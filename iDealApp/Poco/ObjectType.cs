using System.Collections.Generic;

namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class ObjectType
    {
        
        #region Private fields
        private List<System.Xml.XmlNode> _any;
        
        private string _id;
        
        private string _mimeType;
        
        private string _encoding;
        #endregion
        
        public ObjectType()
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
        
        public string Id
        {
            get
            {
                return this._id;
            }
            set
            {
                this._id = value;
            }
        }
        
        public string MimeType
        {
            get
            {
                return this._mimeType;
            }
            set
            {
                this._mimeType = value;
            }
        }
        
        public string Encoding
        {
            get
            {
                return this._encoding;
            }
            set
            {
                this._encoding = value;
            }
        }
    }
}