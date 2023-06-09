

function checkBoldAndButtonShape() {
  let shapesEnabled = InvokeFunc_Bool("UIAccessibilityButtonShapesEnabled");
  let isBold = InvokeFunc_Bool("UIAccessibilityIsBoldTextEnabled");
  UnityEngine.GameObject.find("/Canvas/Keyboard")?.transform?.getComponentsInChildren("KeyboardKey")?.forEach(function(kbKey) {
    if (shapesEnabled && kbKey.getComponent("UnityEngine.UI.Outline") === undefined) {
      var outline = kbKey?.gameObject?.addComponent("UnityEngine.UI.Outline");
      outline.effectDistance = { x: 8, y: -8 };
      outline.effectColor = { r: 0, g: 0, b: 0, a: 1 };
    }
    else if (!shapesEnabled && kbKey.getComponent("UnityEngine.UI.Outline") !== undefined) {
      kbKey.getComponent("UnityEngine.UI.Outline")?.destroy();
    }
  });
}

function displaySettingsChanged(obj) {
  if (obj.name === LookupSymbol_Id("UIAccessibilityBoldTextStatusDidChangeNotification") || obj.name === LookupSymbol_Id("UIAccessibilityButtonShapesEnabledStatusDidChangeNotification")) {
    checkBoldAndButtonShape();
  }
}

Notifications.addObserver(LookupSymbol_Id("UIAccessibilityBoldTextStatusDidChangeNotification"), displaySettingsChanged);
Notifications.addObserver(LookupSymbol_Id("UIAccessibilityButtonShapesEnabledStatusDidChangeNotification"), displaySettingsChanged);

checkBoldAndButtonShape();