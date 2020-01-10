namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class AcquirerStatusResTransaction
    {
        
        #region Private fields
        private string _transactionID;
        
        private string _status;
        
        private System.DateTime _statusDateTimestamp;
        
        private string _consumerName;
        
        private string _consumerIBAN;
        
        private string _consumerBIC;
        
        private decimal _amount;
        
        private string _currency;
        #endregion
        
        public string transactionID
        {
            get
            {
                return this._transactionID;
            }
            set
            {
                this._transactionID = value;
            }
        }
        
        public string status
        {
            get
            {
                return this._status;
            }
            set
            {
                this._status = value;
            }
        }
        
        public System.DateTime statusDateTimestamp
        {
            get
            {
                return this._statusDateTimestamp;
            }
            set
            {
                this._statusDateTimestamp = value;
            }
        }
        
        public string consumerName
        {
            get
            {
                return this._consumerName;
            }
            set
            {
                this._consumerName = value;
            }
        }
        
        public string consumerIBAN
        {
            get
            {
                return this._consumerIBAN;
            }
            set
            {
                this._consumerIBAN = value;
            }
        }
        
        public string consumerBIC
        {
            get
            {
                return this._consumerBIC;
            }
            set
            {
                this._consumerBIC = value;
            }
        }
        
        public decimal amount
        {
            get
            {
                return this._amount;
            }
            set
            {
                this._amount = value;
            }
        }
        
        public string currency
        {
            get
            {
                return this._currency;
            }
            set
            {
                this._currency = value;
            }
        }
    }
}