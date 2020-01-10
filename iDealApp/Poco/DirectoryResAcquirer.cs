namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class DirectoryResAcquirer
    {
        
        #region Private fields
        private string _acquirerID;
        #endregion
        
        public string acquirerID
        {
            get
            {
                return this._acquirerID;
            }
            set
            {
                this._acquirerID = value;
            }
        }
    }
}