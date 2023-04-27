using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UnityObjCRuntime
{
    public class UnityObjCRuntimeBehaviour : MonoBehaviour
    {
        Dictionary<string, object> properties = new Dictionary<string, object>();

        public object this[string name]
        {
            get
            {
                if (properties.ContainsKey(name))
                {
                    return properties[name];
                }
                return null;
            }
            set
            {
                properties[name] = value;
            }
        }
    }
}


