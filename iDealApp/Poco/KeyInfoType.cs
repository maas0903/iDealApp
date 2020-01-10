using System.Collections.Generic;

namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class KeyInfoType
    {
        
        #region Private fields
        private object[] _items;
        
        private ItemsChoiceType2[] _itemsElementName;
        
        private List<string> _text;
        
        private string _id;
        #endregion
        
        public KeyInfoType()
        {
            this._text = new List<string>();
        }
        
        [System.Xml.Serialization.XmlAnyElementAttribute()]
        public object[] Items
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
        
        public ItemsChoiceType2[] ItemsElementName
        {
            get
            {
                return this._itemsElementName;
            }
            set
            {
                this._itemsElementName = value;
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
    }
}