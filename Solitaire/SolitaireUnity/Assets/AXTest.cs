using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityObjCRuntime;
using Solitaire.Presenters;

public class AXTest : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        var card = Object.FindObjectOfType<CardPresenter>();
        var pos = card.transform.position;
    }
}
