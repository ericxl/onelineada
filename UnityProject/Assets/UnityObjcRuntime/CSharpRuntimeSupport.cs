using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using UnityEngine;

public static class CSharpRuntimeSupport
{
    private delegate string _CSharpDelegate_UnityEngineObjectTypeFullName(int objectInstanceID);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectTypeFullName(_CSharpDelegate_UnityEngineObjectTypeFullName func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectTypeFullName))]
    private static string _CSharpImpl_UnityEngineObjectTypeFullName(int objectInstanceID)
    {
        var obj = FindObjectFromInstanceID(objectInstanceID);
        if (obj == null) return null;

        return obj.GetType().FullName;
    }

    private delegate bool _CSharpDelegate_UnityEngineObjectSafeCSharpBoolForKey(int objectInstanceID, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpBoolForKey(_CSharpDelegate_UnityEngineObjectSafeCSharpBoolForKey func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpBoolForKey))]
    private static bool _CSharpImpl_UnityEngineObjectSafeCSharpBoolForKey(int objectInstanceID, string key)
    {
        if (string.IsNullOrEmpty(key)) return false;
        var obj = FindObjectFromInstanceID(objectInstanceID);
        if (obj == null) return false;

        return safeValueForKey<bool>(obj, key);
    }

    private delegate int _CSharpDelegate_UnityEngineObjectSafeCSharpIntForKey(int objectInstanceID, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpIntForKey(_CSharpDelegate_UnityEngineObjectSafeCSharpIntForKey func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpIntForKey))]
    private static int _CSharpImpl_UnityEngineObjectSafeCSharpIntForKey(int objectInstanceID, string key)
    {
        if (string.IsNullOrEmpty(key)) return 0;
        var obj = FindObjectFromInstanceID(objectInstanceID);
        if (obj == null) return 0;

        return safeValueForKey<int>(obj, key);
    }

    private delegate string _CSharpDelegate_UnityEngineObjectSafeCSharpStringForKey(int objectInstanceID, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpStringForKey(_CSharpDelegate_UnityEngineObjectSafeCSharpStringForKey func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpStringForKey))]
    private static string _CSharpImpl_UnityEngineObjectSafeCSharpStringForKey(int objectInstanceID, string key)
    {
        if (string.IsNullOrEmpty(key)) return null;
        var obj = FindObjectFromInstanceID(objectInstanceID);
        if (obj == null) return null;

        return safeValueForKey<string>(obj, key);
    }

    private delegate int _CSharpDelegate_UnityEngineObjectSafeCSharpObjectForKey(int objectInstanceID, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpObjectForKey(_CSharpDelegate_UnityEngineObjectSafeCSharpObjectForKey func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpObjectForKey))]
    private static int _CSharpImpl_UnityEngineObjectSafeCSharpObjectForKey(int objectInstanceID, string key)
    {
        if (string.IsNullOrEmpty(key)) return -1;
        var obj = FindObjectFromInstanceID(objectInstanceID);
        if (obj == null) return -1;

        return safeValueForKey<UnityEngine.Object>(obj, key)?.GetInstanceID() ?? 0;
    }

    public static T safeValueForKey<T>(object obj, string methodName)
    {
        var type = obj.GetType();
        var mi = type.GetMethod(methodName, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.GetField);
        if (mi != null && typeof(T).IsAssignableFrom(mi.ReturnType))
        {
            return (T)mi.Invoke(obj, null);
        }
        var pi = type.GetProperty(methodName, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
        if (pi != null && typeof(T).IsAssignableFrom(pi.PropertyType))
        {
            return (T)pi.GetValue(obj);
        }
        return default(T);
    }


    private delegate string _CSharpDelegate_UnityEngineObjectFindObjectsOfType(string componentName);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectFindObjectsOfType(_CSharpDelegate_UnityEngineObjectFindObjectsOfType func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectFindObjectsOfType))]
    private static string _CSharpImpl_UnityEngineObjectFindObjectsOfType(string componentName)
    {
        var type = Type.GetType(componentName);
        if (type == null) return null;

        return UnityEngine.Object.FindObjectsOfType(type).InstanceIDsToJsonString();
    }

    private delegate int _CSharpDelegate_UnityEngineGameObjectFind(string name);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineGameObjectFind(_CSharpDelegate_UnityEngineGameObjectFind func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineGameObjectFind))]
    private static int _CSharpImpl_UnityEngineGameObjectFind(string name)
    {
        var gameObject = UnityEngine.GameObject.Find(name);
        return gameObject ? gameObject.GetInstanceID() : -1;
    }

    private delegate int _CSharpDelegate_UnityEngineGameObjectAddComponent(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineGameObjectAddComponent(_CSharpDelegate_UnityEngineGameObjectAddComponent func);
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
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineGameObjectGetComponent(_CSharpDelegate_UnityEngineGameObjectGetComponent func);
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
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineComponentGetComponent(_CSharpDelegate_UnityEngineComponentGetComponent func);
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

    private delegate string _CSharpDelegate_UnityEngineComponentGetComponents(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineComponentGetComponents(_CSharpDelegate_UnityEngineComponentGetComponents func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineComponentGetComponents))]
    private static string _CSharpImpl_UnityEngineComponentGetComponents(int componnetInstanceID, string componentName)
    {
        var obj = FindObjectFromInstanceID(componnetInstanceID);
        if (obj == null || obj is not Component) return null;

        var type = Type.GetType(componentName);
        if (type == null) return null;

        return (obj as Component).GetComponents(type).InstanceIDsToJsonString();
    }

    private delegate int _CSharpDelegate_UnityEngineComponentGetComponentInChildren(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineComponentGetComponentInChildren(_CSharpDelegate_UnityEngineComponentGetComponentInChildren func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineComponentGetComponentInChildren))]
    private static int _CSharpImpl_UnityEngineComponentGetComponentInChildren(int componnetInstanceID, string componentName)
    {
        var obj = FindObjectFromInstanceID(componnetInstanceID);
        if (obj == null || obj is not Component) return -1;

        var type = Type.GetType(componentName);
        if (type == null) return -1;

        var component = (obj as Component).GetComponentInChildren(type);
        return component ? component.GetInstanceID() : -1;
    }

    private delegate string _CSharpDelegate_UnityEngineComponentGetComponentsInChildren(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineComponentGetComponentsInChildren(_CSharpDelegate_UnityEngineComponentGetComponentsInChildren func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineComponentGetComponentsInChildren))]
    private static string _CSharpImpl_UnityEngineComponentGetComponentsInChildren(int componnetInstanceID, string componentName)
    {
        var obj = FindObjectFromInstanceID(componnetInstanceID);
        if (obj == null || obj is not Component) return null;

        var type = Type.GetType(componentName);
        if (type == null) return null;

        return (obj as Component).GetComponentsInChildren(type).InstanceIDsToJsonString();
    }

    private delegate int _CSharpDelegate_UnityEngineComponentGetComponentInParent(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineComponentGetComponentInParent(_CSharpDelegate_UnityEngineComponentGetComponentInParent func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineComponentGetComponentInParent))]
    private static int _CSharpImpl_UnityEngineComponentGetComponentInParent(int componnetInstanceID, string componentName)
    {
        var obj = FindObjectFromInstanceID(componnetInstanceID);
        if (obj == null || obj is not Component) return -1;

        var type = Type.GetType(componentName);
        if (type == null) return -1;

        var component = (obj as Component).GetComponentInParent(type);
        return component ? component.GetInstanceID() : -1;
    }

    private delegate string _CSharpDelegate_UnityEngineComponentGetComponentsInParent(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineComponentGetComponentsInParent(_CSharpDelegate_UnityEngineComponentGetComponentsInParent func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineComponentGetComponentsInParent))]
    private static string _CSharpImpl_UnityEngineComponentGetComponentsInParent(int componnetInstanceID, string componentName)
    {
        var obj = FindObjectFromInstanceID(componnetInstanceID);
        if (obj == null || obj is not Component) return null;

        var type = Type.GetType(componentName);
        if (type == null) return null;

        return (obj as Component).GetComponentsInParent(type).InstanceIDsToJsonString();
    }

    private static string InstanceIDsToJsonString(this UnityEngine.Object[] objects)
    {
        var ids = objects.Select(s => s.GetInstanceID().ToString()).ToArray();
        var joined = string.Join(",", ids);
        return "[" + joined + "]";
    }

    private static UnityEngine.Object FindObjectFromInstanceID(int iid)
    {
        return (UnityEngine.Object)typeof(UnityEngine.Object)
                .GetMethod("FindObjectFromInstanceID", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static)
                .Invoke(null, new object[] { iid });
    }

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
    private static void SubsystemRegistration()
    {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
        _UEORegisterCSharpFunc_UnityEngineObjectTypeFullName(_CSharpImpl_UnityEngineObjectTypeFullName);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpBoolForKey(_CSharpImpl_UnityEngineObjectSafeCSharpBoolForKey);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpIntForKey(_CSharpImpl_UnityEngineObjectSafeCSharpIntForKey);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpStringForKey(_CSharpImpl_UnityEngineObjectSafeCSharpStringForKey);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpObjectForKey(_CSharpImpl_UnityEngineObjectSafeCSharpObjectForKey);
        _UEORegisterCSharpFunc_UnityEngineObjectFindObjectsOfType(_CSharpImpl_UnityEngineObjectFindObjectsOfType);
        _UEORegisterCSharpFunc_UnityEngineGameObjectFind(_CSharpImpl_UnityEngineGameObjectFind);
        _UEORegisterCSharpFunc_UnityEngineGameObjectAddComponent(_CSharpImpl_UnityEngineGameObjectAddComponent);
        _UEORegisterCSharpFunc_UnityEngineGameObjectGetComponent(_CSharpImpl_UnityEngineGameObjectGetComponent);
        _UEORegisterCSharpFunc_UnityEngineComponentGetComponent(_CSharpImpl_UnityEngineComponentGetComponent);
        _UEORegisterCSharpFunc_UnityEngineComponentGetComponents(_CSharpImpl_UnityEngineComponentGetComponents);
        _UEORegisterCSharpFunc_UnityEngineComponentGetComponentInChildren(_CSharpImpl_UnityEngineComponentGetComponentInChildren);
        _UEORegisterCSharpFunc_UnityEngineComponentGetComponentsInChildren(_CSharpImpl_UnityEngineComponentGetComponentsInChildren);
        _UEORegisterCSharpFunc_UnityEngineComponentGetComponentInParent(_CSharpImpl_UnityEngineComponentGetComponentInParent);
        _UEORegisterCSharpFunc_UnityEngineComponentGetComponentsInParent(_CSharpImpl_UnityEngineComponentGetComponentsInParent);
#endif
    }
}
