using System.Collections.Generic;

namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class ReferenceType
    {
        
        #region Private fields
        private List<TransformType> _transforms;
        
        private DigestMethodType _digestMethod;
        
        private byte[] _digestValue;
        
        private string _id;
        
        private string _uRI;
        
        private string _type;
        #endregion
        
        public ReferenceType()
        {
            this._digestMethod = new DigestMethodType();
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
        
        public DigestMethodType DigestMethod
        {
            get
            {
                return this._digestMethod;
            }
            set
            {
                this._digestMethod = value;
            }
        }
        
        public byte[] DigestValue
        {
            get
            {
                return this._digestValue;
            }
            set
            {
                this._digestValue = value;
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