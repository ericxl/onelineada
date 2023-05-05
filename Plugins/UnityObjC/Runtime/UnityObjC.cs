using System;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using UnityEngine;

namespace UnityObjC
{
    [StructLayout(LayoutKind.Sequential)]
    internal struct NativeVector2
    {
        internal float x;
        internal float y;
    }
    [StructLayout(LayoutKind.Sequential)]
    internal struct NativeVector3
    {
        internal float x;
        internal float y;
        internal float z;
    }
    [StructLayout(LayoutKind.Sequential)]
    internal struct NativeVector4
    {
        internal float x;
        internal float y;
        internal float z;
        internal float w;
    }
    [StructLayout(LayoutKind.Sequential)]
    internal struct NativeRect
    {
        internal float x;
        internal float y;
        internal float width;
        internal float height;
    }
    [StructLayout(LayoutKind.Sequential)]
    internal struct NativeColor
    {
        internal float r;
        internal float g;
        internal float b;
        internal float a;
    }
    public static class CSharpRuntimeSupportUtilities
    {
        internal static Vector2 ToCSharp(this NativeVector2 value)
        {
            return new Vector2(value.x, value.y);
        }
        internal static NativeVector2 ToNative(this Vector2 value)
        {
            return new NativeVector2 { x = value.x, y = value.y };
        }

        internal static Vector3 ToCSharp(this NativeVector3 value)
        {
            return new Vector3(value.x, value.y, value.z);
        }
        internal static NativeVector3 ToNative(this Vector3 value)
        {
            return new NativeVector3 { x = value.x, y = value.y, z = value.z };
        }

        internal static Vector4 ToCSharp(this NativeVector4 value)
        {
            return new Vector4(value.x, value.y);
        }
        internal static NativeVector4 ToNative(this Vector4 value)
        {
            return new NativeVector4 { x = value.x, y = value.y, z = value.z, w = value.w };
        }

        internal static Rect ToCSharp(this NativeRect value)
        {
            return new Rect(value.x, value.y, value.width, value.height);
        }
        internal static NativeRect ToNative(this Rect value)
        {
            return new NativeRect { x = value.x, y = value.y, width = value.width, height = value.height };
        }

        internal static Color ToCSharp(this NativeColor value)
        {
            return new Color(value.r, value.g, value.b, value.a);
        }
        internal static NativeColor ToNative(this Color value)
        {
            return new NativeColor { r = value.r, g = value.g, b = value.b, a = value.a };
        }

        internal static Type GetSafeTypeName(string typeName)
        {
            var type = Type.GetType(typeName);
            if (type != null) return type;
            foreach (var a in AppDomain.CurrentDomain.GetAssemblies())
            {
                type = a.GetType(typeName);
                if (type != null)
                    return type;
            }
            return null;
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

        internal static void PrintProperties(object obj)
        {
            if (obj == null) return;

            Type objType = obj.GetType();
            PropertyInfo[] properties = objType.GetProperties();

            Debug.Log($"Properties of object {objType.Name}:");
            foreach (PropertyInfo property in properties)
            {
                string propertyName = property.Name;
                object propertyValue = property.GetValue(obj);
                Debug.Log($"{propertyName}: {propertyValue}");
            }
        }

        internal static bool ObjectIsKindOfType<T>(object obj)
        {
            if (typeof(T).IsAssignableFrom(obj.GetType()))
            {
                return true;
            }
            return false;
        }

        internal static bool IsGenericTypeAssignableFrom(Type type, Type assignableFromType)
        {
            if (type.IsAssignableFrom(assignableFromType))
            {
                return true;
            }
            if (assignableFromType.IsEnum)
            {
                return type == typeof(string) || type == typeof(int);
            }
            return false;
        }

        internal static T CastValueToGenericType<T>(object obj)
        {
            if (obj.GetType().IsEnum)
            {
                if (typeof(T) == typeof(string))
                {
                    object str = obj.ToString();
                    return (T)str;
                }
                else if (typeof(T) == typeof(int))
                {
                    int number = (int)obj;
                    object numberObj = number;
                    return (T)numberObj;
                } 
            }
            return (T)obj;
        }

        internal static T safeValueForKey<T>(object obj, string methodName)
        {
            var type = obj.GetType();

            var propertyInfo = type.GetProperty(methodName, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.GetProperty);
            if (propertyInfo != null && propertyInfo.CanRead && IsGenericTypeAssignableFrom(typeof(T), propertyInfo.PropertyType))
            {
                return CastValueToGenericType<T>(propertyInfo.GetValue(obj));
            }

            var fieldInfo = type.GetField(methodName);
            if (fieldInfo != null && IsGenericTypeAssignableFrom(typeof(T), fieldInfo.FieldType))
            {
                return CastValueToGenericType<T>(fieldInfo.GetValue(obj));
            }

            var methodInfo = type.GetMethod(methodName, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.GetField);
            if (methodInfo != null && IsGenericTypeAssignableFrom(typeof(T), methodInfo.ReturnType))
            {
                return CastValueToGenericType<T>(methodInfo.Invoke(obj, null));
            }

            var indexerInfo = type.GetProperties().FirstOrDefault(x => x.GetIndexParameters().Select(y => y.ParameterType).SequenceEqual(new[] { typeof(string) }));
            if (indexerInfo != null && indexerInfo.CanRead && indexerInfo.PropertyType.IsAssignableFrom(typeof(T)))
            {
                return CastValueToGenericType<T>(indexerInfo.GetValue(obj, new string[] { methodName }));
            }

            return default(T);
        }

        internal static T safeValueForKeyStatic<T>(Type type, string methodName)
        {
            var propertyInfo = type.GetProperty(methodName, BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public);
            if (propertyInfo != null && propertyInfo.CanRead && IsGenericTypeAssignableFrom(typeof(T), propertyInfo.PropertyType))
            {
                return CastValueToGenericType<T>(propertyInfo.GetValue(null));
            }

            var fieldInfo = type.GetField(methodName, BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public);
            if (fieldInfo != null && IsGenericTypeAssignableFrom(typeof(T), fieldInfo.FieldType))
            {
                return CastValueToGenericType<T>(fieldInfo.GetValue(null));
            }

            var methodInfo = type.GetMethod(methodName, BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.GetField);
            if (methodInfo != null && IsGenericTypeAssignableFrom(typeof(T), methodInfo.ReturnType))
            {
                return CastValueToGenericType<T>(methodInfo.Invoke(null, null));
            }

            return default(T);
        }

        public static void safeSetValueForKey<T>(object obj, string methodName, T value)
        {
            var type = obj.GetType();

            var propertyInfo = type.GetProperty(methodName, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
            if (propertyInfo != null && propertyInfo.CanWrite && IsGenericTypeAssignableFrom(typeof(T), propertyInfo.PropertyType))
            {
                propertyInfo.SetValue(obj, value);
            }

            var fieldInfo = type.GetField(methodName);
            if (fieldInfo != null && typeof(T).IsAssignableFrom(fieldInfo.FieldType))
            {
                fieldInfo.SetValue(obj, value);
            }

            var methodInfo = type.GetMethod(methodName, new[] { typeof(T) });
            if (methodInfo != null && methodInfo.ReturnType == typeof(void))
            {
                methodInfo.Invoke(obj, new[] { (object)value });
            }

            var indexerInfo = type.GetProperties().FirstOrDefault(x => x.GetIndexParameters().Select(y => y.ParameterType).SequenceEqual(new[] { typeof(string) }));
            if (indexerInfo != null && indexerInfo.CanWrite && indexerInfo.PropertyType.IsAssignableFrom(typeof(T)))
            {
                indexerInfo.SetValue(obj, value, new string[] { methodName });
            }
        }

#if ENABLE_IL2CPP
        [UnityEngine.Scripting.Preserve]
#endif
        static void FixMe_SymbolsDoNotStrip()
        {
            _ = (null as SpriteRenderer).sprite;
            _ = (null as UnityEngine.UI.Text).fontStyle;
            _ = (null as UnityEngine.UI.Text).fontSize;
        }
    }

    internal static class ObjcRuntimeUnityEngineGameObject
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
            if (obj == null || !CSharpRuntimeSupportUtilities.ObjectIsKindOfType<GameObject>(obj)) return 0;
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
            if (obj == null || !CSharpRuntimeSupportUtilities.ObjectIsKindOfType<GameObject>(obj)) return 0;

            var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(componentName);
            if (type == null) return 0;

            var component = (obj as GameObject).GetComponent(type);
            return component ? component.GetInstanceID() : 0;
        }

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterAssembliesLoaded)]
        static void AfterAssembliesLoaded()
        {
#if UNITY_IOS || UNITY_TVOS
            if (Application.platform == RuntimePlatform.IPhonePlayer || Application.platform == RuntimePlatform.tvOS)
            {
                _UEORegisterCSharpFunc_UnityEngineGameObjectFind(_CSharpImpl_UnityEngineGameObjectFind);
                _UEORegisterCSharpFunc_UnityEngineGameObjectAddComponent(_CSharpImpl_UnityEngineGameObjectAddComponent);
                _UEORegisterCSharpFunc_UnityEngineGameObjectGetComponent(_CSharpImpl_UnityEngineGameObjectGetComponent);
            }
#endif
        }
    }

    internal static class ObjcRuntimeUnityEngineComponent
    {

        private delegate int _CSharpDelegate_UnityEngineComponentGetComponent(int objectInstanceID, string componentName);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineComponentGetComponent(_CSharpDelegate_UnityEngineComponentGetComponent func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineComponentGetComponent))]
        private static int _CSharpImpl_UnityEngineComponentGetComponent(int componnetInstanceID, string componentName)
        {
            var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(componnetInstanceID);
            if (obj == null || !CSharpRuntimeSupportUtilities.ObjectIsKindOfType<Component>(obj)) return 0;

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
            if (obj == null || !CSharpRuntimeSupportUtilities.ObjectIsKindOfType<Component>(obj)) return null;

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
            if (obj == null || !CSharpRuntimeSupportUtilities.ObjectIsKindOfType<Component>(obj)) return 0;

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
            if (obj == null || !CSharpRuntimeSupportUtilities.ObjectIsKindOfType<Component>(obj)) return null;

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
            if (obj == null || !CSharpRuntimeSupportUtilities.ObjectIsKindOfType<Component>(obj)) return 0;

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
            if (obj == null || !CSharpRuntimeSupportUtilities.ObjectIsKindOfType<Component>(obj)) return null;

            var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(componentName);
            if (type == null) return null;

            return (obj as Component).GetComponentsInParent(type).InstanceIDsToJsonString();
        }

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterAssembliesLoaded)]
        static void AfterAssembliesLoaded()
        {
#if UNITY_IOS || UNITY_TVOS
            if (Application.platform == RuntimePlatform.IPhonePlayer || Application.platform == RuntimePlatform.tvOS)
            {

                _UEORegisterCSharpFunc_UnityEngineComponentGetComponent(_CSharpImpl_UnityEngineComponentGetComponent);
                _UEORegisterCSharpFunc_UnityEngineComponentGetComponents(_CSharpImpl_UnityEngineComponentGetComponents);
                _UEORegisterCSharpFunc_UnityEngineComponentGetComponentInChildren(_CSharpImpl_UnityEngineComponentGetComponentInChildren);
                _UEORegisterCSharpFunc_UnityEngineComponentGetComponentsInChildren(_CSharpImpl_UnityEngineComponentGetComponentsInChildren);
                _UEORegisterCSharpFunc_UnityEngineComponentGetComponentInParent(_CSharpImpl_UnityEngineComponentGetComponentInParent);
                _UEORegisterCSharpFunc_UnityEngineComponentGetComponentsInParent(_CSharpImpl_UnityEngineComponentGetComponentsInParent);
            }
#endif
        }
    }

    internal static class ObjcRuntimeUnityEngineTransform
    {
        private delegate int _CSharpDelegate_UnityEngineTransformFind(int transformInstanceID, string childName);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineTransformFind(_CSharpDelegate_UnityEngineTransformFind func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineTransformFind))]
        private static int _CSharpImpl_UnityEngineTransformFind(int transformInstanceID, string childName)
        {
            var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(transformInstanceID);
            if (obj == null || !CSharpRuntimeSupportUtilities.ObjectIsKindOfType<Transform>(obj)) return 0;

            var child = (obj as Transform).Find(childName);
            return child ? child.GetInstanceID() : 0;
        }

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterAssembliesLoaded)]
        static void AfterAssembliesLoaded()
        {
#if UNITY_IOS || UNITY_TVOS
            if (Application.platform == RuntimePlatform.IPhonePlayer || Application.platform == RuntimePlatform.tvOS)
            {
                _UEORegisterCSharpFunc_UnityEngineTransformFind(_CSharpImpl_UnityEngineTransformFind);
            }
#endif
        }
    }

    internal static class ObjcRuntimeUnityEngineRectTransform
    {
        private delegate string _CSharpDelegate_UnityEngineRectTransformGetWorldCorners(int objectInstanceID);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineRectTransformGetWorldCorners(_CSharpDelegate_UnityEngineRectTransformGetWorldCorners func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineRectTransformGetWorldCorners))]
        private static string _CSharpImpl_UnityEngineRectTransformGetWorldCorners(int objectInstanceID)
        {
            var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
            if (obj == null || !CSharpRuntimeSupportUtilities.ObjectIsKindOfType<RectTransform>(obj)) return null;

            Vector3[] corners = new Vector3[4];
            (obj as RectTransform).GetWorldCorners(corners);
            return corners.ToJsonString();
        }

        private delegate NativeVector2 _CSharpDelegate_UnityEngineRectTransformUtilityWorldToScreenPoint(int cameraInstanceID, NativeVector3 vector);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineRectTransformUtilityWorldToScreenPoint(_CSharpDelegate_UnityEngineRectTransformUtilityWorldToScreenPoint func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineRectTransformUtilityWorldToScreenPoint))]
        private static NativeVector2 _CSharpImpl_UnityEngineRectTransformUtilityWorldToScreenPoint(int cameraInstanceID, NativeVector3 vector)
        {
            var camera = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(cameraInstanceID);
            if (camera != null && !CSharpRuntimeSupportUtilities.ObjectIsKindOfType<Camera>(camera)) return Vector2.zero.ToNative();

            return RectTransformUtility.WorldToScreenPoint((Camera)camera, vector.ToCSharp()).ToNative();
        }

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterAssembliesLoaded)]
        static void AfterAssembliesLoaded()
        {
#if UNITY_IOS || UNITY_TVOS
            if (Application.platform == RuntimePlatform.IPhonePlayer || Application.platform == RuntimePlatform.tvOS)
            {
                _UEORegisterCSharpFunc_UnityEngineRectTransformGetWorldCorners(_CSharpImpl_UnityEngineRectTransformGetWorldCorners);
                _UEORegisterCSharpFunc_UnityEngineRectTransformUtilityWorldToScreenPoint(_CSharpImpl_UnityEngineRectTransformUtilityWorldToScreenPoint);
            }
#endif
        }
    }

    internal static class ObjcRuntimeUnityEngineScene
    {
        private delegate bool _CSharpDelegate_UnityEngineSceneManagerGetActiveSceneIsLoaded();
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineSceneManagerGetActiveSceneIsLoaded(_CSharpDelegate_UnityEngineSceneManagerGetActiveSceneIsLoaded func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineSceneManagerGetActiveSceneIsLoaded))]
        private static bool _CSharpImpl_UnityEngineSceneManagerGetActiveSceneIsLoaded()
        {
            return UnityEngine.SceneManagement.SceneManager.GetActiveScene().isLoaded;
        }

        private delegate string _CSharpDelegate_UnityEngineSceneManagerGetActiveSceneName();
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineSceneManagerGetActiveSceneName(_CSharpDelegate_UnityEngineSceneManagerGetActiveSceneName func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineSceneManagerGetActiveSceneName))]
        private static string _CSharpImpl_UnityEngineSceneManagerGetActiveSceneName()
        {
            return UnityEngine.SceneManagement.SceneManager.GetActiveScene().name;
        }

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterAssembliesLoaded)]
        static void AfterAssembliesLoaded()
        {
#if UNITY_IOS || UNITY_TVOS
            if (Application.platform == RuntimePlatform.IPhonePlayer || Application.platform == RuntimePlatform.tvOS)
            {
                _UEORegisterCSharpFunc_UnityEngineSceneManagerGetActiveSceneIsLoaded(_CSharpImpl_UnityEngineSceneManagerGetActiveSceneIsLoaded);
                _UEORegisterCSharpFunc_UnityEngineSceneManagerGetActiveSceneName(_CSharpImpl_UnityEngineSceneManagerGetActiveSceneName);
            }
#endif
        }
    }

    internal static class ObjcRuntimeUnityEngineCamera
    {
        private delegate NativeVector3 _CSharpDelegate_UnityEngineCameraWorldToScreenPoint(int cameraInstanceID, NativeVector3 vector);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineCameraWorldToScreenPoint(_CSharpDelegate_UnityEngineCameraWorldToScreenPoint func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineCameraWorldToScreenPoint))]
        private static NativeVector3 _CSharpImpl_UnityEngineCameraWorldToScreenPoint(int cameraInstanceID, NativeVector3 vector)
        {
            var camera = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(cameraInstanceID);
            if (camera == null || !CSharpRuntimeSupportUtilities.ObjectIsKindOfType<Camera>(camera)) return Vector3.zero.ToNative();

            return (camera as Camera).WorldToScreenPoint(vector.ToCSharp()).ToNative();
        }

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterAssembliesLoaded)]
        static void AfterAssembliesLoaded()
        {
#if UNITY_IOS || UNITY_TVOS
            if (Application.platform == RuntimePlatform.IPhonePlayer || Application.platform == RuntimePlatform.tvOS)
            {
                _UEORegisterCSharpFunc_UnityEngineCameraWorldToScreenPoint(_CSharpImpl_UnityEngineCameraWorldToScreenPoint);
            }
#endif
        }
    }

    internal static class ObjcRuntimeUnityEngineObject
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

        private delegate NativeVector2 _CSharpDelegate_UnityEngineObjectSafeCSharpVector2ForKey(int objectInstanceID, string key);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVector2ForKey(_CSharpDelegate_UnityEngineObjectSafeCSharpVector2ForKey func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpVector2ForKey))]
        private static NativeVector2 _CSharpImpl_UnityEngineObjectSafeCSharpVector2ForKey(int objectInstanceID, string key)
        {
            if (string.IsNullOrEmpty(key)) return Vector2.zero.ToNative();
            var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
            if (obj == null) return Vector2.zero.ToNative();

            return CSharpRuntimeSupportUtilities.safeValueForKey<Vector2>(obj, key).ToNative();
        }

        private delegate NativeVector3 _CSharpDelegate_UnityEngineObjectSafeCSharpVector3ForKey(int objectInstanceID, string key);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVector3ForKey(_CSharpDelegate_UnityEngineObjectSafeCSharpVector3ForKey func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpVector3ForKey))]
        private static NativeVector3 _CSharpImpl_UnityEngineObjectSafeCSharpVector3ForKey(int objectInstanceID, string key)
        {
            if (string.IsNullOrEmpty(key)) return Vector3.zero.ToNative();
            var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
            if (obj == null) return Vector3.zero.ToNative();

            return CSharpRuntimeSupportUtilities.safeValueForKey<Vector3>(obj, key).ToNative();
        }

        private delegate NativeVector4 _CSharpDelegate_UnityEngineObjectSafeCSharpVector4ForKey(int objectInstanceID, string key);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVector4ForKey(_CSharpDelegate_UnityEngineObjectSafeCSharpVector4ForKey func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpVector4ForKey))]
        private static NativeVector4 _CSharpImpl_UnityEngineObjectSafeCSharpVector4ForKey(int objectInstanceID, string key)
        {
            if (string.IsNullOrEmpty(key)) return Vector4.zero.ToNative();
            var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
            if (obj == null) return Vector4.zero.ToNative();

            return CSharpRuntimeSupportUtilities.safeValueForKey<Vector4>(obj, key).ToNative();
        }

        private delegate NativeRect _CSharpDelegate_UnityEngineObjectSafeCSharpRectForKey(int objectInstanceID, string key);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpRectForKey(_CSharpDelegate_UnityEngineObjectSafeCSharpRectForKey func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpRectForKey))]
        private static NativeRect _CSharpImpl_UnityEngineObjectSafeCSharpRectForKey(int objectInstanceID, string key)
        {
            if (string.IsNullOrEmpty(key)) return Rect.zero.ToNative();
            var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
            if (obj == null) return Rect.zero.ToNative();

            return CSharpRuntimeSupportUtilities.safeValueForKey<Rect>(obj, key).ToNative();
        }

        private delegate NativeColor _CSharpDelegate_UnityEngineObjectSafeCSharpColorForKey(int objectInstanceID, string key);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpColorForKey(_CSharpDelegate_UnityEngineObjectSafeCSharpColorForKey func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpColorForKey))]
        private static NativeColor _CSharpImpl_UnityEngineObjectSafeCSharpColorForKey(int objectInstanceID, string key)
        {
            if (string.IsNullOrEmpty(key)) return new Color().ToNative();
            var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
            if (obj == null) return new Color().ToNative();

            return CSharpRuntimeSupportUtilities.safeValueForKey<Color>(obj, key).ToNative();
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
            var result = CSharpRuntimeSupportUtilities.safeValueForKey<UnityEngine.Object>(obj, key);

            return result?.GetInstanceID() ?? 0;
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

        private delegate NativeVector2 _CSharpDelegate_UnityEngineObjectSafeCSharpVector2ForKeyStatic(string typeName, string key);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVector2ForKeyStatic(_CSharpDelegate_UnityEngineObjectSafeCSharpVector2ForKeyStatic func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpVector2ForKeyStatic))]
        private static NativeVector2 _CSharpImpl_UnityEngineObjectSafeCSharpVector2ForKeyStatic(string typeName, string key)
        {
            if (string.IsNullOrEmpty(key)) return Vector2.zero.ToNative();
            var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(typeName);
            if (type == null) return Vector2.zero.ToNative();

            return CSharpRuntimeSupportUtilities.safeValueForKeyStatic<Vector2>(type, key).ToNative();
        }

        private delegate NativeVector3 _CSharpDelegate_UnityEngineObjectSafeCSharpVector3ForKeyStatic(string typeName, string key);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVector3ForKeyStatic(_CSharpDelegate_UnityEngineObjectSafeCSharpVector3ForKeyStatic func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpVector3ForKeyStatic))]
        private static NativeVector3 _CSharpImpl_UnityEngineObjectSafeCSharpVector3ForKeyStatic(string typeName, string key)
        {
            if (string.IsNullOrEmpty(key)) return Vector3.zero.ToNative();
            var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(typeName);
            if (type == null) return Vector3.zero.ToNative();

            return CSharpRuntimeSupportUtilities.safeValueForKeyStatic<Vector3>(type, key).ToNative();
        }

        private delegate NativeVector4 _CSharpDelegate_UnityEngineObjectSafeCSharpVector4ForKeyStatic(string typeName, string key);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVector4ForKeyStatic(_CSharpDelegate_UnityEngineObjectSafeCSharpVector4ForKeyStatic func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpVector4ForKeyStatic))]
        private static NativeVector4 _CSharpImpl_UnityEngineObjectSafeCSharpVector4ForKeyStatic(string typeName, string key)
        {
            if (string.IsNullOrEmpty(key)) return Vector4.zero.ToNative();
            var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(typeName);
            if (type == null) return Vector4.zero.ToNative();

            return CSharpRuntimeSupportUtilities.safeValueForKeyStatic<Vector4>(type, key).ToNative();
        }

        private delegate NativeRect _CSharpDelegate_UnityEngineObjectSafeCSharpRectForKeyStatic(string typeName, string key);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpRectForKeyStatic(_CSharpDelegate_UnityEngineObjectSafeCSharpRectForKeyStatic func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeCSharpRectForKeyStatic))]
        private static NativeRect _CSharpImpl_UnityEngineObjectSafeCSharpRectForKeyStatic(string typeName, string key)
        {
            if (string.IsNullOrEmpty(key)) return Rect.zero.ToNative();
            var type = CSharpRuntimeSupportUtilities.GetSafeTypeName(typeName);
            if (type == null) return Rect.zero.ToNative();

            return CSharpRuntimeSupportUtilities.safeValueForKeyStatic<Rect>(type, key).ToNative();
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

        private delegate void _CSharpDelegate_UnityEngineObjectSafeSetCSharpBoolForKey(int objectInstanceID, string key, bool value);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpBoolForKey(_CSharpDelegate_UnityEngineObjectSafeSetCSharpBoolForKey func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeSetCSharpBoolForKey))]
        private static void _CSharpImpl_UnityEngineObjectSafeSetCSharpBoolForKey(int objectInstanceID, string key, bool value)
        {
            if (string.IsNullOrEmpty(key)) return;
            var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
            if (obj == null) return;

            CSharpRuntimeSupportUtilities.safeSetValueForKey<bool>(obj, key, value);
        }

        private delegate void _CSharpDelegate_UnityEngineObjectSafeSetCSharpIntForKey(int objectInstanceID, string key, int value);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpIntForKey(_CSharpDelegate_UnityEngineObjectSafeSetCSharpIntForKey func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeSetCSharpIntForKey))]
        private static void _CSharpImpl_UnityEngineObjectSafeSetCSharpIntForKey(int objectInstanceID, string key, int value)
        {
            if (string.IsNullOrEmpty(key)) return;
            var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
            if (obj == null) return;

            CSharpRuntimeSupportUtilities.safeSetValueForKey<int>(obj, key, value);
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

        private delegate void _CSharpDelegate_UnityEngineObjectSafeSetCSharpDoubleForKey(int objectInstanceID, string key, double value);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpDoubleForKey(_CSharpDelegate_UnityEngineObjectSafeSetCSharpDoubleForKey func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeSetCSharpFloatForKey))]
        private static void _CSharpImpl_UnityEngineObjectSafeSetCSharpDoubleForKey(int objectInstanceID, string key, double value)
        {
            if (string.IsNullOrEmpty(key)) return;
            var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
            if (obj == null) return;

            CSharpRuntimeSupportUtilities.safeSetValueForKey<double>(obj, key, value);
        }

        private delegate void _CSharpDelegate_UnityEngineObjectSafeSetCSharpVector2ForKey(int objectInstanceID, string key, NativeVector2 value);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpVector2ForKey(_CSharpDelegate_UnityEngineObjectSafeSetCSharpVector2ForKey func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeSetCSharpVector2ForKey))]
        private static void _CSharpImpl_UnityEngineObjectSafeSetCSharpVector2ForKey(int objectInstanceID, string key, NativeVector2 value)
        {
            if (string.IsNullOrEmpty(key)) return;

            var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
            if (obj == null) return;

            CSharpRuntimeSupportUtilities.safeSetValueForKey<Vector2>(obj, key, value.ToCSharp());
        }

        private delegate void _CSharpDelegate_UnityEngineObjectSafeSetCSharpVector3ForKey(int objectInstanceID, string key, NativeVector3 value);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpVector3ForKey(_CSharpDelegate_UnityEngineObjectSafeSetCSharpVector3ForKey func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeSetCSharpVector3ForKey))]
        private static void _CSharpImpl_UnityEngineObjectSafeSetCSharpVector3ForKey(int objectInstanceID, string key, NativeVector3 value)
        {
            if (string.IsNullOrEmpty(key)) return;

            var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
            if (obj == null) return;

            CSharpRuntimeSupportUtilities.safeSetValueForKey<Vector3>(obj, key, value.ToCSharp());
        }

        private delegate void _CSharpDelegate_UnityEngineObjectSafeSetCSharpVector4ForKey(int objectInstanceID, string key, NativeVector4 value);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpVector4ForKey(_CSharpDelegate_UnityEngineObjectSafeSetCSharpVector4ForKey func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeSetCSharpVector4ForKey))]
        private static void _CSharpImpl_UnityEngineObjectSafeSetCSharpVector4ForKey(int objectInstanceID, string key, NativeVector4 value)
        {
            if (string.IsNullOrEmpty(key)) return;

            var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
            if (obj == null) return;

            CSharpRuntimeSupportUtilities.safeSetValueForKey<Vector4>(obj, key, value.ToCSharp());
        }

        private delegate void _CSharpDelegate_UnityEngineObjectSafeSetCSharpRectForKey(int objectInstanceID, string key, NativeRect value);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpRectForKey(_CSharpDelegate_UnityEngineObjectSafeSetCSharpRectForKey func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeSetCSharpRectForKey))]
        private static void _CSharpImpl_UnityEngineObjectSafeSetCSharpRectForKey(int objectInstanceID, string key, NativeRect value)
        {
            if (string.IsNullOrEmpty(key)) return;

            var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
            if (obj == null) return;

            CSharpRuntimeSupportUtilities.safeSetValueForKey<Rect>(obj, key, value.ToCSharp());
        }

        private delegate void _CSharpDelegate_UnityEngineObjectSafeSetCSharpColorForKey(int objectInstanceID, string key, NativeColor value);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpColorForKey(_CSharpDelegate_UnityEngineObjectSafeSetCSharpColorForKey func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeSetCSharpColorForKey))]
        private static void _CSharpImpl_UnityEngineObjectSafeSetCSharpColorForKey(int objectInstanceID, string key, NativeColor value)
        {
            if (string.IsNullOrEmpty(key)) return;

            var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
            if (obj == null) return;

            CSharpRuntimeSupportUtilities.safeSetValueForKey<Color>(obj, key, value.ToCSharp());
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

        private delegate void _CSharpDelegate_UnityEngineObjectSafeSetCSharpObjectForKey(int objectInstanceID, string key, int value);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpObjectForKey(_CSharpDelegate_UnityEngineObjectSafeSetCSharpObjectForKey func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectSafeSetCSharpObjectForKey))]
        private static void _CSharpImpl_UnityEngineObjectSafeSetCSharpObjectForKey(int objectInstanceID, string key, int value)
        {
            if (string.IsNullOrEmpty(key)) return;
            var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
            if (obj == null) return;
            var objectValue = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(value);
            if (obj != null && !CSharpRuntimeSupportUtilities.ObjectIsKindOfType<UnityEngine.Object>(obj)) return;

            CSharpRuntimeSupportUtilities.safeSetValueForKey<UnityEngine.Object>(obj, key, objectValue);
        }

        private delegate void _CSharpDelegate_UnityEngineObjectDestroy(int objectInstanceID);
        [DllImport("__Internal")] private static extern void _UEORegisterCSharpFunc_UnityEngineObjectDestroy(_CSharpDelegate_UnityEngineObjectDestroy func);
        [AOT.MonoPInvokeCallback(typeof(_CSharpDelegate_UnityEngineObjectDestroy))]
        private static void _CSharpImpl_UnityEngineObjectDestroy(int objectInstanceID)
        {
            var obj = CSharpRuntimeSupportUtilities.FindObjectFromInstanceID(objectInstanceID);
            if (obj == null) return;

            UnityEngine.Object.Destroy(obj);
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

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterAssembliesLoaded)]
        static void AfterAssembliesLoaded()
        {
#if UNITY_IOS || UNITY_TVOS
            if (Application.platform == RuntimePlatform.IPhonePlayer || Application.platform == RuntimePlatform.tvOS )
            {
                _UEORegisterCSharpFunc_UnityEngineObjectTypeFullName(_CSharpImpl_UnityEngineObjectTypeFullName);

                _UEORegisterCSharpFunc_UnityEngineObjectDestroy(_CSharpImpl_UnityEngineObjectDestroy);
                _UEORegisterCSharpFunc_UnityEngineObjectFindObjectsOfType(_CSharpImpl_UnityEngineObjectFindObjectsOfType);

                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVoidForKey(_CSharpImpl_UnityEngineObjectSafeCSharpVoidForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpBoolForKey(_CSharpImpl_UnityEngineObjectSafeCSharpBoolForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpIntForKey(_CSharpImpl_UnityEngineObjectSafeCSharpIntForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpFloatForKey(_CSharpImpl_UnityEngineObjectSafeCSharpFloatForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpDoubleForKey(_CSharpImpl_UnityEngineObjectSafeCSharpDoubleForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVector2ForKey(_CSharpImpl_UnityEngineObjectSafeCSharpVector2ForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVector3ForKey(_CSharpImpl_UnityEngineObjectSafeCSharpVector3ForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVector4ForKey(_CSharpImpl_UnityEngineObjectSafeCSharpVector4ForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpRectForKey(_CSharpImpl_UnityEngineObjectSafeCSharpRectForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpColorForKey(_CSharpImpl_UnityEngineObjectSafeCSharpColorForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpStringForKey(_CSharpImpl_UnityEngineObjectSafeCSharpStringForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpObjectForKey(_CSharpImpl_UnityEngineObjectSafeCSharpObjectForKey);

                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpBoolForKeyStatic(_CSharpImpl_UnityEngineObjectSafeCSharpBoolForKeyStatic);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpIntForKeyStatic(_CSharpImpl_UnityEngineObjectSafeCSharpIntForKeyStatic);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpFloatForKeyStatic(_CSharpImpl_UnityEngineObjectSafeCSharpFloatForKeyStatic);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpDoubleForKeyStatic(_CSharpImpl_UnityEngineObjectSafeCSharpDoubleForKeyStatic);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVector2ForKeyStatic(_CSharpImpl_UnityEngineObjectSafeCSharpVector2ForKeyStatic);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVector3ForKeyStatic(_CSharpImpl_UnityEngineObjectSafeCSharpVector3ForKeyStatic);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpVector4ForKeyStatic(_CSharpImpl_UnityEngineObjectSafeCSharpVector4ForKeyStatic);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpRectForKeyStatic(_CSharpImpl_UnityEngineObjectSafeCSharpRectForKeyStatic);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpStringForKeyStatic(_CSharpImpl_UnityEngineObjectSafeCSharpStringForKeyStatic);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeCSharpObjectForKeyStatic(_CSharpImpl_UnityEngineObjectSafeCSharpObjectForKeyStatic);

                _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpBoolForKey(_CSharpImpl_UnityEngineObjectSafeSetCSharpBoolForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpIntForKey(_CSharpImpl_UnityEngineObjectSafeSetCSharpIntForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpFloatForKey(_CSharpImpl_UnityEngineObjectSafeSetCSharpFloatForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpDoubleForKey(_CSharpImpl_UnityEngineObjectSafeSetCSharpDoubleForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpVector2ForKey(_CSharpImpl_UnityEngineObjectSafeSetCSharpVector2ForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpVector3ForKey(_CSharpImpl_UnityEngineObjectSafeSetCSharpVector3ForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpVector4ForKey(_CSharpImpl_UnityEngineObjectSafeSetCSharpVector4ForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpRectForKey(_CSharpImpl_UnityEngineObjectSafeSetCSharpRectForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpColorForKey(_CSharpImpl_UnityEngineObjectSafeSetCSharpColorForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpStringForKey(_CSharpImpl_UnityEngineObjectSafeSetCSharpStringForKey);
                _UEORegisterCSharpFunc_UnityEngineObjectSafeSetCSharpObjectForKey(_CSharpImpl_UnityEngineObjectSafeSetCSharpObjectForKey);

            }
#endif
        }
    }
}