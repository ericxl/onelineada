using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using UnityEngine;

public class CSharpRuntimeSupport
{
    private delegate string _CSharpDelegate_UnityEngineObjectToString(int objectInstanceID);
    [DllImport("__Internal")] private static extern void _CSharpRegisterFunc_UnityEngineObjectToString(_CSharpDelegate_UnityEngineObjectToString func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectToString))]
    private static string _CSharpImpl_UnityEngineObjectToString(int objectInstanceID)
    {
        var obj = FindObjectFromInstanceID(objectInstanceID);
        if (obj == null) return null;

        return obj.ToString();
    }

    private delegate string _CSharpDelegate_UnityEngineObjectTypeFullName(int objectInstanceID);
    [DllImport("__Internal")] private static extern void _CSharpRegisterFunc_UnityEngineObjectTypeFullName(_CSharpDelegate_UnityEngineObjectTypeFullName func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectTypeFullName))]
    private static string _CSharpImpl_UnityEngineObjectTypeFullName(int objectInstanceID)
    {
        var obj = FindObjectFromInstanceID(objectInstanceID);
        if (obj == null) return null;

        return obj.GetType().FullName;
    }

    private delegate string _CSharpDelegate_UnityEngineObjectFindObjectsOfType(string componentName);
    [DllImport("__Internal")] private static extern void _CSharpRegisterFunc_UnityEngineObjectFindObjectsOfType(_CSharpDelegate_UnityEngineObjectFindObjectsOfType func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectFindObjectsOfType))]
    private static string _CSharpImpl_UnityEngineObjectFindObjectsOfType(string componentName)
    {
        var type = Type.GetType(componentName);
        if (type == null) return null;

        var allObjects = UnityEngine.Object.FindObjectsOfType(type);
        var ids = allObjects.Select(s => s.GetInstanceID().ToString()).ToArray();
        var joined = string.Join(",", ids);
        return "[" + joined + "]";
    }

    private delegate int _CSharpDelegate_UnityEngineGameObjectFind(string name);
    [DllImport("__Internal")] private static extern void _CSharpRegisterFunc_UnityEngineGameObjectFind(_CSharpDelegate_UnityEngineGameObjectFind func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineGameObjectFind))]
    private static int _CSharpImpl_UnityEngineGameObjectFind(string name)
    {
        var gameObject = UnityEngine.GameObject.Find(name);
        return gameObject ? gameObject.GetInstanceID() : -1;
    }

    private delegate int _CSharpDelegate_UnityEngineGameObjectAddComponent(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _CSharpRegisterFunc_UnityEngineGameObjectAddComponent(_CSharpDelegate_UnityEngineGameObjectAddComponent func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineGameObjectAddComponent))]
    private static int _CSharpImpl_UnityEngineGameObjectAddComponent(int objectInstanceID, string componentName)
    {
        var obj = FindObjectFromInstanceID(objectInstanceID);
        if (obj == null || obj is not GameObject) return -1;

        var type = Type.GetType(componentName);
        if (type == null) return -1;

        var component = (obj as GameObject).AddComponent(type);
        return component ? component.GetInstanceID() : -1;
    }

    private delegate int _CSharpDelegate_UnityEngineGameObjectGetComponent(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _CSharpRegisterFunc_UnityEngineGameObjectGetComponent(_CSharpDelegate_UnityEngineGameObjectGetComponent func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineGameObjectGetComponent))]
    private static int _CSharpImpl_UnityEngineGameObjectGetComponent(int objectInstanceID, string componentName)
    {
        var obj = FindObjectFromInstanceID(objectInstanceID);
        if (obj == null || obj is not GameObject) return -1;
        
        var type = Type.GetType(componentName);
        if (type == null) return -1;

        var component = (obj as GameObject).GetComponent(type);
        return component ? component.GetInstanceID() : -1;
    }

    private delegate int _CSharpDelegate_UnityEngineComponentGetComponent(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _CSharpRegisterFunc_UnityEngineComponentGetComponent(_CSharpDelegate_UnityEngineComponentGetComponent func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineComponentGetComponent))]
    private static int _CSharpImpl_UnityEngineComponentGetComponent(int componnetInstanceID, string componentName)
    {
        var obj = FindObjectFromInstanceID(componnetInstanceID);
        if (obj == null || obj is not Component) return -1;

        var type = Type.GetType(componentName);
        if (type == null) return -1;

        var component = (obj as Component).GetComponent(type);
        return component ? component.GetInstanceID() : -1;
    }

    private static UnityEngine.Object FindObjectFromInstanceID(int iid)
    {
        return (UnityEngine.Object)typeof(UnityEngine.Object)
                .GetMethod("FindObjectFromInstanceID", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static)
                .Invoke(null, new object[] { iid });
    }

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
    private static void BeforeSplashScreen()
    {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
        _CSharpRegisterFunc_UnityEngineObjectToString(_CSharpImpl_UnityEngineObjectToString);
        _CSharpRegisterFunc_UnityEngineObjectTypeFullName(_CSharpImpl_UnityEngineObjectTypeFullName);
        _CSharpRegisterFunc_UnityEngineObjectFindObjectsOfType(_CSharpImpl_UnityEngineObjectFindObjectsOfType);
        _CSharpRegisterFunc_UnityEngineGameObjectFind(_CSharpImpl_UnityEngineGameObjectFind);
        _CSharpRegisterFunc_UnityEngineGameObjectAddComponent(_CSharpImpl_UnityEngineGameObjectAddComponent);
        _CSharpRegisterFunc_UnityEngineGameObjectGetComponent(_CSharpImpl_UnityEngineGameObjectGetComponent);
        _CSharpRegisterFunc_UnityEngineComponentGetComponent(_CSharpImpl_UnityEngineComponentGetComponent);
#endif
    }
}
