ObjC.createClassPair("WordleKeyboardAccessibilityNode", "UnityAccessibilityNode");
ObjC.addArrayMethodToClass("WordleKeyboardAccessibilityNode", "accessibilityElements", function(obj) {
    var keyboardInstanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
    var keys = UnityEngine.UnityObject.create(keyboardInstanceID).transform.getComponentsInChildren("KeyboardKey");
    return keys?.map((keyboardKey) => UnityAccessibilityNode.createNode(keyboardKey.instanceID, "WordleKeyboardKeyAccessibilityNode"));
}, "c@:");
ObjC.addRectMethodToClass("WordleKeyboardAccessibilityNode", "accessibilityFrame", function(obj) {
    return {x: 0, y: 0, width: 375, height: 667};
}, "c@:");

ObjC.createClassPair("WordleKeyboardKeyAccessibilityNode", "UnityAccessibilityNode");
ObjC.addBoolMethodToClass("WordleKeyboardKeyAccessibilityNode", "isAccessibilityElement", function(obj) { return true; }, "c@:");
ObjC.addRectMethodToClass("WordleKeyboardKeyAccessibilityNode", "unitySpaceAccessibilityFrame", function(obj) {
    var instanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
    let transform = UnityEngine.UnityObject.create(instanceID).transform;
    let corners = transform.getWorldCorners();
    let canvas = transform.getComponentInParent("UnityEngine.Canvas");

    let camera = undefined;
    let screenCorners = corners?.map((vector3) => UnityEngine.RectTransform.rectUtilityWorldToScreenPoint(camera, vector3));
    const maxX = Math.max(...screenCorners?.map(v => v.x));
    const minX = Math.min(...screenCorners?.map(v => v.x));
    const maxY = Math.max(...screenCorners?.map(v => v.y));
    const minY = Math.min(...screenCorners?.map(v => v.y));
    return {x: minX, y: UnityEngine.Screen.height - maxY, width: maxX - minX, height: maxY - minY};
}, "c@:");
ObjC.addStringMethodToClass("WordleKeyboardKeyAccessibilityNode", "accessibilityLabel", function(obj) {
    var instanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
    let transform = UnityEngine.UnityObject.create(instanceID).transform;
    return transform.getComponentInChildren("TMPro.TextMeshProUGUI")?.text ?? "delete";
}, "c@:");
ObjC.addIntMethodToClass("WordleKeyboardKeyAccessibilityNode", "accessibilityTraits", function(obj) {
    var instanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
    let transform = UnityEngine.UnityObject.create(instanceID).transform;
    if (transform.getComponentInChildren("TMPro.TextMeshProUGUI")?.text === "SUBMIT")
    {
        return AXButtonTrait;
    }
    else
    {
        return AXKeyboardKeyTrait;
    }
}, "c@:");

ObjC.createClassPair("WordleBoardAccessibilityNode", "UnityAccessibilityNode");
ObjC.addArrayMethodToClass("WordleBoardAccessibilityNode", "accessibilityElements", function(obj) {
    var boardInstanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
    var tiles = UnityEngine.UnityObject.create(boardInstanceID).transform.getComponentsInChildren("Tile");
    return tiles?.map((tile) => UnityAccessibilityNode.createNode(tile.instanceID, "WordleTileAccessibilityNode"));
}, "c@:");
ObjC.addRectMethodToClass("WordleBoardAccessibilityNode", "accessibilityFrame", function(obj) {
    return {x: 0, y: 0, width: 375, height: 667};
}, "c@:");

ObjC.createClassPair("WordleTileAccessibilityNode", "UnityAccessibilityNode");
ObjC.addBoolMethodToClass("WordleTileAccessibilityNode", "isAccessibilityElement", function(obj) { return true; }, "c@:");
ObjC.addRectMethodToClass("WordleTileAccessibilityNode", "unitySpaceAccessibilityFrame", function(obj) {
    var instanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
    let transform = UnityEngine.UnityObject.create(instanceID).transform;
    let corners = transform.getWorldCorners();
    let canvas = transform.getComponentInParent("UnityEngine.Canvas");

    let camera = undefined;
    let screenCorners = corners?.map((vector3) => UnityEngine.RectTransform.rectUtilityWorldToScreenPoint(camera, vector3) );
    const maxX = Math.max(...screenCorners?.map(v => v.x));
    const minX = Math.min(...screenCorners?.map(v => v.x));
    const maxY = Math.max(...screenCorners?.map(v => v.y));
    const minY = Math.min(...screenCorners?.map(v => v.y));
    return {x: minX, y: UnityEngine.Screen.height - maxY, width: maxX - minX, height: maxY - minY};
}, "c@:");
ObjC.addStringMethodToClass("WordleTileAccessibilityNode", "accessibilityLabel", function(obj) {
    var instanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
    let transform = UnityEngine.UnityObject.create(instanceID).transform;
    let textEle = transform.getComponentInChildren("TMPro.TextMeshProUGUI");
    let currentValue = transform.getComponentInChildren("TMPro.TextMeshProUGUI")?.text?.toUpperCase();
    let imageColor = transform.getComponent("UnityEngine.UI.Image")?.color;
    var state = undefined;
    if ( imageColor.r > 0.7 )
    {
        state = "correct but in wrong spot";
    }
    else if ( imageColor.g > 0.55 )
    {
        state = "correct spot";
    }
    else if ( imageColor.r > 0.22 && imageColor.g > 0.22 && imageColor.g > 0.22 )
    {
        state = "incorrect";
    }
    return currentValue.length > 0 ? [currentValue, state].filter(item => item !== undefined).join(", ") : "empty";
}, "c@:");
ObjC.addStringMethodToClass("WordleTileAccessibilityNode", "accessibilityValue", function(obj) {
    var instanceID = InvokeFunc_Int_Id0_Selector1_Id2("objc_msgSend", obj, "safeIntForKey:", "_instanceID");
    let transform = UnityEngine.UnityObject.create(instanceID).transform;
    let column = transform?.siblingIndex ?? 0;
    let row = transform?.parent?.siblingIndex ?? 0;
    return `column ${column+1} row ${row+1}`;
}, "c@:");

ObjC.createClassPair("__UnityView_super", "_ObjCSafeCategory");
ObjC.createClassPair("UnityViewAccessibility", "__UnityView_super");
ObjC.addBoolMethodToClass("UnityViewAccessibility", "isAccessibilityElement", function(obj) { return false; }, "c@:");
ObjC.addIntMethodToClass("UnityViewAccessibility", "accessibilityTraits", function(obj) { return 0; }, "c@:");
ObjC.addArrayMethodToClass("UnityViewAccessibility", "accessibilityElements", function(obj) {
    if (!InvokeFunc_Bool("*UnityEngineSceneManagerGetActiveSceneIsLoaded_CSharpFunc") || UnityEngine.Scene.activeSceneName != "Wordle") {
        return [];
    }
    var board = UnityAccessibilityNode.createNode(UnityEngine.GameObject.find("/Canvas/Board")?.instanceID, "WordleBoardAccessibilityNode");
    var keyboard = UnityAccessibilityNode.createNode(UnityEngine.GameObject.find("/Canvas/Keyboard")?.instanceID, "WordleKeyboardAccessibilityNode");
    return [board, keyboard];
}, "c@:");

InvokeFunc_Void_Id0_Id1("_ObjCSafeCategoryInstall", "UnityViewAccessibility", "UnityView");

InvokeFunc_Void_Int0_Id1("UIAccessibilityPostNotification", LookupSymbol_Int("UIAccessibilityScreenChangedNotification"));