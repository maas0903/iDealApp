namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class AcquirerTrxReqIssuer
    {
        
        #region Private fields
        private string _issuerID;
        #endregion
        
        public string issuerID
        {
            get
            {
                return this._issuerID;
            }
            set
            {
                this._issuerID = value;
            }
        }
    }
}