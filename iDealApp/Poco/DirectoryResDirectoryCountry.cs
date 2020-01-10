using System.Collections.Generic;

namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class DirectoryResDirectoryCountry
    {
        
        #region Private fields
        private string _countryNames;
        
        private List<DirectoryResDirectoryCountryIssuer> _issuer;
        #endregion
        
        public DirectoryResDirectoryCountry()
        {
            this._issuer = new List<DirectoryResDirectoryCountryIssuer>();
        }
        
        public string countryNames
        {
            get
            {
                return this._countryNames;
            }
            set
            {
                this._countryNames = value;
            }
        }
        
        public List<DirectoryResDirectoryCountryIssuer> Issuer
        {
            get
            {
                return this._issuer;
            }
            set
            {
                this._issuer = value;
            }
        }
    }
}