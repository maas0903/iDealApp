using System.Collections.Generic;

namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class SignatureType
    {
        
        #region Private fields
        private SignedInfoType _signedInfo;
        
        private SignatureValueType _signatureValue;
        
        private KeyInfoType _keyInfo;
        
        private List<ObjectType> _object;
        
        private string _id;
        #endregion
        
        public SignatureType()
        {
            this._object = new List<ObjectType>();
            this._keyInfo = new KeyInfoType();
            this._signatureValue = new SignatureValueType();
            this._signedInfo = new SignedInfoType();
        }
        
        public SignedInfoType SignedInfo
        {
            get
            {
                return this._signedInfo;
            }
            set
            {
                this._signedInfo = value;
            }
        }
        
        public SignatureValueType SignatureValue
        {
            get
            {
                return this._signatureValue;
            }
            set
            {
                this._signatureValue = value;
            }
        }
        
        public KeyInfoType KeyInfo
        {
            get
            {
                return this._keyInfo;
            }
            set
            {
                this._keyInfo = value;
            }
        }
        
        public List<ObjectType> Object
        {
            get
            {
                return this._object;
            }
            set
            {
                this._object = value;
            }
        }
        
        public string Id
        {
            get
            {
                return this._id;
            }
            set
            {
                this._id = value;
            }
        }
    }
}