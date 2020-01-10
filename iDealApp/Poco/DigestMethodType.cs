using System.Collections.Generic;

namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class DigestMethodType
    {
        
        #region Private fields
        private List<System.Xml.XmlNode> _any;
        
        private string _algorithm;
        #endregion
        
        public DigestMethodType()
        {
            this._any = new List<System.Xml.XmlNode>();
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