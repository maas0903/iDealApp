namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class AcquirerTrxResIssuer
    {
        
        #region Private fields
        private string _issuerAuthenticationURL;
        #endregion
        
        public string issuerAuthenticationURL
        {
            get
            {
                return this._issuerAuthenticationURL;
            }
            set
            {
                this._issuerAuthenticationURL = value;
            }
        }
    }
}