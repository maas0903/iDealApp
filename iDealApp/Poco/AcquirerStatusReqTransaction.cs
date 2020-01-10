namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class AcquirerStatusReqTransaction
    {
        
        #region Private fields
        private string _transactionID;
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
    }
}