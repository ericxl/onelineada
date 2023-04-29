using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AXTest : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        var controlsRenderer = UnityEngine.GameObject.Find("UI/CanvasGameControls").GetComponent<Renderer>();
        Debug.Log(controlsRenderer.ToString());
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
