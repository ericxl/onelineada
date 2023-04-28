using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityObjC;
using Solitaire.Presenters;

public class AXTest : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        var card = Object.FindObjectOfType<SpriteRenderer>().sprite;
        Debug.Log(Rect.zero.ToString());
        //var pos = card.transform.localScale = Vector3.zero;
    }
}
