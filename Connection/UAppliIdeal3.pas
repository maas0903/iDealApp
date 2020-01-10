unit UAppliIdeal3;

interface

uses
  NCHeader, ParamObjConst, UParamObj, UappliObj, ADODB_TLB, NCDescrSvr_TLB, SysUtils, Variants, ActiveX,
  MSXML_TLB, math, ACZip, Windows, NCPubConstants, TechLog,
  classes, Forms, NCPayDataMaint_TLB, DateUtils,
  UProtocolObj, BEHttpObj_TLB, UCryptAPIWrapper, UTrn, Tools, GPTimeZone,
  UOGRPCClientCalls, IDStrings, uXmlCan, Base64, StrUtils, Dialogs, SBBTools,
  SBX509, SBSHA2, SBUtils, SBPublicKeyCrypto, SBConstants, SBTypes ;
const
  arrIdealApplication3 : array [0..6]of TParamRec = (
     (ParamGroup:AcqParamGroup  ; ParamName:'SignPrivKey'          ; ParamType:ftString ; EnumValues:''     ; help:'Private Key used to sign outgoing XML (put a key without a password).'),
     (ParamGroup:AcqParamGroup  ; ParamName:'SignThumbprint'       ; ParamType:ftString ; EnumValues:'4DDD5A796F9EEAC2BC7CB715D29634C2F944B863' ; help:'Thumbprint of the certificate linked with the priv key above.'),
     (ParamGroup:AcqParamGroup  ; ParamName:'IDEALCertificate'     ; ParamType:ftString ; EnumValues:''     ; help:'Acquirer certificate used to verify signature.'#13#10'Format: c:\cert\pem\whatever_thumbprint.pem - '#13#10'All files must be uploaded with the same format except the "thumbprint".'#13#10'When configuring, the "thumbprint.pem" part must be avoided.'),
     (ParamGroup:AcqParamGroup  ; ParamName:'CheckAcqSig'          ; ParamType:ftBoolean; EnumValues:'1'    ; help:'Determines whether or not acquirer signature should be checked on status result messages.'),
     (ParamGroup:AcqParamGroup  ; ParamName:'ExpireSupport'        ; ParamType:ftBoolean; EnumValues:'0'    ; help:'Set to true in order to send expiration period in transaction request.'),
     (ParamGroup:AcqParamGroup  ; ParamName:'Dir_MID_override'     ; ParamType:ftString;  EnumValues:''     ; help:'MerchantID/Subid override for Directory Request - if set replace the value comming from the FE.'),
     (ParamGroup:AcqParamGroup  ; ParamName:'STRICT_DESC_TRANSFORM'; ParamType:ftBoolean; EnumValues:'1'  ; help:'If set, description only contains Alpha + Num + Spaces')
  );

type

  TAppliIdeal3 = class( TOnLineApplication )
    private
      procedure LogSentReceived(const sToSend,sAnswer : String; const LogLevel : TLogEntryType);
    protected
      function  StandardizeTrnCode(var Transac : TTrnMsg) : integer;override;
      function  CleanString(sData: String): String;
    public
      fExpectedResponse : String;  // Move above after

      function  Canonicalize(node : IXMLDomNode; bEncodeUTF8 : boolean) : String;
      function  CalcDigest(sData : String) : String;
      function  SignDataV3(sData : String) : String;
      function  DigestToBinary(const Digest : TMessageDigest256) : string;
      function  GetAcquirerCertificate(sThumbprint : String) : String;

      function  BuildIssuerListRequestV3(sMerchantID, sSubID: String): IXMLDOMDocument;
      function  IssuerListResToStringV3(dom: IXMLDomDocument): String;

      procedure CompleteAuthenticationFieldsV3(dom : IXMLDomDocument; sReqType : String; bEncodeUTF8 : boolean);

      function  CheckAcquirerSignatureV3(dom: IXMLDomDocument; sNodeName : String): boolean;
      function  BuildTransactionRequestV3(sMerchantID, sSubID, sIssuerID,sMerchantURL, sPurchasid, sCurrency, sLang, sDescr, sEntranceCode, sAmount, sExpPeriod: String): IXMLDOMDocument;
      function  TransformDescriptionV3(sInput: String): STring;
      function  BuildStatusRequestV3(sMerchantID, sSubID,sTransactionID: String): IXMLDOMDocument;
      function  TreatResponseV3(sAnsWer : String; var trn: TTrnMsg) : Boolean;
      function  BuildRequestsV3(trn: TTrnMsg) : String;

      procedure AddAttributeToNode( dom  : IXMLDOMDocument;node: IXMLDomNode;sAttName,sAttValue : String);
      function  GetDateStamp(dtMoment: TDateTime): String;
      function  GetUTCTime(dtLocalDate: TDateTime): TDateTime;
      procedure SafeXMLLoad(const sXML: String; dom: IXMLDOmDocument);
      function  CheckIsErrResponse(var trn : TTrnMsg; dom : IXMLDomDocument) : boolean;

      function  FormatExpirationPeriod(iMinutes : integer) : String;

      function  CleanUpAmpersandsInField(sFieldTag : String;sInput: String): String;
      function  FormatCurrency(sInput: String): String;
      function  FormatLanguage(sInput: String): String;
      function  ReadNodeVal(dom: IXMLDomDocument;sQueryString: String): String;
      procedure ApplyMerchantParamRS(sMerchant, sApp, sAcq: String;rsParams: RecordSet; var bManualConfigNeeded: boolean); override;
      function  SendTrn(var trn : TTrnMsg) : integer; override;
      procedure GetParamArray(var pArr: Pointer; var LowIndex,HighIndex : Integer); override;
end;

const

  C_IDEAL_VERSION3     = '3.3.1';
  C_IDEAL_NAMESPACE3   = 'http://www.idealdesk.com/ideal/messages/mer-acq/3.3.1';
  C_PI3                = '<?xml version="1.0" encoding="UTF-8"?>';
  C_SIG_NAMESPACE3     = 'http://www.w3.org/2000/09/xmldsig#';

  c_AcquirerTrxReq     = 'AcquirerTrxReq';
  c_DirectoryReq       = 'DirectoryReq';
  c_AcquirerStatusReq  = 'AcquirerStatusReq';

  C_ERR_ISSUER_NOT_RESPONDING = '30051100';

implementation

{ TAppliIdeal3 }

procedure TAppliIdeal3.ApplyMerchantParamRS(sMerchant, sApp, sAcq: String; rsParams: RecordSet; var bManualConfigNeeded: boolean);
begin
  LoadMerchantParamsFromRS(sApp,sAcq,sMerchant);
  LoadAcquirerParamsFromRS(sApp,sAcq);
end;

function TAppliIdeal3.CheckAcquirerSignatureV3(dom : IXMLDomDocument; sNodeName : String) : boolean;
var
  tmpNode, node, SignatureNode, SignedInfo : IXMLDomNode;
  sThumbPrint, sSigVal, sCertFileName, sDigestValue, sTmp, sDigest, sPubKey, sBuffer, sSignedInfoCan : String;
  Cert509 : TElX509Certificate;
  RSAPK : TElRSAPublicKeyCrypto;
  FS : TFileStream;
  xres : TSBPublicKeyVerificationResult;
  fdom: IXMLDomDocument;
begin
  result := false;
  try
    // extract signature fields
    SignatureNode := dom.SelectSingleNode('//*/Signature');
    if SignatureNode = Nil then begin
      Exit;
    end;
    tmpNode := SignatureNode.SelectSingleNode('//*/KeyName');
    if assigned(tmpNode) then begin
      sThumbPrint := tmpNode.text;
    end
    else begin
      sThumbPrint := '';
    end;
    sCertFileName := GetAcquirerCertificate(sThumbPrint);

    tmpNode := SignatureNode.SelectSingleNode('//*/SignatureValue');
    if assigned(tmpNode) then begin
      sSigVal := tmpNode.text;
    end
    else begin
      sSigVal := '';
    end;
    tmpNode := SignatureNode.SelectSingleNode('//*/DigestValue');
    if assigned(tmpNode) then begin
      sDigestValue :=  tmpNode.text;
    end
    else begin
      sDigestValue := '';
    end;

    SignedInfo := SignatureNode.SelectSingleNode('//*/SignedInfo');
//  sSignedInfoCan := Canonicalize(SignedInfo); // Contains the CanNonical form of SignInfo
   fdom := CoDOMDocument.Create;
   try
     fdom.loadxml(SignedInfo.xml);
     node := fdom.selectSingleNode('SignedInfo');
     sSignedInfoCan := Canonicalize(node, True);
   finally
     fdom :=Nil;
   end;



    node := dom.selectSingleNode(sNodeName);
    node.removeChild(SignatureNode);
    // Canonicalize root xml
    sTmp := Canonicalize(node, True);

    // sh256 Encode + Base64 encode, normally must be
    sDigest := CalcDigest(sTmp);
      if sDigest <> sDigestValue then begin
      LogMessage(letError,'Calculated digest <> received digest');
      Exit;
    end;



    try
      FS := TFileStream.Create(sCertFileName, fmOpenRead or fmShareDenyNone);
      try
        SetLength(sPubKey, FS.Size);
        FS.Read(sPubKey[1], FS.Size);
      finally
        FS.Free;
      end;
    except
      PostSysErrMessage( 'IDEAL_SIG_ERR',FsAcquirer, FsApplication, Protocol.Media.DeviceLabel, Protocol.Media.TelecomCH,
                         'Exception in signature check using this filename:' + sCertFileName, '', 1);
      result := True; // To avoid question from support and merchant, the signature is considered as OK but an event is posted, L3 can check.
      Exit;
    end;

    Cert509 := TElX509Certificate.Create(Nil);
    try
      Cert509.LoadFromBufferPEM(Pointer(@sPubKey[1]), Length(sPubKey),'');

      RSAPK := TElRSAPublicKeyCrypto.Create(SB_OID_SHA256_RSAENCRYPTION); // Impact NOW with the new SBB library... Initially when developped the value was not used..
      try
        RSAPK.KeyMaterial := Cert509.KeyMaterial;
        RSAPK.OutputEncoding := pkeBinary;// No importance, only Input.
        RSAPK.InputEncoding := pkeBinary;
        sBuffer := StringReplace(sSigVal, #13, '', [rfReplaceAll]);
        sBuffer := StringReplace(sBuffer, #10, '', [rfReplaceAll]);
        sBuffer := StringReplace(sBuffer, ' ', '', [rfReplaceAll]);
        sBuffer := DecodeThis(sBuffer);
        xres := RSAPK.VerifyDetached(Pointer(@sSignedInfoCan[1]), Length(sSignedInfoCan), Pointer(@sBuffer[1]), Length(sBuffer));
      finally
        RSAPK.Free;
      end;
      if xres = pkvrSuccess then begin
        Result := True;
      end
      else begin
        LogMessage(letError,'Signature KO:' + IntToStr(Ord(xres)));
      end;
    finally
      Cert509.Free;
    end;
    {
    0            1                     2               3
    pkvrSuccess, pkvrInvalidSignature, pkvrKeyNotFound,pkvrFailure
    }

  except
    on e:exception do begin
      LogMessage(letError,'Exception in acquirer signature validation: '+e.ClassName+' '+e.Message);
      LogMessage(letError,'XML='+dom.xml);
    end;
  end;
  fdom :=Nil;
end;

function TAppliIdeal3.GetDateStamp(dtMoment : TDateTime) : String;
begin
  dtMoment := GetUTCTime(dtMoment);
  result := FormatDateTime('YYYY-MM-DD',dtMoment) + 'T' + FormatDateTime('HH:NN:SS.ZZZ',dtMoment)   +'Z';
end;

procedure TAppliIdeal3.GetParamArray(var pArr: Pointer; var LowIndex,
  HighIndex: Integer);
begin
  pArr      := Addr(arrIdealApplication3);
  LowIndex  := Low (arrIdealApplication3);
  HighIndex := High(arrIdealApplication3);
end;

function TAppliIdeal3.CleanUpAmpersandsInField(sFieldTag : String;sInput : String) : String;
var
  iPos,iStart,iEnd : integer;
  sTemp,sReplace : String;
begin
  result := sInput;

  iPos := pos('&',sInput);
  if iPos < 1 then exit;

  iStart := Pos('<'+sFieldTag+'>',sInput);
  iEnd := Pos('</'+sFieldTag+'>',sInput);

  if (iStart <1) or (iEnd < 1) or (iEnd < iStart) then
    exit;


  iStart := iStart +  Length('<'+sFieldTag+'>');
  sTemp := Copy(sInput,iStart ,(iEnd - iStart) );

  iPos := pos('&',sTemp);
  if iPos < 1 then exit;

  sReplace := strHTMLEncode( strHTMLDecode( sTemp));
  result := StringReplace(sInput,sTemp,sReplace,[]);
end;

procedure TAppliIdeal3.SafeXMLLoad(const sXML: String; dom: IXMLDOmDocument);
var
  iStart,iEnd : integer;
  sTemp : String;
begin
  iStart := Pos('<?xml',sXML);
  iEnd   := Pos('?>',sXML)+2;
  sTemp := sXML;
  if (iStart > 0) and (iEnd > iStart) then //remove everything up to and including processing instruction
    sTemp := Copy(sTemp,iEnd,Length(sTemp));
  dom.async := false;
  dom.preserveWhiteSpace := true;
  if not dom.loadXML(sTemp) then begin
    raise Exception.create('Unable to load XML response : '+sXML);
  end;
end;


function TAppliIdeal3.GetUTCTime(dtLocalDate : TDateTime) : TDateTime;
var
  tzInfo : _TIME_ZONE_INFORMATION;
  iRes : integer;
  bIsDayLightNow : boolean;
begin
  iRes := GetTimeZoneInformation(tzInfo);
  if iRes = TIME_ZONE_ID_UNKNOWN then
    raiseLastOSError;
  bIsDaylightNow := iRes = TIME_ZONE_ID_DAYLIGHT;// preference for ambiguous times when going from DST to STD, when an hour repeats itself !!
  result := TZLocalTimeToUTC(tzInfo,dtLocalDate,bIsDayLightNow);
end;

function TAppliIdeal3.CheckIsErrResponse(var trn : TTrnMsg; dom: IXMLDomDocument): boolean;
var
  tmpNode : IXMLDomNode;
  sErrMessage, sErrorCode : String;
  sTemp : String;
begin
  result  := dom.documentElement.nodeName = 'AcquirerErrorRes';
  sErrMessage := '';
  if result then begin
    LogMessage(letError,'iDeal response is an error message.');


    tmpNode := dom.SelectSingleNode('//*/errorCode');
    if assigned(tmpNode) then begin
      sErrorCode := tmpNode.text;
      LogMessage(letError,'  Ideal error code  =' + sErrorCode);
      if sErrorCode = 'SO1100' then begin
        trn.Error := C_ERR_ISSUER_NOT_RESPONDING;
        sErrMessage := trn.Error+'/';
      end
      else begin
        trn.Error := InttoStr(AUTHENTICATION_PROTOCOL_ERROR);
      end;
    end;

    tmpNode := dom.SelectSingleNode('//*/errorMessage');
    if assigned(tmpNode) then begin
      sTemp := tmpNode.text;
      LogMessage(letError,'  Ideal error msg   =' + sTemp);
      if sTemp  <> '' then
        sErrMessage := sErrMessage + sTemp +'.';
    end;

    tmpNode := dom.SelectSingleNode('//*/errorDetail');
    if assigned(tmpNode) then begin
      sTemp := tmpNode.text;
      LogMessage(letError,'  Ideal error detail=' + sTemp);
      if sTemp  <> '' then
        sErrMessage := sErrMessage + ' '+ sTemp +'.';
    end;

    tmpNode := dom.SelectSingleNode('//*/suggestedAction');
    if assigned(tmpNode) then begin
      sTemp := tmpNode.text;
      LogMessage(letError,'  Suggested action  =' + sTemp);
      if sTemp  <> '' then
        sErrMessage := sErrMessage + ' '+ sTemp +'.';
    end;

    tmpNode := dom.SelectSingleNode('//*/consumerMessage');
    if assigned(tmpNode) then begin
      sTemp := tmpNode.text;
      LogMessage(letError,'  Consumer message  =' + sTemp);
      if sTemp  <> '' then
        sErrMessage := sErrMessage + ' '+ sTemp +'.';
    end;

    trn.ResMsg := 'Acquirer response is an error message ['+sErrMessage+'] .';
    trn.Status := 'ERROR';
    trn.Ticket := sErrMessage;
  end;
end;

function TAppliIdeal3.FormatExpirationPeriod(iMinutes: integer): String;
var
  iHour : integer;
begin
  try
    if (iMinutes > 60) or (iMinutes < 0) then
      iMinutes := 60
    else if iMinutes < 3 then
      iMinutes := 60;

    iHour := iMinutes div 60;
    iMinutes := iMinutes mod 60;
    result := 'PT';
    if iHour > 0 then
      result := result + IntToStr(iHour) +'H';
    if iMinutes > 0 then
      result := result + IntToStr(iMinutes)+'M';
  except
    result := '';
  end;
end;

function TAppliIdeal3.SendTrn(var trn: TTrnMsg): integer;
var
  sToSend, sAnswer : String;
  LogLevel : TLogEntryType;
begin
  sToSend := BuildRequestsV3(trn);
  FProtocol.WriteMessage(sToSend, sAnswer);
  result := FProtocol.Status;
  LogLevel := letDebug;
  if result = 0 then begin
    if not TreatResponseV3(sAnsWer, Trn) then begin
      LogLevel := letError;
      if ((Length(sAnswer) = 0) or (trn.Status <> 'ERROR')) and (trn.Error <> C_ERR_ISSUER_NOT_RESPONDING) then begin
        trn.ResMsg := 'Response could not be treated';
        trn.Error := intToStr(PARSING_FAILED);
        trn.status := 'ERROR';
      end;
    end;
  end
  else begin
    trn.Error :=  IntToStr(HOST_RESPONSE_TIMOUT);
    trn.Status := 'ERROR';
    trn.ResMsg := 'No response from acquirer';
    LogLevel := letError;
  end;
  LogSentReceived(sToSend,sAnswer,LogLevel);
end;

procedure TAppliIdeal3.LogSentReceived(const sToSend,sAnswer : String; const LogLevel : TLogEntryType);
begin
  LogMessageLong(LogLevel, 'Sent:' +  sToSend, false);
  LogMessageLong(LogLevel, 'Received:' +  sAnswer, false);
end;

function TAppliIdeal3.StandardizeTrnCode(var Transac: TTrnMsg): integer;
begin
  result :=  0;
  if Transac.ReqCode = REQ_PRE then // issuer list
    Transac.TrnCode := TC_PRE
  else if Transac.ReqCode = REQ_INT then  // trx req
    Transac.TrnCode := TC_INT
  else if Transac.ReqCode = REQ_GDT then  // status req
    Transac.TrnCode := TC_GDT
  else begin
    result := INVALID_CODE_FOR_HOST;
    EXIT;
  end;
end;

function TAppliIdeal3.FormatCurrency(sInput : String) : String;
var
  ifDescr : INCDescriptiveSvr;
begin
  if (sInput = '978') or (sInput = 'EUR') then
    result := 'EUR'
  else begin
    ifDescr := coNCDescriptiveSvr.Create;
    result := ifDescr.GetCurrAlphaCode(sInput);
    ifDescr := nil;
  end;
end;

function TAppliIdeal3.FormatLanguage(sInput : String) : String;
begin
  result :=  'nl';
  //map to DESTCTRYCODE if needed -- initially only language really supported was nl -- don't know if this has evolved...
end;


function TAppliIdeal3.ReadNodeVal(dom : IXMLDomDocument;sQueryString: String): String;
var
  tmpNode : IXMLDomNode;
begin
  tmpNode := dom.SelectSingleNode(sQueryString);
  if not Assigned(tmpNode) then
    result := ''
  else
    result := tmpNode.Text;
end;


function TAppliIdeal3.BuildIssuerListRequestV3(sMerchantID, sSubID: String): IXMLDOMDocument;
var
  dom  : IXMLDOMDocument;
  root,mer, tmpNode : IXMLDOMNode;
  att : IXMLDomAttribute;
  sTmp : String;
begin
  sTmp := GetParam('Dir_MID_override');
  if sTmp <> '' then begin
    LogMessage(letNormal, 'MerchantID and SubID override on the directory request:' + sTmp);
    sMerchantID := GetField_(sTmp, '/', 1);
    sSubID      := GetField_(sTmp, '/', 2);
  end;
  fExpectedResponse := 'DirectoryRes';
  dom := CoDOMDocument.Create;
  try
    root :=   dom.createnode( NODE_ELEMENT,c_DirectoryReq, C_IDEAL_NAMESPACE3);
    att :=  dom.createAttribute( 'version');
    att.value := C_IDEAL_VERSION3;
    root.attributes.setNamedItem(att) ;
    dom.documentElement := IXMLDomElement(root);

    tmpNode := dom.createnode( NODE_ELEMENT,'createDateTimestamp', C_IDEAL_NAMESPACE3);
    tmpNode.text := GetDateStamp(now);
    root.appendChild(tmpNode);


    mer := dom.createnode( NODE_ELEMENT,'Merchant', C_IDEAL_NAMESPACE3);
    root.appendChild(mer);
    mer.text := #13#10;

    tmpNode :=  dom.createnode( NODE_ELEMENT,'merchantID', C_IDEAL_NAMESPACE3);
    tmpNode.text := sMerchantID;
    mer.appendChild(tmpNode);

    tmpNode :=  dom.createnode( NODE_ELEMENT,'subID', C_IDEAL_NAMESPACE3);
    tmpNode.text := sSubID;
    mer.appendChild(tmpNode);
    result := dom;
  finally
  end;
end;


procedure TAppliIdeal3.AddAttributeToNode(dom: IXMLDOMDocument; node: IXMLDomNode; sAttName, sAttValue: String);
var
  att : IXMLDomAttribute;
begin
  att := dom.createAttribute(sAttName);
  att.value := sAttValue;
  node.attributes.setNamedItem(att);
end;

procedure TAppliIdeal3.CompleteAuthenticationFieldsV3(dom: IXMLDomDocument; sReqType : String; bEncodeUTF8 : boolean);
var
  sTmp, sDigest, sKeyThumbPrint : String;
  tmpNode, sig, node, SignedInfo, ReferenceNode, TransFormsNode, KeyInfoNode : IXMLDomNode;
  fdom: IXMLDomDocument;
begin
  fdom := CoDOMDocument.Create;
  try
    fdom.preserveWhiteSpace := true;
    fdom.loadxml(dom.xml);
    node := fdom.selectSingleNode(sReqType);
    sTmp := Canonicalize(node, bEncodeUTF8);    // !!!!!!
  finally
    fdom :=Nil;
  end;
  sDigest := CalcDigest(sTmp);

  node := dom.selectSingleNode(sReqType);
  sig :=  dom.createnode(NODE_ELEMENT,'Signature', C_SIG_NAMESPACE3);
  sig.text := '';
  node.appendChild(sig);

//  SignedInfo :=  dom.createnode( NODE_ELEMENT,'SignedInfo', C_SIG_NAMESPACE3);
  SignedInfo :=  dom.createnode( NODE_ELEMENT,'SignedInfo', C_SIG_NAMESPACE3);
  SignedInfo.text := '';
  sig.appendChild(SignedInfo);

  tmpNode :=  dom.createnode( NODE_ELEMENT,'CanonicalizationMethod', C_SIG_NAMESPACE3);
  AddAttributeToNode(dom, tmpNode, 'Algorithm', 'http://www.w3.org/2001/10/xml-exc-c14n#');
  SignedInfo.appendChild(tmpNode);

  tmpNode :=  dom.createnode( NODE_ELEMENT,'SignatureMethod', C_SIG_NAMESPACE3);
  AddAttributeToNode(dom, tmpNode, 'Algorithm', 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256');
  SignedInfo.appendChild(tmpNode);

  ReferenceNode :=  dom.createnode( NODE_ELEMENT,'Reference', C_SIG_NAMESPACE3);
  AddAttributeToNode(dom, ReferenceNode, 'URI', '');
  SignedInfo.appendChild(ReferenceNode);

  TransFormsNode :=  dom.createnode( NODE_ELEMENT,'Transforms', C_SIG_NAMESPACE3);
  ReferenceNode.appendChild(TransFormsNode);

  tmpNode :=  dom.createnode( NODE_ELEMENT,'Transform', C_SIG_NAMESPACE3);
  AddAttributeToNode(dom, tmpNode, 'Algorithm', 'http://www.w3.org/2000/09/xmldsig#enveloped-signature');
  TransFormsNode.appendChild(tmpNode);

  tmpNode :=  dom.createnode( NODE_ELEMENT,'DigestMethod', C_SIG_NAMESPACE3);
  AddAttributeToNode(dom, tmpNode, 'Algorithm', 'http://www.w3.org/2001/04/xmlenc#sha256');
  ReferenceNode.appendChild(tmpNode);

  tmpNode :=  dom.createnode( NODE_ELEMENT,'DigestValue', C_SIG_NAMESPACE3);
  tmpNode.text := sDigest;
  ReferenceNode.appendChild(tmpNode);

  // Now we can Canonicalize the signature
  fdom := CoDOMDocument.Create;
  
  try
    fdom.loadxml(SignedInfo.xml);
    node := fdom.selectSingleNode('SignedInfo');
    sTmp := Canonicalize(node, True);
  finally
    fdom :=Nil;
  end;
  sDigest := SignDataV3(sTmp);
  tmpNode :=  dom.createnode( NODE_ELEMENT,'SignatureValue', C_SIG_NAMESPACE3);
  tmpNode.text := sDigest;
  sig.appendChild(tmpNode);
  KeyInfoNode :=  dom.createnode( NODE_ELEMENT,'KeyInfo', C_SIG_NAMESPACE3);
  KeyInfoNode.text := '';
  sig.appendChild(KeyInfoNode);

  sKeyThumbPrint := GetParam('SignThumbprint');
  tmpNode :=  dom.createnode( NODE_ELEMENT,'KeyName', C_SIG_NAMESPACE3);
  tmpNode.text := sKeyThumbPrint;
  KeyInfoNode.appendChild(tmpNode);
end;

function TAppliIdeal3.Canonicalize(node: IXMLDomNode; bEncodeUTF8 : boolean): String;
var
  tXMLCan : TclXmlCanonicalizer;
begin
  tXMLCan := TclXmlCanonicalizer.Create;
  try
    tXMLCan.EncodeUTF8 := bEncodeUTF8;
    result := tXMLCan.Canonicalize(node) ;
  finally
    tXMLCan.Free;
  end;
end;

function TAppliIdeal3.CalcDigest(sData: String): String;
begin
  Result := EncodeThis(DigestToBinary(HashSHA256(BytesOfString(sData))));
end;

function TAppliIdeal3.SignDataV3(sData: String): String;
var
  sSigVal, sKeyFile, sPrivKey, sTmp : String;
  RSAPrivK : TElRSAKeyMaterial;
  RSAPK : TElRSAPublicKeyCrypto;
  FS : TFileStream;
  iResSize, i : Integer;
begin
  sKeyFile := GetParam('SignPrivKey');

  if not FileExists(sKeyFile) then
   raise Exception.create('Unable to open private key file:' + sKeyFile);
  FS := TFileStream.Create(sKeyFile, fmOpenRead or fmShareDenyNone);
  try
    SetLength(sPrivKey, FS.Size);
    FS.Read(sPrivKey[1], FS.Size);
  finally
    FS.Free;
  end;
  RSAPrivK := TElRSAKeyMaterial.Create;
  RSAPK := TElRSAPublicKeyCrypto.Create(SB_OID_SHA256_RSAENCRYPTION);
  try
    //
    // !!!! The component only supports key encryption with DES or 3DES. - AES not supported !!!!!
    // To avoid decryption of the key (and errors) - it's saved without password, see openssl documentation.
    // openssl rsa -in privkey_enc.pem -out privkey_no_pwd.pem
    //
    RSAPrivK.Passphrase := '';
    RSAPrivK.LoadSecret(Pointer(@sPrivKey[1]), Length(sPrivKey));
    LogMessage(letNormal, 'Value to sign :"'+sData+'"');
    RSAPK.KeyMaterial := RSAPrivK;
//    RSAPK.OutputEncoding := pkeBinary; // output in base64.
    RSAPK.OutputEncoding := pkeBase64; // output in base64.
    iResSize := 1024;                  // 1024 bytes are enough - a signature even in base 64 is below 512 bytes.
    SetLength(sSigVal, iResSize);      // Set bufefr size.
    RSAPK.SignDetached(Pointer(@sData[1]), Length(sData), Pointer(@sSigVal[1]), iResSize);
    sTmp := LeftStr(sSigVal, iResSize); //iResSize now copntains ths signature size.
//    sTmp := EncodeThis(sTmp); encoded above
    i := 1;
    Result := '';
    while i < Length(sTmp) do begin
      Result := Result + Copy(sTmp, i, 76) + #13#10;
      i := i + 76;
    end;
    Result := Copy(Result, 1, Length(Result) - 2);

  finally
    RSAPrivK.Free;
    RSAPK.Free;
  end;
end;

function TAppliIdeal3.DigestToBinary(const Digest: TMessageDigest256): string;
begin
  SetLength(Result, 32);
  Move(Digest, Result[1], 32);
end;

function TAppliIdeal3.GetAcquirerCertificate(sThumbprint: String): String;
begin
  //
  Result := GetParam('IDEALCertificate') + sThumbprint + '.pem';
end;

function TAppliIdeal3.IssuerListResToStringV3(dom: IXMLDomDocument): String;
var
  tmpNode,xnID,xnName, xnCounty : IXMLDomNode;
  tmpList, tmpCtryList : IXMLDOMNodeList;
  i, j : integer;
  sCountryNames : String;
const
  c_lineEnd = '|';
  c_FieldEnd = '?';
begin
  result := '';
  tmpNode := dom.SelectSingleNode('//*/directoryDateTimestamp');
  if assigned(tmpNode) then
     result :=  result + tmpNode.text;
  result := result + c_LineEnd ;
  // Country names ara available - don't know if FE needs this info...
  tmpCtryList := dom.getElementsByTagName('*/Country');
  for j := 0 to tmpCtryList.length - 1 do begin
    tmpNode := tmpCtryList[j];
    xnCounty := tmpNode.selectSingleNode('countryNames');
    if xnCounty <> Nil then
      sCountryNames := xnCounty.text
    else
      sCountryNames := '';
    
    tmpList := tmpNode.selectNodes('Issuer');//  .getElementsByTagName('*/Issuer');
    for i := 0 to tmpList.length - 1 do begin
      tmpNode := tmpList[i];
      xnID := tmpNode.selectSingleNode('issuerID');
      if not Assigned(xnID) then
        raise Exception.Create('Received issuer list xml has an invalid structure');
      xnName := tmpNode.selectSingleNode('issuerName');
      if not Assigned(xnName) then
        raise Exception.Create('Received issuer list xml has an invalid structure');
      result := result +  xnID.text + c_FieldEnd +  xnName.text + c_FieldEnd + '' + c_FieldEnd + sCountryNames +  c_LineEnd;
    end;
  end;
end;


function TAppliIdeal3.BuildTransactionRequestV3(sMerchantID, sSubID,
  sIssuerID, sMerchantURL, sPurchasid, sCurrency, sLang, sDescr,
  sEntranceCode, sAmount, sExpPeriod: String): IXMLDOMDocument;
var
  dom  : IXMLDOMDocument;
  root,iss,mer,trx,tmpNode : IXMLDOMNode;
  att : IXMLDomAttribute;
begin
  fExpectedResponse := 'AcquirerTrxRes';
  dom := CoDOMDocument.Create;
  try
    root :=   dom.createnode( NODE_ELEMENT,c_AcquirerTrxReq, C_IDEAL_NAMESPACE3);
    att :=  dom.createAttribute( 'version');
    att.value := C_IDEAL_VERSION3;
    root.attributes.setNamedItem(att) ;
    dom.documentElement := IXMLDomElement(root);

    tmpNode := dom.createnode( NODE_ELEMENT,'createDateTimestamp', C_IDEAL_NAMESPACE3);
    tmpNode.text := GetDateStamp(now);
    root.appendChild(tmpNode);

    iss := dom.createnode( NODE_ELEMENT,'Issuer', C_IDEAL_NAMESPACE3);
    root.appendChild(iss);

    tmpNode :=  dom.createnode( NODE_ELEMENT,'issuerID',C_IDEAL_NAMESPACE3);
    tmpNode.text :=  sIssuerID;
    iss.appendChild(tmpNode);

    mer := dom.createnode( NODE_ELEMENT,'Merchant', C_IDEAL_NAMESPACE3);
    root.appendChild(mer);

    tmpNode :=  dom.createnode( NODE_ELEMENT,'merchantID', C_IDEAL_NAMESPACE3);
    tmpNode.text := sMerchantID;
    mer.appendChild(tmpNode);

    tmpNode :=  dom.createnode( NODE_ELEMENT,'subID', C_IDEAL_NAMESPACE3);
    tmpNode.text := sSubID;
    mer.appendChild(tmpNode);

    tmpNode :=  dom.createnode( NODE_ELEMENT,'merchantReturnURL', C_IDEAL_NAMESPACE3);  // AN max 512
    tmpNode.text := Trim(sMerchantURL);
    mer.appendChild(tmpNode);

    trx :=  dom.createnode( NODE_ELEMENT,'Transaction', C_IDEAL_NAMESPACE3);
    root.appendChild(trx);

    tmpNode :=  dom.createnode( NODE_ELEMENT,'purchaseID', C_IDEAL_NAMESPACE3); // ANS 16 (35 in the future - )
    tmpNode.text := LeftSTr(TrimNonAlphaNum(sPurchasID), 35);
    trx.appendChild(tmpNode);

    tmpNode :=  dom.createnode( NODE_ELEMENT,'amount', C_IDEAL_NAMESPACE3);
    tmpNode.text := sAmount;
    trx.appendChild(tmpNode);

    tmpNode :=  dom.createnode( NODE_ELEMENT,'currency', C_IDEAL_NAMESPACE3);
    tmpNode.text := sCurrency;
    trx.appendChild(tmpNode);

    tmpNode :=  dom.createnode( NODE_ELEMENT,'expirationPeriod', C_IDEAL_NAMESPACE3);
    tmpNode.text := sExpPeriod;
    trx.appendChild(tmpNode);

    tmpNode :=  dom.createnode( NODE_ELEMENT,'language', C_IDEAL_NAMESPACE3);
    tmpNode.text := 'nl';//sLang
    trx.appendChild(tmpNode);

    tmpNode :=  dom.createnode( NODE_ELEMENT,'description', C_IDEAL_NAMESPACE3);   // AN max 32
    tmpNode.text := LeftStr(TransformDescriptionV3(sDescr), 35);
    trx.appendChild(tmpNode);

    tmpNode :=  dom.createnode( NODE_ELEMENT,'entranceCode', C_IDEAL_NAMESPACE3); // ANS max 40
    tmpNode.text := LeftStr(TrimNonAlphaNum(sEntranceCode), 40);
    trx.appendChild(tmpNode);
    result := dom;
  finally
  end;
end;

function TAppliIdeal3.TransformDescriptionV3(sInput: String): STring;
begin
  if GetParamBool('STRICT_DESC_TRANSFORM') then
    result := TrimNonAlphaNum(sInput)
  else
    result := Utf8Encode(CleanString(sInput));
end;

function TAppliIdeal3.BuildStatusRequestV3(sMerchantID, sSubID, sTransactionID: String): IXMLDOMDocument;
var
  dom  : IXMLDOMDocument;
  root, mer, trx, tmpNode : IXMLDOMNode;
  att : IXMLDomAttribute;
begin
  fExpectedResponse := 'AcquirerStatusRes';
  dom := CoDOMDocument.Create;
  try
    root :=   dom.createnode( NODE_ELEMENT,c_AcquirerStatusReq, C_IDEAL_NAMESPACE3);
    att :=  dom.createAttribute( 'version');
    att.value := C_IDEAL_VERSION3;
    root.attributes.setNamedItem(att) ;
    dom.documentElement := IXMLDomElement(root);

    tmpNode := dom.createnode( NODE_ELEMENT,'createDateTimestamp', C_IDEAL_NAMESPACE3);
    tmpNode.text := GetDateStamp(now);
    root.appendChild(tmpNode);

    mer := dom.createnode( NODE_ELEMENT,'Merchant', C_IDEAL_NAMESPACE3);
    root.appendChild(mer);

    tmpNode :=  dom.createnode( NODE_ELEMENT,'merchantID', C_IDEAL_NAMESPACE3);
    tmpNode.text := sMerchantID;
    mer.appendChild(tmpNode);

    tmpNode :=  dom.createnode( NODE_ELEMENT,'subID', C_IDEAL_NAMESPACE3);
    tmpNode.text := sSubID;
    mer.appendChild(tmpNode);

    trx :=  dom.createnode( NODE_ELEMENT,'Transaction',C_IDEAL_NAMESPACE3);
    root.appendChild(trx);

    tmpNode :=  dom.createnode( NODE_ELEMENT,'transactionID',C_IDEAL_NAMESPACE3);
    tmpNode.text := sTransactionID;
    trx.appendChild(tmpNode);

    result := dom;

  finally

  end;

end;

function TAppliIdeal3.TreatResponseV3(sAnsWer: String; var trn: TTrnMsg) : boolean;
var
  dom : IXMLDomDocument;
  sTransactionID, sIssuerURL, sStatus, sAccount, sConsumerName, sConsumerBIC, sAmount, sCurrency, sAnsWerTmp : String;
begin
  Result := False;

  if Length(sAnsWer) = 0 then
    Exit;

  sAnsWerTmp := Utf8Decode(sAnsWer);
  if Length(sAnsWerTmp) > 0 then
    sAnsWer := sAnsWerTmp;

  try
    if trn.TrnCode = TC_GDT then  begin
      sAnsWer := CleanUpAmpersandsInField('consumerName',sAnsWer);
      sAnsWer := CleanUpAmpersandsInField('consumerIBAN',sAnsWer);
      sAnsWer := CleanUpAmpersandsInField('consumerBIC',sAnsWer);
    end;
    dom := CoDOMDocument.Create;
    SafeXMLLoad(sAnsWer,dom);
  except
    on e:exception do begin
      LogMessage(letError,'Request failure : '+e.Message);
      trn.Error := InttoStr(AUTHENTICATION_COMM_FAILURE);
      trn.Status := 'ERROR';
      trn.ResMsg := 'Error loading response : '+e.Message;
      exit;
    end;
  end;
  if CheckIsErrResponse(trn, dom) then begin
    exit;
  end;

  if trn.trnCode = TC_PRE then begin
    trn.Ticket :=  IssuerListResToStringV3(dom);
    trn.Error := '0';
    trn.ResMsg := '';
    trn.Acceptation := '0';
    trn.Status := 'CLEARED';
    Result := True;
  end
  else
    if trn.TrnCode = TC_INT then   begin
      // return trnid and url
      sTransactionID := ReadNodeVal(dom,'//*/transactionID');
      sIssuerURL := ReadNodeVal(dom,'//*/issuerAuthenticationURL');
      if (trim(sIssuerURL) = '' ) or (StrToInt64Def(sTransactionID,-1)< 0) then begin
        trn.Error := InttoStr(AUTHENTICATION_PROTOCOL_ERROR);
        trn.ResMsg :=  'Acquirer response is incomplete';
        trn.Status := 'ERROR';
        exit;
      end
      else begin
        trn.Error := '0';
        trn.ResMsg := 'OK-'+sTransactionID;
        trn.Acceptation := '0';
        trn.Status := 'CLEARED';
        trn.Ticket := sTransactionID + '|'+ sIssuerURL;
        trn.AutData := sTransactionID;
        Result := True;
      end;
    end
    else
      if trn.TrnCode = TC_GDT then begin
        sStatus := ReadNodeVal(dom,'//*/status');
        trn.ResMsg := sStatus;

        trn.Acceptation := '';
        trn.Ticket := sStatus;
        if sStatus = 'Success' then begin
          if (GetParam('CheckAcqSig') <> '0') and (not CheckAcquirerSignatureV3(dom, fExpectedResponse)) then begin
            LogMessage(letError,'Returning negative response due to signature error.');
            trn.Error := IntToStr(ACQUIRER_SIGNATURE_INVALID);
            trn.ResMsg :=  'Check of acquirer signature on status message failed.';
            trn.Status := 'ERROR';
            PostSysErrMessage( 'IDEAL_SIG_ERR',FsAcquirer, FsApplication, Protocol.Media.DeviceLabel, Protocol.Media.TelecomCH,
                               'Check of acquirer signature failed for merchant ' + trn.MID + ', payid ' + trn.IntRef + ', transaction id ' + trn.TransID+'.', dom.xml, 1);
            exit;
          end
          else begin
            trn.Error :=  '0' ;
            trn.Status := 'CLEARED';
            trn.Acceptation := '0';
            try  sConsumerName := ReadNodeVal(dom,'//*/consumerName'); except sConsumerName := '??'  end;
            try  sAccount      := ReadNodeVal(dom,'//*/consumerIBAN'); except sAccount := '??'  end;
            try  sConsumerBIC  := ReadNodeVal(dom,'//*/consumerBIC');  except sConsumerBIC := '??'  end;
            try  sAmount       := ReadNodeVal(dom,'//*/amount');       except sAmount := '??'  end;
            try  sCurrency     := ReadNodeVal(dom,'//*/currency');     except sCurrency := '??'  end;
            trn.Ticket := trn.Ticket + '|' + StringReplace(sConsumerName, '|', '', [rfReplaceAll]) + '|' + sAccount + '|' + sConsumerBIC + '|' + sAmount + '|' + sCurrency;
            Result := True;
          end;
        end
        else
          if sStatus = 'Open' then begin
            trn.Error := '0' ;
            trn.Status := 'CLEARED';
            trn.Acceptation := '-';
            Result := True;
          end
          else
            if (sStatus = 'Expired')  or (sStatus = 'Cancelled') then begin
              trn.Error := IntToStr(TRN_ABANDONED);
              trn.status := 'ERROR';
            end
            else
              if (sStatus = 'Failure')then begin
                trn.Error := IntToStr(PROCESSING_FAILED);
                trn.status := 'ERROR';
              end
              else begin
                trn.ResMsg := 'Unknown iDeal status response :  '+sStatus;
                trn.Error := intToStr(GENERIC_ERROR_FROM_ACQUIRER);
                trn.status := 'ERROR';
              end;
      end;
end;

function TAppliIdeal3.BuildRequestsV3(trn: TTrnMsg): String;
var
  dom : IXMLDOMDocument;
  sExpireMinute, sRetURL, sEntranceCode : String;
begin
  if trn.trnCode = TC_PRE then begin
    dom := BuildIssuerListRequestV3(trn.UID, trn.tid);
    CompleteAuthenticationFieldsV3(dom, c_DirectoryReq, True);
  end
  else if trn.TrnCode = TC_INT then   begin
    sExpireMinute := FormatExpirationPeriod(MinutesBetween(now, trn.AuthTime ));
    sEntranceCode := trn.CardHolderRef;
    sRetURL := trn.ReturnUrl;
    dom := BuildTransactionRequestV3(trn.UID, trn.tid, trn.ExternalCustId, sRetURL, trn.Ref2, FormatCurrency(trn.Currency),
                                     FormatLanguage(trn.DestCtryCode), trn.CustomerID, sEntranceCode, NCAmountToStr(trn.Amount,2,'.'),
                                     sExpireMinute);
    CompleteAuthenticationFieldsV3(dom, c_AcquirerTrxReq, (GetParamBool('STRICT_DESC_TRANSFORM')));
  end
  else if trn.TrnCode = TC_GDT then  begin
    if (trn.CustID = '') and (trn.PrevTrnID > 0) then
      trn.CustID := trn.autdata; // for future use where FE would integrate this in a more standard mode, and GDT would refer to previous trn
    dom := BuildStatusRequestV3(trn.UID, trn.tid, trn.custid);
    CompleteAuthenticationFieldsV3(dom, c_AcquirerStatusReq, True);
  end
  else
    raise Exception.Create('operation code not supported for ideal');
  result := C_PI3 + dom.xml ;
  dom := nil;
end;


function TAppliIdeal3.CleanString(sData: String): String;
var
  sTemp : String;
  i  : integer;
begin
  sTemp := sData;
  for i := 1 to Length(sTemp) do begin
    case sTemp[i] of
      'a'..'z', ' ', 'A'..'Z', '0'..'9', 'À'..'ý',
      '.', '-', '/', '_', '`','*', '+', '@' :;   // Keep Alpha Nums - see comment 2 lines bellow.
      else begin
        //if Ord(sTemp[i]) > 127 then // Removed, DHA 26-05-2005
          sTemp[i] := ' ';

      end;
    end;
  end;
  Result := sTemp;
end;

end.
