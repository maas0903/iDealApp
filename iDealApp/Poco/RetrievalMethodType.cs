using System.Collections.Generic;

namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class RetrievalMethodType
    {
        
        #region Private fields
        private List<TransformType> _transforms;
        
        private string _uRI;
        
        private string _type;
        #endregion
        
        public RetrievalMethodType()
        {
            this._transforms = new List<TransformType>();
        }
        
        public List<TransformType> Transforms
        {
            get
            {
                return this._transforms;
            }
            set
            {
                this._transforms = value;
            }
        }
        
        public string URI
        {
            get
            {
                return this._uRI;
            }
            set
            {
                this._uRI = value;
            }
        }
        
        public string Type
        {
            get
            {
                return this._type;
            }
            set
            {
                this._type = value;
            }
        }
    }
}