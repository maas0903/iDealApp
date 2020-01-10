namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class DirectoryReqMerchant
    {
        
        #region Private fields
        private string _merchantID;
        
        private string _subID;
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
    }
}