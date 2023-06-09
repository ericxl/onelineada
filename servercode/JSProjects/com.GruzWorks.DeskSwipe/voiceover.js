ObjC.createClassPair("TextAccessibilityNode", "UnityAccessibilityNode");
ObjC.addBoolMethodToClass("TextAccessibilityNode", "isAccessibilityElement", function(obj) { return true; }, "c@:");
ObjC.addRectMethodToClass("TextAccessibilityNode", "unitySpaceAccessibilityFrame", function(obj) {
    var instanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
    let transform = UnityEngine.UnityObject.create(instanceID).transform;
    let corners = transform.getWorldCorners();
    let canvas = transform.getComponentInParent("UnityEngine.Canvas");
    let camera = canvas.renderMode != UnityEngine.Canvas.RenderMode.ScreenSpaceOverlay ? canvas.worldCamera : undefined;
    let screenCorners = corners?.map((vector3) => UnityEngine.RectTransform.rectUtilityWorldToScreenPoint(camera, vector3));
    
    const maxX = Math.max(...screenCorners?.map(v => v.x));
    const minX = Math.min(...screenCorners?.map(v => v.x));
    const maxY = Math.max(...screenCorners?.map(v => v.y));
    const minY = Math.min(...screenCorners?.map(v => v.y));
    return {x: minX, y: UnityEngine.Screen.height - maxY, width: maxX - minX, height: maxY - minY};
}, "c@:");
ObjC.addStringMethodToClass("TextAccessibilityNode", "accessibilityLabel", function(obj) {
    var instanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
    let transform = UnityEngine.UnityObject.create(instanceID).transform;
    return transform.getComponentInChildren("TMPro.TextMeshProUGUI")?.text ?? transform.getComponentInChildren("UnityEngine.UI.Text")?.text;
}, "c@:");


ObjC.createClassPair("ProgressDisplayAccessibilityNode", "UnityAccessibilityNode");
ObjC.addBoolMethodToClass("ProgressDisplayAccessibilityNode", "isAccessibilityElement", function(obj) { return true; }, "c@:");
ObjC.addRectMethodToClass("ProgressDisplayAccessibilityNode", "unitySpaceAccessibilityFrame", function(obj) {
    var instanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
    let transform = UnityEngine.UnityObject.create(instanceID).transform;
    let corners = transform.getWorldCorners();
    let canvas = transform.getComponentInParent("UnityEngine.Canvas");
    let camera = canvas.renderMode != UnityEngine.Canvas.RenderMode.ScreenSpaceOverlay ? canvas.worldCamera : undefined;
    let screenCorners = corners?.map((vector3) => UnityEngine.RectTransform.rectUtilityWorldToScreenPoint(camera, vector3));
    
    const maxX = Math.max(...screenCorners?.map(v => v.x));
    const minX = Math.min(...screenCorners?.map(v => v.x));
    const maxY = Math.max(...screenCorners?.map(v => v.y));
    const minY = Math.min(...screenCorners?.map(v => v.y));
    return {x: minX, y: UnityEngine.Screen.height - maxY, width: maxX - minX, height: maxY - minY};
}, "c@:");
ObjC.addStringMethodToClass("ProgressDisplayAccessibilityNode", "accessibilityValue", function(obj) {
    var instanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
    let transform = UnityEngine.UnityObject.create(instanceID).transform?.find("Days Survived Text");
    return transform.getComponentInChildren("TMPro.TextMeshProUGUI")?.text ?? transform.getComponentInChildren("UnityEngine.UI.Text")?.text;
}, "c@:");
ObjC.addStringMethodToClass("ProgressDisplayAccessibilityNode", "accessibilityLabel", function(obj) {
    var instanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
    let transform = UnityEngine.UnityObject.create(instanceID).transform?.find("Days Survived Label");
    return transform.getComponentInChildren("TMPro.TextMeshProUGUI")?.text ?? transform.getComponentInChildren("UnityEngine.UI.Text")?.text;
}, "c@:");


ObjC.createClassPair("BarGroupAccessibilityNode", "UnityAccessibilityNode");
ObjC.addBoolMethodToClass("BarGroupAccessibilityNode", "isAccessibilityElement", function(obj) { return true; }, "c@:");
ObjC.addRectMethodToClass("BarGroupAccessibilityNode", "unitySpaceAccessibilityFrame", function(obj) {
    var instanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
    let transform = UnityEngine.UnityObject.create(instanceID).transform;
    let corners = transform.getWorldCorners();
    let canvas = transform.getComponentInParent("UnityEngine.Canvas");
    let camera = canvas.renderMode != UnityEngine.Canvas.RenderMode.ScreenSpaceOverlay ? canvas.worldCamera : undefined;
    let screenCorners = corners?.map((vector3) => UnityEngine.RectTransform.rectUtilityWorldToScreenPoint(camera, vector3));
    
    const maxX = Math.max(...screenCorners?.map(v => v.x));
    const minX = Math.min(...screenCorners?.map(v => v.x));
    const maxY = Math.max(...screenCorners?.map(v => v.y));
    const minY = Math.min(...screenCorners?.map(v => v.y));
    return {x: minX, y: UnityEngine.Screen.height - maxY, width: maxX - minX, height: maxY - minY};
}, "c@:");
ObjC.addStringMethodToClass("BarGroupAccessibilityNode", "accessibilityLabel", function(obj) {
    var instanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
  var go = UnityEngine.UnityObject.create(instanceID);
  console.log("unityobj: " + go);
  let goName = go.name;
    console.log("goName: " + goName);
    return goName.replace(/\b Bar Group\b$/, "");
}, "c@:");
ObjC.addStringMethodToClass("BarGroupAccessibilityNode", "accessibilityValue", function(obj) {
    var instanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
    let transform = UnityEngine.UnityObject.create(instanceID).transform;
    let searched = transform?.gameObject?.name.replace(/\b Group\b$/, "");
    let image = transform?.find(searched)?.getComponent("UnityEngine.UI.Image");
    let percentage = image.fillAmount;
    return (percentage * 100).toFixed(2) + "%";
}, "c@:");

ObjC.createClassPair("CardAccessibilityNode", "UnityAccessibilityNode");
ObjC.addBoolMethodToClass("CardAccessibilityNode", "isAccessibilityElement", function(obj) { return true; }, "c@:");
ObjC.addRectMethodToClass("CardAccessibilityNode", "unitySpaceAccessibilityFrame", function(obj) {
    var instanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
    let transform = UnityEngine.UnityObject.create(instanceID).transform;
    let corners = transform.getWorldCorners();
    let canvas = transform.getComponentInParent("UnityEngine.Canvas");
    let camera = canvas.renderMode != UnityEngine.Canvas.RenderMode.ScreenSpaceOverlay ? canvas.worldCamera : undefined;
    let screenCorners = corners?.map((vector3) => UnityEngine.RectTransform.rectUtilityWorldToScreenPoint(camera, vector3));
    
    const maxX = Math.max(...screenCorners?.map(v => v.x));
    const minX = Math.min(...screenCorners?.map(v => v.x));
    const maxY = Math.max(...screenCorners?.map(v => v.y));
    const minY = Math.min(...screenCorners?.map(v => v.y));
    return {x: minX, y: UnityEngine.Screen.height - maxY, width: maxX - minX, height: maxY - minY};
}, "c@:");
ObjC.addStringMethodToClass("CardAccessibilityNode", "accessibilityLabel", function(obj) {
    var instanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
  var go = UnityEngine.UnityObject.create(instanceID);
  console.log("unityobj: " + go);
  let goName = go.name;
    console.log("goName: " + goName);
    return goName.replace(/\b Bar Group\b$/, "");
}, "c@:");
ObjC.addStringMethodToClass("CardAccessibilityNode", "accessibilityValue", function(obj) {
    var instanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
    let transform = UnityEngine.UnityObject.create(instanceID).transform;
    let searched = transform?.gameObject?.name.replace(/\b Group\b$/, "");
    let image = transform?.find(searched)?.getComponent("UnityEngine.UI.Image");
    let percentage = image.fillAmount;
    return (percentage * 100).toFixed(2) + "%";
}, "c@:");

ObjC.createClassPair("__UnityView_super", "_ObjCSafeCategory");
ObjC.createClassPair("UnityViewAccessibility", "__UnityView_super");
ObjC.addBoolMethodToClass("UnityViewAccessibility", "isAccessibilityElement", function(obj) { return false; }, "c@:");
ObjC.addIntMethodToClass("UnityViewAccessibility", "accessibilityTraits", function(obj) { return 0; }, "c@:");
ObjC.addArrayMethodToClass("UnityViewAccessibility", "accessibilityElements", function(obj) {
    if (!InvokeFunc_Bool("*UnityEngineSceneManagerGetActiveSceneIsLoaded_CSharpFunc") || UnityEngine.Scene.activeSceneName != "GameplayScene") {
        return [];
    }
  return [
    UnityAccessibilityNode.createNode(UnityEngine.GameObject.find("/HUD Canvas/Top Pane/Stats Display/Coal Bar Group")?.instanceID, "BarGroupAccessibilityNode"),
    UnityAccessibilityNode.createNode(UnityEngine.GameObject.find("/HUD Canvas/Top Pane/Stats Display/Food Bar Group")?.instanceID, "BarGroupAccessibilityNode"),
    UnityAccessibilityNode.createNode(UnityEngine.GameObject.find("/HUD Canvas/Top Pane/Stats Display/Health Bar Group")?.instanceID, "BarGroupAccessibilityNode"),
    UnityAccessibilityNode.createNode(UnityEngine.GameObject.find("/HUD Canvas/Top Pane/Stats Display/Hope Bar Group")?.instanceID, "BarGroupAccessibilityNode"),
    UnityAccessibilityNode.createNode(UnityEngine.GameObject.find("/In-world Canvas/Card Description Display/Card Text")?.instanceID, "UnityAXElementCard"),
    UnityAccessibilityNode.createNode(UnityEngine.GameObject.find("/HUD Canvas/Version Text")?.instanceID, "TextAccessibilityNode"),
    UnityAccessibilityNode.createNode(UnityEngine.GameObject.find("/HUD Canvas/Bottom Pane/Progress Display")?.instanceID, "ProgressDisplayAccessibilityNode")
         ].filter(elem => elem !== null && elem !== undefined);
}, "c@:");

InvokeFunc_Void_Id0_Id1("_ObjCSafeCategoryInstall", "UnityViewAccessibility", "UnityView");

InvokeFunc_Void_Int0_Id1("UIAccessibilityPostNotification", LookupSymbol_Int("UIAccessibilityScreenChangedNotification"));