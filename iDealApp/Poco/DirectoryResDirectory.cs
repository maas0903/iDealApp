using System.Collections.Generic;

namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class DirectoryResDirectory
    {
        
        #region Private fields
        private System.DateTime _directoryDateTimestamp;
        
        private List<DirectoryResDirectoryCountry> _country;
        #endregion
        
        public DirectoryResDirectory()
        {
            this._country = new List<DirectoryResDirectoryCountry>();
        }
        
        public System.DateTime directoryDateTimestamp
        {
            get
            {
                return this._directoryDateTimestamp;
            }
            set
            {
                this._directoryDateTimestamp = value;
            }
        }
        
        public List<DirectoryResDirectoryCountry> Country
        {
            get
            {
                return this._country;
            }
            set
            {
                this._country = value;
            }
        }
    }
}