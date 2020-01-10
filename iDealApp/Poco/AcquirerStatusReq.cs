namespace iDealApp.Poco
{

    [System.Diagnostics.DebuggerStepThrough()]
    public partial class AcquirerStatusReq
    {

        #region Private fields
        private System.DateTime _createDateTimestamp;

        private AcquirerStatusReqMerchant _merchant;

        private AcquirerStatusReqTransaction _transaction;

        private SignatureType _signature;

        private string _version;
        #endregion

        public AcquirerStatusReq()
        {
            _signature = new SignatureType();
            _transaction = new AcquirerStatusReqTransaction();
            _merchant = new AcquirerStatusReqMerchant();
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

        public AcquirerStatusReqMerchant Merchant
        {
            get
            {
                return _merchant;
            }
            set
            {
                _merchant = value;
            }
        }

        public AcquirerStatusReqTransaction Transaction
        {
            get
            {
                return _transaction;
            }
            set
            {
                _transaction = value;
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