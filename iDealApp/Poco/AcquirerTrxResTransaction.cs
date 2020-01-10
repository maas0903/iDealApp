namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class AcquirerTrxResTransaction
    {
        
        #region Private fields
        private string _transactionID;
        
        private System.DateTime _transactionCreateDateTimestamp;
        
        private string _purchaseID;
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
        
        public System.DateTime transactionCreateDateTimestamp
        {
            get
            {
                return this._transactionCreateDateTimestamp;
            }
            set
            {
                this._transactionCreateDateTimestamp = value;
            }
        }
        
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
    }
}