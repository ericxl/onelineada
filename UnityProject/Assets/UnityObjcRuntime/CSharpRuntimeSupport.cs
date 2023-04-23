using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using UnityEngine;

public class CSharpRuntimeSupport
{
    private delegate int _GameAXDelegate_GameObjectFind(string name);
    [DllImport("__Internal")] private static extern void _GameAXRegisterFunc_GameObjectFind(_GameAXDelegate_GameObjectFind func);
    [AOT.MonoPInvokeCallback(typeof(_GameAXDelegate_GameObjectFind))]
    private static int _GameAXImpl_GameObjectFind(string name)
    {
        var gameObject = UnityEngine.GameObject.Find(name);
        return gameObject ? gameObject.GetInstanceID() : -1;
    }

    private delegate string _GameAXDelegate_FindObjectsGetInstanceIDsOfTypeGameObject();
    [DllImport("__Internal")] private static extern void _GameAXRegisterFunc_FindObjectsGetInstanceIDsOfTypeGameObject(_GameAXDelegate_FindObjectsGetInstanceIDsOfTypeGameObject func);
    [AOT.MonoPInvokeCallback(typeof(_GameAXDelegate_FindObjectsGetInstanceIDsOfTypeGameObject))]
    private static string _GameAXImpl_FindObjectsGetInstanceIDsOfTypeGameObject()
    {
        GameObject[] allObjects = UnityEngine.Object.FindObjectsOfType<GameObject>();
        var ids = allObjects.Select(s => s.GetInstanceID().ToString()).ToArray();
        var joined = string.Join(",", ids);
        return "[" + joined + "]";
    }

    private delegate int _GameAXDelegate_GetComponentForObject(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _GameAXRegisterFunc_GetComponentForObject(_GameAXDelegate_GetComponentForObject func);
    [AOT.MonoPInvokeCallback(typeof(_GameAXDelegate_GetComponentForObject))]
    private static int _GameAXImpl_GetComponentForObject(int objectInstanceID, string componentName)
    {
        var obj = FindObjectFromInstanceID(objectInstanceID);
        if (obj == null || obj is not GameObject) return -1;
        
        var type = Type.GetType(componentName);
        if (type == null) return -1;

        var component = (obj as GameObject).GetComponent(type);
        return component ? component.GetInstanceID() : -1;
    }

    private delegate int _GameAXDelegate_AddComponentForObject(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _GameAXRegisterFunc_AddComponentForObject(_GameAXDelegate_GetComponentForObject func);
    [AOT.MonoPInvokeCallback(typeof(_GameAXDelegate_GetComponentForObject))]
    private static int _GameAXImpl_AddComponentForObject(int objectInstanceID, string componentName)
    {
        var obj = FindObjectFromInstanceID(objectInstanceID);
        if (obj == null || obj is not GameObject) return -1;

        var type = Type.GetType(componentName);
        if (type == null) return -1;

        var component = (obj as GameObject).AddComponent(type);
        return component ? component.GetInstanceID() : -1;
    }

    public static UnityEngine.Object FindObjectFromInstanceID(int iid)
    {
        return (UnityEngine.Object)typeof(UnityEngine.Object)
                .GetMethod("FindObjectFromInstanceID", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static)
                .Invoke(null, new object[] { iid });
    }

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
    private static void BeforeSplashScreen()
    {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
        _GameAXRegisterFunc_GameObjectFind(_GameAXImpl_GameObjectFind);
        _GameAXRegisterFunc_FindObjectsGetInstanceIDsOfTypeGameObject(_GameAXImpl_FindObjectsGetInstanceIDsOfTypeGameObject);
        _GameAXRegisterFunc_GetComponentForObject(_GameAXImpl_GetComponentForObject);
        _GameAXRegisterFunc_AddComponentForObject(_GameAXImpl_AddComponentForObject);
#endif
    }
}



