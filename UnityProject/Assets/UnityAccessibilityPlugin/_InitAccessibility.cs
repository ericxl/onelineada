using System.Runtime.InteropServices;
using UnityEngine;

static class _InitAccessibility
{
    [DllImport("__Internal")] private static extern void _InitializeAccessibility();
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
    private static void AfterSceneLoad()
    {
#if UNITY_IOS && !UNITY_EDITOR
        _InitializeAccessibility();
#endif
    }
}
