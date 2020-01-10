using System.Collections.Generic;

namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class SignedInfoType
    {
        
        #region Private fields
        private CanonicalizationMethodType _canonicalizationMethod;
        
        private SignatureMethodType _signatureMethod;
        
        private List<ReferenceType> _reference;
        
        private string _id;
        #endregion
        
        public SignedInfoType()
        {
            this._reference = new List<ReferenceType>();
            this._signatureMethod = new SignatureMethodType();
            this._canonicalizationMethod = new CanonicalizationMethodType();
        }
        
        public CanonicalizationMethodType CanonicalizationMethod
        {
            get
            {
                return this._canonicalizationMethod;
            }
            set
            {
                this._canonicalizationMethod = value;
            }
        }
        
        public SignatureMethodType SignatureMethod
        {
            get
            {
                return this._signatureMethod;
            }
            set
            {
                this._signatureMethod = value;
            }
        }
        
        public List<ReferenceType> Reference
        {
            get
            {
                return this._reference;
            }
            set
            {
                this._reference = value;
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