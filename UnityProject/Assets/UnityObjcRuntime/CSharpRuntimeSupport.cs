using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using UnityEngine;

static class CSharpRuntimeSupportUtilities
{
    internal static Type GetSafeTypeName(string typeName)
    {
        return Type.GetType(typeName);
    }

    internal static Vector2 ToVector2(this string vectorStr)
    {
        string[] components = vectorStr.Trim(new char[] { '(', ')' }).Split(',');

        // Parse the components as floats
        if (float.TryParse(components[0], out float x) && float.TryParse(components[1], out float y))
        {
            // Create a new Vector2 from the parsed values
            return new Vector2(x, y);
        }
        else
        {
            return Vector2.zero;
        }
    }

    internal static Vector3 ToVector3(this string vectorStr)
    {
        string[] components = vectorStr.Trim(new char[] { '(', ')' }).Split(',');

        // Parse the components as floats
        if (float.TryParse(components[0], out float x) && float.TryParse(components[1], out float y) && float.TryParse(components[2], out float z))
        {
            // Create a new Vector2 from the parsed values
            return new Vector3(x, y, z);
        }
        else
        {
            return Vector2.zero;
        }
    }

    internal static string ToJsonString(this Vector2[] vectors)
    {
        var strings = vectors.Select(v => v.ToString()).ToArray();
        var joined = string.Join(",", strings);
        return "[" + joined + "]";
    }

    internal static string ToJsonString(this Vector3[] vectors)
    {
        var strings = vectors.Select(v => v.ToString()).ToArray();
        var joined = string.Join(",", strings);
        return "[" + joined + "]";
    }

    internal static string InstanceIDsToJsonString(this UnityEngine.Object[] objects)
    {
        var ids = objects.Select(s => s.GetInstanceID().ToString()).ToArray();
        var joined = string.Join(",", ids);
        return "[" + joined + "]";
    }

    internal static UnityEngine.Object FindObjectFromInstanceID(int iid)
    {
        return (UnityEngine.Object)typeof(UnityEngine.Object)
                .GetMethod("FindObjectFromInstanceID", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static)
                .Invoke(null, new object[] { iid });
    }

    internal static void safeVoidForKey(object obj, string methodName)
    {
        var type = obj.GetType();
        var methodInfo = type.GetMethod(methodName, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.GetField);
        if (methodInfo != null && methodInfo.ReturnType == typeof(void))
        {
            methodInfo.Invoke(obj, null);
        }
    }

    internal static T safeValueForKey<T>(object obj, string methodName)
    {
        var type = obj.GetType();
        var methodInfo = type.GetMethod(methodName, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.GetField);
        var propertyInfo = type.GetProperty(methodName, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
        var fieldInfo = type.GetField(methodName);
        var indexerInfo = type.GetProperties().FirstOrDefault(x => x.GetIndexParameters().Select(y => y.ParameterType).SequenceEqual(new[] { typeof(string) }));
        if (methodInfo != null && typeof(T).IsAssignableFrom(methodInfo.ReturnType))
        {
            return (T)methodInfo.Invoke(obj, null);
        }
        else if (propertyInfo != null && propertyInfo.CanRead && typeof(T).IsAssignableFrom(propertyInfo.PropertyType))
        {
            return (T)propertyInfo.GetValue(obj);
        }
        else if (fieldInfo != null && typeof(T).IsAssignableFrom(fieldInfo.FieldType))
        {
            return (T)fieldInfo.GetValue(obj);
        }
        else if (indexerInfo != null && indexerInfo.CanRead && indexerInfo.PropertyType.IsAssignableFrom(typeof(T)))
        {
            return (T)indexerInfo.GetValue(obj, new string[] { methodName });
        }
        return default(T);
    }

    internal static T safeValueForKeyStatic<T>(Type type, string methodName)
    {
        var methodInfo = type.GetMethod(methodName, BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.GetField);
        var propertyInfo = type.GetProperty(methodName, BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public);
        var fieldInfo = type.GetField(methodName, BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public);
        if (methodInfo != null && typeof(T).IsAssignableFrom(methodInfo.ReturnType))
        {
            return (T)methodInfo.Invoke(null, null);
        }
        else if (propertyInfo != null && typeof(T).IsAssignableFrom(propertyInfo.PropertyType))
        {
            return (T)propertyInfo.GetValue(null);
        }
        else if (fieldInfo != null && typeof(T).IsAssignableFrom(fieldInfo.FieldType))
        {
            return (T)fieldInfo.GetValue(null);
        }
        return default(T);
    }

    internal static void safeSetValueForKey<T>(object obj, string methodName, T value)
    {
        var type = obj.GetType();
        var methodInfo = type.GetMethod(methodName, new[] { typeof(T) });
        var propertyInfo = type.GetProperty(methodName, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
        var fieldInfo = type.GetField(methodName);
        var indexerInfo = type.GetProperties().FirstOrDefault(x => x.GetIndexParameters().Select(y => y.ParameterType).SequenceEqual(new[] { typeof(string) }));
        if (methodInfo != null && methodInfo.ReturnType == typeof(void))
        {
            methodInfo.Invoke(obj, new[] { (object)value });
        }
        else if (propertyInfo != null && propertyInfo.CanWrite && typeof(T).IsAssignableFrom(propertyInfo.PropertyType))
        {
            propertyInfo.SetValue(obj, value);
        }
        else if (fieldInfo != null && typeof(T).IsAssignableFrom(fieldInfo.FieldType))
        {
            fieldInfo.SetValue(obj, value);
        }
        else if (indexerInfo != null && indexerInfo.CanWrite && indexerInfo.PropertyType.IsAssignableFrom(typeof(T)))
        {
            indexerInfo.SetValue(obj, value, new string[] { methodName });
        }
    }
}

static class ObjcRuntimeUnityEngineGameObject
{
    private delegate int _CSharpDelegate_UnityEngineGameObjectFind(string name);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineGameObjectFind(_CSharpDelegate_UnityEngineGameObjectFind func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineGameObjectFind))]
    private static int _CSharpImpl_UnityEngineGameObjectFind(string name)
    {
        var gameObject = UnityEngine.GameObject.Find(name);
        return gameObject ? gameObject.GetInstanceID() : 0;
    }

    private delegate int _CSharpDelegate_UnityEngineGameObjectAddComponent(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineGameObjectAddComponent(_CSharpDelegate_UnityEngineGameObjectAddComponent func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineGameObjectAddComponent))]
    private static int _CSharpImpl_UnityEngineGameObjectAddComponent(int objectInstanceID, string componentName)
    {
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
        if (obj == null || obj is not GameObject) return 0;
        var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(componentName);
        if (type == null) return 0;

        var component = (obj as GameObject).AddComponent(type);
        return component ? component.GetInstanceID() : 0;
    }

    private delegate int _CSharpDelegate_UnityEngineGameObjectGetComponent(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineGameObjectGetComponent(_CSharpDelegate_UnityEngineGameObjectGetComponent func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineGameObjectGetComponent))]
    private static int _CSharpImpl_UnityEngineGameObjectGetComponent(int objectInstanceID, string componentName)
    {
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
        if (obj == null || obj is not GameObject) return 0;

        var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(componentName);
        if (type == null) return 0;

        var component = (obj as GameObject).GetComponent(type);
        return component ? component.GetInstanceID() : 0;
    }

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
    private static void SubsystemRegistration()
    {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
        _UEORegisterCSharpFunc_UnityEngineGameObjectFind(_CSharpImpl_UnityEngineGameObjectFind);
        _UEORegisterCSharpFunc_UnityEngineGameObjectAddComponent(_CSharpImpl_UnityEngineGameObjectAddComponent);
        _UEORegisterCSharpFunc_UnityEngineGameObjectGetComponent(_CSharpImpl_UnityEngineGameObjectGetComponent);
#endif
    }
}

static class ObjcRuntimeUnityEngineTransform
{
    private delegate int _CSharpDelegate_UnityEngineTransformFind(int transformInstanceID, string childName);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineTransformFind(_CSharpDelegate_UnityEngineTransformFind func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineTransformFind))]
    private static int _CSharpImpl_UnityEngineTransformFind(int transformInstanceID, string childName)
    {
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(transformInstanceID);
        if (obj == null || obj is not Transform) return 0;

        var child = (obj as Transform).Find(childName);
        return child ? child.GetInstanceID() : 0;
    }

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
    private static void SubsystemRegistration()
    {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
        _UEORegisterCSharpFunc_UnityEngineTransformFind(_CSharpImpl_UnityEngineTransformFind);
#endif
    }
}

static class ObjcRuntimeUnityEngineRectTransform
{
    private delegate string _CSharpDelegate_UnityEngineRectTransformGetWorldCorners(int objectInstanceID);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineRectTransformGetWorldCorners(_CSharpDelegate_UnityEngineRectTransformGetWorldCorners func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineRectTransformGetWorldCorners))]
    private static string _CSharpImpl_UnityEngineRectTransformGetWorldCorners(int objectInstanceID)
    {
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
        if (obj == null || obj is not RectTransform) return null;

        Vector3[] corners = new Vector3[4];
        (obj as RectTransform).GetWorldCorners(corners);
        return corners.ToJsonString();
    }

    private delegate string _CSharpDelegate_UnityEngineRectTransformUtilityWorldToScreenPoint(int cameraInstanceID, string vector3String);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineRectTransformUtilityWorldToScreenPoint(_CSharpDelegate_UnityEngineRectTransformUtilityWorldToScreenPoint func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineRectTransformUtilityWorldToScreenPoint))]
    private static string _CSharpImpl_UnityEngineRectTransformUtilityWorldToScreenPoint(int cameraInstanceID, string vector3String)
    {
        var camera = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(cameraInstanceID);
        if (camera != null && camera is not Camera) return Vector2.zero.ToString();

        return RectTransformUtility.WorldToScreenPoint((Camera)camera, vector3String.ToVector3()).ToString();
    }

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
    private static void SubsystemRegistration()
    {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
        _UEORegisterCSharpFunc_UnityEngineRectTransformGetWorldCorners(_CSharpImpl_UnityEngineRectTransformGetWorldCorners);
        _UEORegisterCSharpFunc_UnityEngineRectTransformUtilityWorldToScreenPoint(_CSharpImpl_UnityEngineRectTransformUtilityWorldToScreenPoint);
#endif
    }
}

static class CSharpRuntimeSupport
{
    private delegate string _CSharpDelegate_UnityEngineObjectTypeFullName(int objectInstanceID);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectTypeFullName(_CSharpDelegate_UnityEngineObjectTypeFullName func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectTypeFullName))]
    private static string _CSharpImpl_UnityEngineObjectTypeFullName(int objectInstanceID)
    {
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
        if (obj == null) return null;

        return obj.GetType().FullName;
    }

    private delegate void _CSharpDelegate_UnityEngineObjectSafeCSharpVoidForKey(int objectInstanceID, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVoidForKey(_CSharpDelegate_UnityEngineObjectSafeCSharpVoidForKey func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpVoidForKey))]
    private static void _CSharpImpl_UnityEngineObjectSafeCSharpVoidForKey(int objectInstanceID, string key)
    {
        if (string.IsNullOrEmpty(key)) return;
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
        if (obj == null) return;

        CSharpRuntimeSupportUtilities.safeVoidForKey(obj, key);
    }

    private delegate bool _CSharpDelegate_UnityEngineObjectSafeCSharpBoolForKey(int objectInstanceID, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpBoolForKey(_CSharpDelegate_UnityEngineObjectSafeCSharpBoolForKey func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpBoolForKey))]
    private static bool _CSharpImpl_UnityEngineObjectSafeCSharpBoolForKey(int objectInstanceID, string key)
    {
        if (string.IsNullOrEmpty(key)) return false;
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
        if (obj == null) return false;

        return CSharpRuntimeSupportUtilities.safeValueForKey<bool>(obj, key);
    }

    private delegate int _CSharpDelegate_UnityEngineObjectSafeCSharpIntForKey(int objectInstanceID, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpIntForKey(_CSharpDelegate_UnityEngineObjectSafeCSharpIntForKey func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpIntForKey))]
    private static int _CSharpImpl_UnityEngineObjectSafeCSharpIntForKey(int objectInstanceID, string key)
    {
        if (string.IsNullOrEmpty(key)) return 0;
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
        if (obj == null) return 0;

        return CSharpRuntimeSupportUtilities.safeValueForKey<int>(obj, key);
    }

    private delegate float _CSharpDelegate_UnityEngineObjectSafeCSharpFloatForKey(int objectInstanceID, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpFloatForKey(_CSharpDelegate_UnityEngineObjectSafeCSharpFloatForKey func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpFloatForKey))]
    private static float _CSharpImpl_UnityEngineObjectSafeCSharpFloatForKey(int objectInstanceID, string key)
    {
        if (string.IsNullOrEmpty(key)) return 0;
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
        if (obj == null) return 0;

        return CSharpRuntimeSupportUtilities.safeValueForKey<float>(obj, key);
    }

    private delegate double _CSharpDelegate_UnityEngineObjectSafeCSharpDoubleForKey(int objectInstanceID, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpDoubleForKey(_CSharpDelegate_UnityEngineObjectSafeCSharpDoubleForKey func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpDoubleForKey))]
    private static double _CSharpImpl_UnityEngineObjectSafeCSharpDoubleForKey(int objectInstanceID, string key)
    {
        if (string.IsNullOrEmpty(key)) return 0;
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
        if (obj == null) return 0;

        return CSharpRuntimeSupportUtilities.safeValueForKey<double>(obj, key);
    }

    private delegate string _CSharpDelegate_UnityEngineObjectSafeCSharpVector3ForKey(int objectInstanceID, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVector3ForKey(_CSharpDelegate_UnityEngineObjectSafeCSharpVector3ForKey func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpVector3ForKey))]
    private static string _CSharpImpl_UnityEngineObjectSafeCSharpVector3ForKey(int objectInstanceID, string key)
    {
        if (string.IsNullOrEmpty(key)) return Vector3.zero.ToString();
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
        if (obj == null) return Vector3.zero.ToString();

        return CSharpRuntimeSupportUtilities.safeValueForKey<Vector3>(obj, key).ToString();
    }

    private delegate string _CSharpDelegate_UnityEngineObjectSafeCSharpStringForKey(int objectInstanceID, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpStringForKey(_CSharpDelegate_UnityEngineObjectSafeCSharpStringForKey func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpStringForKey))]
    private static string _CSharpImpl_UnityEngineObjectSafeCSharpStringForKey(int objectInstanceID, string key)
    {
        if (string.IsNullOrEmpty(key)) return null;
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
        if (obj == null) return null;

        return CSharpRuntimeSupportUtilities.safeValueForKey<string>(obj, key);
    }

    private delegate int _CSharpDelegate_UnityEngineObjectSafeCSharpObjectForKey(int objectInstanceID, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpObjectForKey(_CSharpDelegate_UnityEngineObjectSafeCSharpObjectForKey func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpObjectForKey))]
    private static int _CSharpImpl_UnityEngineObjectSafeCSharpObjectForKey(int objectInstanceID, string key)
    {
        if (string.IsNullOrEmpty(key)) return 0;
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
        if (obj == null) return 0;

        return CSharpRuntimeSupportUtilities.safeValueForKey<UnityEngine.Object>(obj, key)?.GetInstanceID() ?? 0;
    }

    private delegate bool _CSharpDelegate_UnityEngineObjectSafeCSharpBoolForKeyStatic(string typeName, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpBoolForKeyStatic(_CSharpDelegate_UnityEngineObjectSafeCSharpBoolForKeyStatic func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpBoolForKeyStatic))]
    private static bool _CSharpImpl_UnityEngineObjectSafeCSharpBoolForKeyStatic(string typeName, string key)
    {
        if (string.IsNullOrEmpty(key)) return false;
        var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(typeName);
        if (type == null) return false;

        return CSharpRuntimeSupportUtilities.safeValueForKeyStatic<bool>(type, key);
    }

    private delegate int _CSharpDelegate_UnityEngineObjectSafeCSharpIntForKeyStatic(string typeName, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpIntForKeyStatic(_CSharpDelegate_UnityEngineObjectSafeCSharpIntForKeyStatic func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpIntForKeyStatic))]
    private static int _CSharpImpl_UnityEngineObjectSafeCSharpIntForKeyStatic(string typeName, string key)
    {
        if (string.IsNullOrEmpty(key)) return 0;
        var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(typeName);
        if (type == null) return 0;

        return CSharpRuntimeSupportUtilities.safeValueForKeyStatic<int>(type, key);
    }

    private delegate float _CSharpDelegate_UnityEngineObjectSafeCSharpFloatForKeyStatic(string typeName, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpFloatForKeyStatic(_CSharpDelegate_UnityEngineObjectSafeCSharpFloatForKeyStatic func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpFloatForKeyStatic))]
    private static float _CSharpImpl_UnityEngineObjectSafeCSharpFloatForKeyStatic(string typeName, string key)
    {
        if (string.IsNullOrEmpty(key)) return 0;
        var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(typeName);
        if (type == null) return 0;

        return CSharpRuntimeSupportUtilities.safeValueForKeyStatic<float>(type, key);
    }

    private delegate double _CSharpDelegate_UnityEngineObjectSafeCSharpDoubleForKeyStatic(string typeName, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpDoubleForKeyStatic(_CSharpDelegate_UnityEngineObjectSafeCSharpDoubleForKeyStatic func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpDoubleForKeyStatic))]
    private static double _CSharpImpl_UnityEngineObjectSafeCSharpDoubleForKeyStatic(string typeName, string key)
    {
        if (string.IsNullOrEmpty(key)) return 0;
        var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(typeName);
        if (type == null) return 0;

        return CSharpRuntimeSupportUtilities.safeValueForKeyStatic<double>(type, key);
    }

    private delegate string _CSharpDelegate_UnityEngineObjectSafeCSharpVector3ForKeyStatic(string typeName, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVector3ForKeyStatic(_CSharpDelegate_UnityEngineObjectSafeCSharpVector3ForKeyStatic func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpVector3ForKeyStatic))]
    private static string _CSharpImpl_UnityEngineObjectSafeCSharpVector3ForKeyStatic(string typeName, string key)
    {
        if (string.IsNullOrEmpty(key)) return Vector3.zero.ToString();
        var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(typeName);
        if (type == null) return Vector3.zero.ToString();

        return CSharpRuntimeSupportUtilities.safeValueForKeyStatic<Vector3>(type, key).ToString();
    }

    private delegate string _CSharpDelegate_UnityEngineObjectSafeCSharpStringForKeyStatic(string typeName, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpStringForKeyStatic(_CSharpDelegate_UnityEngineObjectSafeCSharpStringForKeyStatic func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpStringForKeyStatic))]
    private static string _CSharpImpl_UnityEngineObjectSafeCSharpStringForKeyStatic(string typeName, string key)
    {
        if (string.IsNullOrEmpty(key)) return null;
        var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(typeName);
        if (type == null) return null;

        return CSharpRuntimeSupportUtilities.safeValueForKeyStatic<string>(type, key);
    }

    private delegate int _CSharpDelegate_UnityEngineObjectSafeCSharpObjectForKeyStatic(string typeName, string key);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpObjectForKeyStatic(_CSharpDelegate_UnityEngineObjectSafeCSharpObjectForKeyStatic func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpObjectForKeyStatic))]
    private static int _CSharpImpl_UnityEngineObjectSafeCSharpObjectForKeyStatic(string typeName, string key)
    {
        if (string.IsNullOrEmpty(key)) return 0;
        var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(typeName);
        if (type == null) return 0;

        return CSharpRuntimeSupportUtilities.safeValueForKeyStatic<UnityEngine.Object>(type, key)?.GetInstanceID() ?? 0;
    }

    private delegate void _CSharpDelegate_UnityEngineObjectSafeSetCSharpFloatForKey(int objectInstanceID, string key, float value);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpFloatForKey(_CSharpDelegate_UnityEngineObjectSafeSetCSharpFloatForKey func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeSetCSharpFloatForKey))]
    private static void _CSharpImpl_UnityEngineObjectSafeSetCSharpFloatForKey(int objectInstanceID, string key, float value)
    {
        if (string.IsNullOrEmpty(key)) return;
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
        if (obj == null) return;

        CSharpRuntimeSupportUtilities.safeSetValueForKey<float>(obj, key, value);
    }

    private delegate void _CSharpDelegate_UnityEngineObjectSafeSetCSharpStringForKey(int objectInstanceID, string key, string value);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpStringForKey(_CSharpDelegate_UnityEngineObjectSafeSetCSharpStringForKey func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeSetCSharpStringForKey))]
    private static void _CSharpImpl_UnityEngineObjectSafeSetCSharpStringForKey(int objectInstanceID, string key, string value)
    {
        if (string.IsNullOrEmpty(key)) return;
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
        if (obj == null) return;

        CSharpRuntimeSupportUtilities.safeSetValueForKey<string>(obj, key, value);
    }

    private delegate string _CSharpDelegate_UnityEngineObjectFindObjectsOfType(string componentName);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectFindObjectsOfType(_CSharpDelegate_UnityEngineObjectFindObjectsOfType func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectFindObjectsOfType))]
    private static string _CSharpImpl_UnityEngineObjectFindObjectsOfType(string componentName)
    {
        var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(componentName);
        if (type == null) return null;

        return UnityEngine.Object.FindObjectsOfType(type).InstanceIDsToJsonString();
    }

    private delegate int _CSharpDelegate_UnityEngineComponentGetComponent(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineComponentGetComponent(_CSharpDelegate_UnityEngineComponentGetComponent func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineComponentGetComponent))]
    private static int _CSharpImpl_UnityEngineComponentGetComponent(int componnetInstanceID, string componentName)
    {
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(componnetInstanceID);
        if (obj == null || obj is not Component) return 0;

        var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(componentName);
        if (type == null) return 0;

        var component = (obj as Component).GetComponent(type);
        return component ? component.GetInstanceID() : 0;
    }

    private delegate string _CSharpDelegate_UnityEngineComponentGetComponents(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineComponentGetComponents(_CSharpDelegate_UnityEngineComponentGetComponents func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineComponentGetComponents))]
    private static string _CSharpImpl_UnityEngineComponentGetComponents(int componnetInstanceID, string componentName)
    {
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(componnetInstanceID);
        if (obj == null || obj is not Component) return null;

        var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(componentName);
        if (type == null) return null;

        return (obj as Component).GetComponents(type).InstanceIDsToJsonString();
    }

    private delegate int _CSharpDelegate_UnityEngineComponentGetComponentInChildren(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineComponentGetComponentInChildren(_CSharpDelegate_UnityEngineComponentGetComponentInChildren func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineComponentGetComponentInChildren))]
    private static int _CSharpImpl_UnityEngineComponentGetComponentInChildren(int componnetInstanceID, string componentName)
    {
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(componnetInstanceID);
        if (obj == null || obj is not Component) return 0;

        var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(componentName);
        if (type == null) return 0;

        var component = (obj as Component).GetComponentInChildren(type);
        return component ? component.GetInstanceID() : 0;
    }

    private delegate string _CSharpDelegate_UnityEngineComponentGetComponentsInChildren(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineComponentGetComponentsInChildren(_CSharpDelegate_UnityEngineComponentGetComponentsInChildren func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineComponentGetComponentsInChildren))]
    private static string _CSharpImpl_UnityEngineComponentGetComponentsInChildren(int componnetInstanceID, string componentName)
    {
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(componnetInstanceID);
        if (obj == null || obj is not Component) return null;

        var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(componentName);
        if (type == null) return null;

        return (obj as Component).GetComponentsInChildren(type).InstanceIDsToJsonString();
    }

    private delegate int _CSharpDelegate_UnityEngineComponentGetComponentInParent(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineComponentGetComponentInParent(_CSharpDelegate_UnityEngineComponentGetComponentInParent func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineComponentGetComponentInParent))]
    private static int _CSharpImpl_UnityEngineComponentGetComponentInParent(int componnetInstanceID, string componentName)
    {
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(componnetInstanceID);
        if (obj == null || obj is not Component) return 0;

        var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(componentName);
        if (type == null) return 0;

        var component = (obj as Component).GetComponentInParent(type);
        return component ? component.GetInstanceID() : 0;
    }

    private delegate string _CSharpDelegate_UnityEngineComponentGetComponentsInParent(int objectInstanceID, string componentName);
    [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineComponentGetComponentsInParent(_CSharpDelegate_UnityEngineComponentGetComponentsInParent func);
    [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineComponentGetComponentsInParent))]
    private static string _CSharpImpl_UnityEngineComponentGetComponentsInParent(int componnetInstanceID, string componentName)
    {
        var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(componnetInstanceID);
        if (obj == null || obj is not Component) return null;

        var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(componentName);
        if (type == null) return null;

        return (obj as Component).GetComponentsInParent(type).InstanceIDsToJsonString();
    }

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
    private static void SubsystemRegistration()
    {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
        _UEORegisterCSharpFunc_UnityEngineObjectTypeFullName(_CSharpImpl_UnityEngineObjectTypeFullName);

        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVoidForKey(_CSharpImpl_UnityEngineObjectSafeCSharpVoidForKey);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpBoolForKey(_CSharpImpl_UnityEngineObjectSafeCSharpBoolForKey);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpIntForKey(_CSharpImpl_UnityEngineObjectSafeCSharpIntForKey);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpFloatForKey(_CSharpImpl_UnityEngineObjectSafeCSharpFloatForKey);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpDoubleForKey(_CSharpImpl_UnityEngineObjectSafeCSharpDoubleForKey);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVector3ForKey(_CSharpImpl_UnityEngineObjectSafeCSharpVector3ForKey);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpStringForKey(_CSharpImpl_UnityEngineObjectSafeCSharpStringForKey);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpObjectForKey(_CSharpImpl_UnityEngineObjectSafeCSharpObjectForKey);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpBoolForKeyStatic(_CSharpImpl_UnityEngineObjectSafeCSharpBoolForKeyStatic);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpIntForKeyStatic(_CSharpImpl_UnityEngineObjectSafeCSharpIntForKeyStatic);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpFloatForKeyStatic(_CSharpImpl_UnityEngineObjectSafeCSharpFloatForKeyStatic);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpDoubleForKeyStatic(_CSharpImpl_UnityEngineObjectSafeCSharpDoubleForKeyStatic);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVector3ForKeyStatic(_CSharpImpl_UnityEngineObjectSafeCSharpVector3ForKeyStatic);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpStringForKeyStatic(_CSharpImpl_UnityEngineObjectSafeCSharpStringForKeyStatic);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpObjectForKeyStatic(_CSharpImpl_UnityEngineObjectSafeCSharpObjectForKeyStatic);

        _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpFloatForKey(_CSharpImpl_UnityEngineObjectSafeSetCSharpFloatForKey);
        _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpStringForKey(_CSharpImpl_UnityEngineObjectSafeSetCSharpStringForKey);

        _UEORegisterCSharpFunc_UnityEngineObjectFindObjectsOfType(_CSharpImpl_UnityEngineObjectFindObjectsOfType);

        _UEORegisterCSharpFunc_UnityEngineComponentGetComponent(_CSharpImpl_UnityEngineComponentGetComponent);
        _UEORegisterCSharpFunc_UnityEngineComponentGetComponents(_CSharpImpl_UnityEngineComponentGetComponents);
        _UEORegisterCSharpFunc_UnityEngineComponentGetComponentInChildren(_CSharpImpl_UnityEngineComponentGetComponentInChildren);
        _UEORegisterCSharpFunc_UnityEngineComponentGetComponentsInChildren(_CSharpImpl_UnityEngineComponentGetComponentsInChildren);
        _UEORegisterCSharpFunc_UnityEngineComponentGetComponentInParent(_CSharpImpl_UnityEngineComponentGetComponentInParent);
        _UEORegisterCSharpFunc_UnityEngineComponentGetComponentsInParent(_CSharpImpl_UnityEngineComponentGetComponentsInParent);
#endif
    }
}
