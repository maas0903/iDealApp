using System.Collections.Generic;

namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class KeyValueType
    {
        
        #region Private fields
        private object _item;
        
        private List<string> _text;
        #endregion
        
        public KeyValueType()
        {
            this._text = new List<string>();
        }
        
        [System.Xml.Serialization.XmlAnyElementAttribute()]
        public object Item
        {
            get
            {
                return this._item;
            }
            set
            {
                this._item = value;
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
    }
}