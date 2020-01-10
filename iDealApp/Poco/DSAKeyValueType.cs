namespace iDealApp.Poco
{
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public partial class DSAKeyValueType
    {
        
        #region Private fields
        private byte[] _p;
        
        private byte[] _q;
        
        private byte[] _g;
        
        private byte[] _y;
        
        private byte[] _j;
        
        private byte[] _seed;
        
        private byte[] _pgenCounter;
        #endregion
        
        public byte[] P
        {
            get
            {
                return this._p;
            }
            set
            {
                this._p = value;
            }
        }
        
        public byte[] Q
        {
            get
            {
                return this._q;
            }
            set
            {
                this._q = value;
            }
        }
        
        public byte[] G
        {
            get
            {
                return this._g;
            }
            set
            {
                this._g = value;
            }
        }
        
        public byte[] Y
        {
            get
            {
                return this._y;
            }
            set
            {
                this._y = value;
            }
        }
        
        public byte[] J
        {
            get
            {
                return this._j;
            }
            set
            {
                this._j = value;
            }
        }
        
        public byte[] Seed
        {
            get
            {
                return this._seed;
            }
            set
            {
                this._seed = value;
            }
        }
        
        public byte[] PgenCounter
        {
            get
            {
                return this._pgenCounter;
            }
            set
            {
                this._pgenCounter = value;
            }
        }
    }
}