using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Apple.Accessibility
{
    public class UnityAccessibilityNode : MonoBehaviour
    {
        public string ClassName;

        Vector3 nodePosition => transform.position;
    }
}

