using System;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityObjC;

public class AXTest : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        var sr = GetComponent<SpriteRenderer>();
        var sprite = CSharpRuntimeSupportUtilities.safeValueForKey<UnityEngine.Object>(sr, "sprite");
        //var teststripping = sr.sprite;
    }

}
