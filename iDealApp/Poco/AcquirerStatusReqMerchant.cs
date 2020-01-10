namespace iDealApp.Poco
{

    [System.Diagnostics.DebuggerStepThrough()]
    public partial class AcquirerStatusReqMerchant
    {

        #region Private fields
        private string _merchantID;

        private string _subID;
        #endregion

        public string merchantID
        {
            get
            {
                return _merchantID;
            }
            set
            {
                _merchantID = value;
            }
        }

        public string subID
        {
            get
            {
                return _subID;
            }
            set
            {
                _subID = value;
            }
        }
    }
}