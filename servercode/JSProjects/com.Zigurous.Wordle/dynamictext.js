function checkTextSize() {
  let multiplier = InvokeFunc_Double("_TMinusUnityUIAccessibilityPreferredContentSizeMultiplier");
    let size = 42.0 * multiplier;
    UnityEngine.GameObject.find("/Canvas/Keyboard")?.transform?.getComponentsInChildren("TMPro.TextMeshProUGUI")?.forEach(function(ugui) {
      ugui.fontSize = size;
    });
}

Notifications.addObserver(LookupSymbol_Id("UIContentSizeCategoryDidChangeNotification"), function(obj) {
  checkTextSize();
});
checkTextSize();