using System.Collections.Generic;

namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class TransformType
    {
        
        #region Private fields
        private List<object> _items;
        
        private List<string> _text;
        
        private string _algorithm;
        #endregion
        
        public TransformType()
        {
            this._text = new List<string>();
            this._items = new List<object>();
        }
        
        [System.Xml.Serialization.XmlAnyElementAttribute()]
        public List<object> Items
        {
            get
            {
                return this._items;
            }
            set
            {
                this._items = value;
            }
        }
        
        public List<string> Text
        {
            get
            {
                return this._text;
            }
            set
            {
                this._text = value;
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