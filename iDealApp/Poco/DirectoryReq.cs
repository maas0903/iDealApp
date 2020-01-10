namespace iDealApp.Poco
{
    
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class DirectoryReq
    {
        
        #region Private fields
        private System.DateTime _createDateTimestamp;
        
        private DirectoryReqMerchant _merchant;
        
        private SignatureType _signature;
        
        private string _version;
        #endregion
        
        public DirectoryReq()
        {
            this._signature = new SignatureType();
            this._merchant = new DirectoryReqMerchant();
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
        
        public DirectoryReqMerchant Merchant
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