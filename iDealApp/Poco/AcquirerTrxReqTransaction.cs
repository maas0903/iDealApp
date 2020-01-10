namespace iDealApp.Poco
{
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class AcquirerTrxReqTransaction
    
    {
        
        #region Private fields
        private string _purchaseID;
        
        private decimal _amount;
        
        private string _currency;
        
        private string _expirationPeriod;
        
        private string _language;
        
        private string _description;
        
        private string _entranceCode;
        #endregion
        
        public string purchaseID
        {
            get
            {
                return this._purchaseID;
            }
            set
            {
                this._purchaseID = value;
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
        
        public string expirationPeriod
        {
            get
            {
                return this._expirationPeriod;
            }
            set
            {
                this._expirationPeriod = value;
            }
        }
        
        public string language
        {
            get
            {
                return this._language;
            }
            set
            {
                this._language = value;
            }
        }
        
        public string description
        {
            get
            {
                return this._description;
            }
            set
            {
                this._description = value;
            }
        }
        
        public string entranceCode
        {
            get
            {
                return this._entranceCode;
            }
            set
            {
                this._entranceCode = value;
            }
        }
    }
}