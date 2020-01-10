namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class DirectoryRes
    {
        
        #region Private fields
        private System.DateTime _createDateTimestamp;
        
        private DirectoryResAcquirer _acquirer;
        
        private DirectoryResDirectory _directory;
        
        private SignatureType _signature;
        
        private string _version;
        #endregion
        
        public DirectoryRes()
        {
            this._signature = new SignatureType();
            this._directory = new DirectoryResDirectory();
            this._acquirer = new DirectoryResAcquirer();
        }
        
        public System.DateTime createDateTimestamp
        {
            get
            {
                return this._createDateTimestamp;
            }
            set
            {
                this._createDateTimestamp = value;
            }
        }
        
        public DirectoryResAcquirer Acquirer
        {
            get
            {
                return this._acquirer;
            }
            set
            {
                this._acquirer = value;
            }
        }
        
        public DirectoryResDirectory Directory
        {
            get
            {
                return this._directory;
            }
            set
            {
                this._directory = value;
            }
        }
        
        public SignatureType Signature
        {
            get
            {
                return this._signature;
            }
            set
            {
                this._signature = value;
            }
        }
        
        public string version
        {
            get
            {
                return this._version;
            }
            set
            {
                this._version = value;
            }
        }
    }
}