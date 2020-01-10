namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class SPKIDataType
    {
        
        #region Private fields
        private byte[][] _sPKISexp;
        
        private System.Xml.XmlElement _any;
        #endregion
        
        public byte[][] SPKISexp
        {
            get
            {
                return this._sPKISexp;
            }
            set
            {
                this._sPKISexp = value;
            }
        }
        
        [System.Xml.Serialization.XmlAnyElementAttribute()]
        public System.Xml.XmlElement Any
        {
            get
            {
                return this._any;
            }
            set
            {
                this._any = value;
            }
        }
    }
}