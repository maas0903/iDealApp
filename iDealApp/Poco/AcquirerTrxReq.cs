namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class AcquirerTrxReq
    {
        
        #region Private fields
        private System.DateTime _createDateTimestamp;
        
        private AcquirerTrxReqIssuer _issuer;
        
        private AcquirerTrxReqMerchant _merchant;
        
        private AcquirerTrxReqTransaction _transaction;
        
        private SignatureType _signature;
        
        private string _version;
        #endregion
        
        public AcquirerTrxReq()
        {
            this._signature = new SignatureType();
            this._transaction = new AcquirerTrxReqTransaction();
            this._merchant = new AcquirerTrxReqMerchant();
            this._issuer = new AcquirerTrxReqIssuer();
        }
        
        public System.DateTime createDateTimestamp
        {
            get
            {
                return this._createDateTimestamp;
            }
            set
            {
                this._createDateTimestamp = value;
            }
        }
        
        public AcquirerTrxReqIssuer Issuer
        {
            get
            {
                return this._issuer;
            }
            set
            {
                this._issuer = value;
            }
        }
        
        public AcquirerTrxReqMerchant Merchant
        {
            get
            {
                return this._merchant;
            }
            set
            {
                this._merchant = value;
            }
        }
        
        public AcquirerTrxReqTransaction Transaction
        {
            get
            {
                return this._transaction;
            }
            set
            {
                this._transaction = value;
            }
        }
        
        public SignatureType Signature
        {
            get
            {
                return this._signature;
            }
            set
            {
                this._signature = value;
            }
        }
        
        public string version
        {
            get
            {
                return this._version;
            }
            set
            {
                this._version = value;
            }
        }
    }
}