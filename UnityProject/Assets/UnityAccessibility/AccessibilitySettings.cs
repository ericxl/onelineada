using System;
using System.Runtime.InteropServices;
using UnityEngine;

namespace Apple.Accessibility
{
    public static class AccessibilitySettings
    {
        /// <summary>
        /// A Boolean value that indicates whether VoiceOver is in an enabled state.
        /// </summary>
        public static bool IsVoiceOverRunning
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityIsVoiceOverRunning");
#else
                return false;
#endif
            }
        }

        /// <summary>
        /// A Boolean value that indicates whether the Switch Control setting is in an enabled state.
        /// </summary>
        public static bool IsSwitchControlRunning
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityIsSwitchControlRunning");
#else
                return false;
#endif
            }
        }

        /// <summary>
        /// A Boolean value that indicates whether the Speak Selection setting is in an enabled state.
        /// </summary>
        public static bool IsSpeakSelectionEnabled
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityIsSpeakSelectionEnabled");
#else
                return false;
#endif
            }
        }

        /// <summary>
        /// A Boolean value that indicates whether the Guided Access setting is in an enabled state.
        /// </summary>
        public static bool IsGuidedAccessEnabled
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityIsGuidedAccessEnabled");
#else
                return false;
#endif
            }
        }

        /// <summary>
        /// A Boolean value that indicates whether the Mono Audio setting is in an enabled state.
        /// </summary>
        public static bool IsMonoAudioEnabled
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityIsMonoAudioEnabled");
#else
                return false;
#endif
            }
        }

        /// <summary>
        /// A Boolean value that indicates whether the Closed Captions + SDH setting is in an enabled state.
        /// </summary>
        public static bool IsClosedCaptioningEnabled
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityIsClosedCaptioningEnabled");
#else
                return false;
#endif
            }
        }

        /// <summary>
        /// A Boolean value that indicates whether the Classic Invert setting is in an enabled state.
        /// </summary>
        public static bool IsInvertColorsEnabled
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityIsInvertColorsEnabled");
#else
                return false;
#endif
            }
        }

        /// <summary>
        /// A Boolean value that indicates whether the Bold Text setting is in an enabled state.
        /// </summary>
        public static bool IsBoldTextEnabled
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityIsBoldTextEnabled");
#else
                return false;
#endif
            }
        }

        /// <summary>
        /// A Boolean value that indicates whether the Button Shapes setting is in an enabled state.
        /// </summary>
        public static bool IsButtonShapesEnabled
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityButtonShapesEnabled");
#else
                return false;
#endif
            }
        }

        /// <summary>
        /// A Boolean value that indicates whether the Color Filters and the Grayscale settings are in an enabled state.
        /// </summary>
        public static bool IsGrayscaleEnabled
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityIsGrayscaleEnabled");
#else
                return false;
#endif
            }
        }

        /// <summary>
        /// A Boolean value that indicates whether the Reduce Transparency setting is in an enabled state.
        /// </summary>
        public static bool IsReduceTransparencyEnabled
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityIsReduceTransparencyEnabled");
#else
                return false;
#endif
            }
        }

        /// <summary>
        /// A Boolean value that indicates whether the Reduce Motion setting is in an enabled state.
        /// </summary>
        public static bool IsReduceMotionEnabled
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityIsReduceMotionEnabled");
#else
                return false;
#endif
            }
        }

        /// <summary>
        /// A Boolean value that indicates whether the Reduce Motion and the Prefer Cross-Fade Transitions settings are in an enabled state.
        /// </summary>
        public static bool PrefersCrossFadeTransitions
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityPrefersCrossFadeTransitions");
#else
                return false;
#endif
            }
        }

        /// <summary>
        /// A Boolean value that indicates whether the Auto-Play Video Previews setting is in an enabled state.
        /// </summary>
        public static bool IsVideoAutoplayEnabled
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityIsVideoAutoplayEnabled");
#else
                return false;
#endif
            }
        }

        /// <summary>
        /// A Boolean value that indicates whether the Increase Contrast setting is in an enabled state.
        /// </summary>
        public static bool IsIncreaseContrastEnabled
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityDarkerSystemColorsEnabled");
#else
                return false;
#endif
            }
        }

        /// <summary>
        /// A Boolean value that indicates whether the Speak Screen setting is in an enabled state.
        /// </summary>
        public static bool IsSpeakScreenEnabled
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityIsSpeakScreenEnabled");
#else
                return false;
#endif
            }
        }

        /// <summary>
        /// A Boolean value that indicates whether the Shake to Undo setting is in an enabled state.
        /// </summary>
        public static bool IsShakeToUndoEnabled
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityIsShakeToUndoEnabled");
#else
                return false;
#endif
            }
        }

        /// <summary>
        /// A Boolean value that indicates whether the Differentiate Without Color setting is in an enabled state.
        /// </summary>
        public static bool ShouldDifferentiateWithoutColor
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityShouldDifferentiateWithoutColor");
#else
                return false;
#endif
            }
        }

        /// <summary>
        /// A Boolean value that indicates whether the On/Off Labels setting is in an enabled state.
        /// </summary>
        public static bool IsOnOffSwitchLabelsEnabled
        {
            get
            {
#if (UNITY_IOS || UNITY_TVOS) && !UNITY_EDITOR
                return _UnityAccessibility_GetUIKitBoolAnwser("UIAccessibilityIsOnOffSwitchLabelsEnabled");
#else
                return false;
#endif
            }
        }

        [DllImport("__Internal")] private static extern bool _UnityAccessibility_GetUIKitBoolAnwser(string question);
    }
}
