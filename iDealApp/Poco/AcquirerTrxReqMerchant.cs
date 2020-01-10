namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class AcquirerTrxReqMerchant
    {
        
        #region Private fields
        private string _merchantID;
        
        private string _subID;
        
        private string _merchantReturnURL;
        #endregion
        
        public string merchantID
        {
            get
            {
                return this._merchantID;
            }
            set
            {
                this._merchantID = value;
            }
        }
        
        public string subID
        {
            get
            {
                return this._subID;
            }
            set
            {
                this._subID = value;
            }
        }
        
        public string merchantReturnURL
        {
            get
            {
                return this._merchantReturnURL;
            }
            set
            {
                this._merchantReturnURL = value;
            }
        }
    }
}