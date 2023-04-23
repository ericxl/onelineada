using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Apple.Accessibility;

public class AccessibleScript : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        var objects = FindObjectsOfType<GameObject>();
        foreach (var obj in objects)
        {
            if (obj.GetComponent<Button>() != null)
            {
                var buttonID = obj.GetComponent<Button>().GetInstanceID();
                var button = CSharpRuntimeSupport.FindObjectFromInstanceID(buttonID);
                Debug.Log(buttonID);
                Debug.Log(button);
                Debug.Log(obj.GetInstanceID()) ;
                obj.AddComponent<AccessibilityNode>();
            }
        }
    }
}
