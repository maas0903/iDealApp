using System.Collections.Generic;

namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class SignatureMethodType
    {
        
        #region Private fields
        private string _hMACOutputLength;
        
        private List<System.Xml.XmlNode> _any;
        
        private string _algorithm;
        #endregion
        
        public SignatureMethodType()
        {
            this._any = new List<System.Xml.XmlNode>();
        }
        
        public string HMACOutputLength
        {
            get
            {
                return this._hMACOutputLength;
            }
            set
            {
                this._hMACOutputLength = value;
            }
        }
        
        [System.Xml.Serialization.XmlAnyElementAttribute()]
        public List<System.Xml.XmlNode> Any
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
        
        public string Algorithm
        {
            get
            {
                return this._algorithm;
            }
            set
            {
                this._algorithm = value;
            }
        }
    }
}