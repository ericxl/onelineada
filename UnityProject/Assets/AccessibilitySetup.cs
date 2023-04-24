using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Apple.Accessibility;

public class AccessibilitySetup : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        var testObject = GameObject.Find("/HUD Canvas/Version Text");
        int instanceID = testObject.GetInstanceID();
        Debug.Log(testObject.GetType().FullName);
        //Debug.Log(GameObject.Find("/HUD Canvas/Version Text").ToString());
        //GameObject.Find("/HUD Canvas/Version Text").AddComponent<AccessibilityNode>();
        //GameObject.Find("/HUD Canvas/Bottom Pane/Progress Display/Days Survived Label").AddComponent<AccessibilityNode>();
        //GameObject.Find("/HUD Canvas/Bottom Pane/Progress Display/Days Survived Text").AddComponent<AccessibilityNode>();
        //GameObject.Find("/HUD Canvas/Top Pane/Stats Display/Coal Bar Group").AddComponent<AccessibilityNode>();
        //GameObject.Find("/HUD Canvas/Top Pane/Stats Display/Food Bar Group").AddComponent<AccessibilityNode>();
        //GameObject.Find("/HUD Canvas/Top Pane/Stats Display/Health Bar Group").AddComponent<AccessibilityNode>();
        //GameObject.Find("/HUD Canvas/Top Pane/Stats Display/Hope Bar Group").AddComponent<AccessibilityNode>();
        //GameObject.Find("/In-world Canvas/Card Description Display/Card Text").AddComponent<AccessibilityNode>();
        //GameObject.Find("/In-world Canvas/Card Description Display/Character Name Text").AddComponent<AccessibilityNode>();
    }
    private void Update()
    {
        //if (GameObject.Find("/Card(Clone)")!= null)
        //{
        //    if (GameObject.Find("/Card(Clone)").GetComponent<AccessibilityNode>() == null)
        //    {
        //        GameObject.Find("/Card(Clone)").AddComponent<AccessibilityNode>();
        //    }
        //}
        
        //var versionText = GameObject.Find("Version Text");
        //if (versionText != null)
        //{
        //    var axNode = versionText.GetComponent<AccessibilityNode>();
        //    var frame = axNode._accessibilityFrame();
        //    Debug.Log("frame is" + frame);
        //}
    }
}
