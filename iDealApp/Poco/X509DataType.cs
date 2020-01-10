namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class X509DataType
    {
        
        #region Private fields
        private object[] _items;
        
        private ItemsChoiceType[] _itemsElementName;
        #endregion
        
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
        
        public ItemsChoiceType[] ItemsElementName
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
    }
}