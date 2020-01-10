namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class AcquirerStatusRes
    {
        
        #region Private fields
        private System.DateTime _createDateTimestamp;
        
        private AcquirerStatusResAcquirer _acquirer;
        
        private AcquirerStatusResTransaction _transaction;
        
        private SignatureType _signature;
        
        private string _version;
        #endregion
        
        public AcquirerStatusRes()
        {
            this._signature = new SignatureType();
            this._transaction = new AcquirerStatusResTransaction();
            this._acquirer = new AcquirerStatusResAcquirer();
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
        
        public AcquirerStatusResAcquirer Acquirer
        {
            get
            {
                return this._acquirer;
            }
            set
            {
                this._acquirer = value;
            }
        }
        
        public AcquirerStatusResTransaction Transaction
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