namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class AcquirerTrxRes
    {
        
        #region Private fields
        private System.DateTime _createDateTimestamp;
        
        private AcquirerTrxResAcquirer _acquirer;
        
        private AcquirerTrxResIssuer _issuer;
        
        private AcquirerTrxResTransaction _transaction;
        
        private SignatureType _signature;
        
        private string _version;
        #endregion
        
        public AcquirerTrxRes()
        {
            this._signature = new SignatureType();
            this._transaction = new AcquirerTrxResTransaction();
            this._issuer = new AcquirerTrxResIssuer();
            this._acquirer = new AcquirerTrxResAcquirer();
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
        
        public AcquirerTrxResAcquirer Acquirer
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
        
        public AcquirerTrxResIssuer Issuer
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
        
        public AcquirerTrxResTransaction Transaction
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