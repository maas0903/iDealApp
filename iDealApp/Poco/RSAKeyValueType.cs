namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class RSAKeyValueType
    {
        
        #region Private fields
        private byte[] _modulus;
        
        private byte[] _exponent;
        #endregion
        
        public byte[] Modulus
        {
            get
            {
                return this._modulus;
            }
            set
            {
                this._modulus = value;
            }
        }
        
        public byte[] Exponent
        {
            get
            {
                return this._exponent;
            }
            set
            {
                this._exponent = value;
            }
        }
    }
}