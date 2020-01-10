namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class X509IssuerSerialType
    {
        
        #region Private fields
        private string _x509IssuerName;
        
        private string _x509SerialNumber;
        #endregion
        
        public string X509IssuerName
        {
            get
            {
                return this._x509IssuerName;
            }
            set
            {
                this._x509IssuerName = value;
            }
        }
        
        public string X509SerialNumber
        {
            get
            {
                return this._x509SerialNumber;
            }
            set
            {
                this._x509SerialNumber = value;
            }
        }
    }
}