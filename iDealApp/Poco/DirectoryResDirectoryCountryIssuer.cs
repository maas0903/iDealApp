namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class DirectoryResDirectoryCountryIssuer
    {
        
        #region Private fields
        private string _issuerID;
        
        private string _issuerName;
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
        
        public string issuerName
        {
            get
            {
                return this._issuerName;
            }
            set
            {
                this._issuerName = value;
            }
        }
    }
}