namespace iDealApp.Poco
{

    [System.Diagnostics.DebuggerStepThrough()]
    public partial class AcquirerErrorRes
    {

        #region Private fields
        private System.DateTime _createDateTimestamp;

        private AcquirerErrorResError _error;

        private SignatureType _signature;

        private string _version;
        #endregion

        public AcquirerErrorRes()
        {
            _signature = new SignatureType();
            _error = new AcquirerErrorResError();
        }

        public System.DateTime createDateTimestamp
        {
            get
            {
                return _createDateTimestamp;
            }
            set
            {
                _createDateTimestamp = value;
            }
        }

        public AcquirerErrorResError Error
        {
            get
            {
                return _error;
            }
            set
            {
                _error = value;
            }
        }

        public SignatureType Signature
        {
            get
            {
                return _signature;
            }
            set
            {
                _signature = value;
            }
        }

        public string version
        {
            get
            {
                return _version;
            }
            set
            {
                _version = value;
            }
        }
    }
}