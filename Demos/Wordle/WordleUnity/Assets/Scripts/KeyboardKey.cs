using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using TMPro;

public static class iOSInput
{
    internal static string pressedKey = null;
    public static bool GetKeyDown(KeyCode keyCode)
    {
        if (pressedKey == null) return false;
        if (keyCode == KeyCode.A && pressedKey == "A") return true;
        if (keyCode == KeyCode.B && pressedKey == "B") return true;
        if (keyCode == KeyCode.C && pressedKey == "C") return true;
        if (keyCode == KeyCode.D && pressedKey == "D") return true;
        if (keyCode == KeyCode.E && pressedKey == "E") return true;
        if (keyCode == KeyCode.F && pressedKey == "F") return true;
        if (keyCode == KeyCode.G && pressedKey == "G") return true;
        if (keyCode == KeyCode.H && pressedKey == "H") return true;
        if (keyCode == KeyCode.I && pressedKey == "I") return true;
        if (keyCode == KeyCode.J && pressedKey == "J") return true;
        if (keyCode == KeyCode.K && pressedKey == "K") return true;
        if (keyCode == KeyCode.L && pressedKey == "L") return true;
        if (keyCode == KeyCode.M && pressedKey == "M") return true;
        if (keyCode == KeyCode.N && pressedKey == "N") return true;
        if (keyCode == KeyCode.O && pressedKey == "O") return true;
        if (keyCode == KeyCode.P && pressedKey == "P") return true;
        if (keyCode == KeyCode.Q && pressedKey == "Q") return true;
        if (keyCode == KeyCode.R && pressedKey == "R") return true;
        if (keyCode == KeyCode.S && pressedKey == "S") return true;
        if (keyCode == KeyCode.T && pressedKey == "T") return true;
        if (keyCode == KeyCode.U && pressedKey == "U") return true;
        if (keyCode == KeyCode.V && pressedKey == "V") return true;
        if (keyCode == KeyCode.W && pressedKey == "W") return true;
        if (keyCode == KeyCode.X && pressedKey == "X") return true;
        if (keyCode == KeyCode.Y && pressedKey == "Y") return true;
        if (keyCode == KeyCode.Z && pressedKey == "Z") return true;
        if (keyCode == KeyCode.Return && pressedKey == "SUBMIT") return true;
        if (keyCode == KeyCode.Backspace && pressedKey == "BACKSPACE") return true;
        return false;
    }
}

[DefaultExecutionOrder(-100)]
public class KeyboardKey : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        GetComponent<Button>().onClick.AddListener(() => {
            iOSInput.pressedKey = GetLetter();
        });

        //FontStyle s = GetComponent<Text>().fontStyle;
        //if (GetComponentInChildren<TextMeshProUGUI>() != null)
        //    UnityObjC.CSharpRuntimeSupportUtilities.safeSetValueForKey<int>(GetComponentInChildren<TextMeshProUGUI>(), "fontStyle", 1);
        //Color s1 = GetComponent<UnityEngine.UI.Outline>();
        //GetComponentInChildren<Image>().color = TextStyl
    }
    private void LateUpdate()
    {
        iOSInput.pressedKey = null;
    }

    string GetLetter()
    {
        var text = GetComponentInChildren<TextMeshProUGUI>();
        if (text != null)
        {
            return text.text;
        }
        var image = GetComponentInChildren<Image>();
        if (image != null)
        {
            return "BACKSPACE";
        }
        return null;
    }

}
