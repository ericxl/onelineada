'use strict';

const UnityEngine = (() => {
    class Vector2 {
        constructor(obj) {
            this.x = obj.x;
            this.y = obj.y;
        }
        toString() {
            return `Vector2 { x: ${this.x}, y: ${this.y} }`;
        }
    }
    class Vector3 {
        constructor(obj) {
            this.x = obj.x;
            this.y = obj.y;
            this.z = obj.z;
        }
        toString() {
            return `Vector3 { x: ${this.x}, y: ${this.y}, z: ${this.z} }`;
        }
    }
    class Vector4 {
        constructor(obj) {
            this.x = obj.x;
            this.y = obj.y;
            this.z = obj.z;
            this.w = obj.w;
        }
        toString() {
            return `Vector4 { x: ${this.x}, y: ${this.y}, z: ${this.z}, w: ${this.w} }`;
        }
    }
    class Rect {
        constructor(obj) {
            this.x = obj.x;
            this.y = obj.y;
            this.width = obj.width;
            this.height = obj.height;
        }
        toString() {
            return `Rect { x: ${this.x}, y: ${this.y}, width: ${this.width}, height: ${this.height} }`;
        }
    }
    class Color {
        constructor(obj) {
            this.r = obj.x;
            this.g = obj.y;
            this.b = obj.z;
            this.a = obj.w;
        }
        toString() {
            return `Color { r: ${this.r}, g: ${this.g}, b: ${this.b}, a: ${this.a} }`;
        }
        toVector4() {
            return new Vector4(this.r, this.g, this.b, this.a);
        }
    }
    class UnityObject {
        static create(instanceID) {
            if (instanceID == 0) {
                return;
            }
            let objClass = UnityObject;
            let fullname = InvokeFunc_CharPtr_Int0("*UnityEngineObjectTypeFullName_CSharpFunc", instanceID)
            if (fullname == "UnityEngine.GameObject") {
                objClass = GameObject;
            }
            else if (fullname == "UnityEngine.Camera") {
                objClass = Camera;
            }
            else if (fullname == "UnityEngine.Canvas") {
                objClass = Canvas;
            }
            else if (fullname == "UnityEngine.RectTransform") {
                objClass = RectTransform;
            }
            else if (fullname == "UnityEngine.Renderer") {
                objClass = Renderer;
            }
            else if (fullname == "UnityEngine.Sprite") {
                objClass = Sprite;
            }
            else if (fullname == "UnityEngine.SpriteRenderer") {
                objClass = SpriteRenderer;
            }
            else if (fullname == "UnityEngine.Transform") {
                objClass = Transform;
            }
            else if (fullname == "UnityEngine.UI.Text") {
                objClass = UI.Text;
            }
            else if (fullname == "TMPro.TextMeshProUGUI") {
                objClass = UI.TMProTextUGUI;
            }
            else if (fullname == "UnityEngine.UI.Image") {
                objClass = UI.Image;
            }
            else if (fullname == "UnityEngine.UI.Button") {
                objClass = UI.Button;
            }
            else if (fullname == "UnityEngine.UI.Outline") {
                objClass = UI.Outline;
            }
            else if (fullname == "UnityEngine.UI.Toggle") {
                objClass = UI.Toggle;
            }
            else {
                objClass = Component;
            }
            return new objClass(instanceID)
        }
        constructor(instanceID) {
          this._instanceID = instanceID;
        }

        isEqual(other) {
            if (other instanceof UnityObject) {
                return this._instanceID === other._instanceID;
            }
            return false;
        }
        toString() {
            return `[${this.constructor.name}] ${this.safeCSharpStringForKey("ToString")}`;
        }
        
        get instanceID() {
          return this._instanceID;
        }

        get typeFullName() {
            return InvokeFunc_CharPtr_Int0("*UnityEngineObjectTypeFullName_CSharpFunc", this._instanceID)
        }

        get name() {
            return this.safeCSharpStringForKey("name");
        }

        set name(value) {
            InvokeFunc_Void_Int0_CharPtr1_CharPtr2("*UnityEngineObjectSafeCSharpStringForKey_CSharpFunc", this._instanceID, "name", value)
        }

        destroy() {
            InvokeFunc_Void_Int0("*UnityEngineObjectDestroy_CSharpFunc", this._instanceID);
        }
        
        safeCSharpBoolForKey(key) {
            return InvokeFunc_Bool_Int0_CharPtr1  ("*UnityEngineObjectSafeCSharpBoolForKey_CSharpFunc",   this._instanceID, key);
        }
        safeCSharpIntForKey(key) {
            return InvokeFunc_Int_Int0_CharPtr1("*UnityEngineObjectSafeCSharpIntForKey_CSharpFunc", this._instanceID, key);
        }
        safeCSharpFloatForKey(key) {
            return InvokeFunc_Float_Int0_CharPtr1("*UnityEngineObjectSafeCSharpFloatForKey_CSharpFunc", this._instanceID, key);
        }
        safeCSharpDoubleForKey(key) {
            return InvokeFunc_Double_Int0_CharPtr1("*UnityEngineObjectSafeCSharpDoubleForKey_CSharpFunc", this._instanceID, key);
        }
        safeCSharpVector2ForKey(key) {
            return new Vector2(InvokeFunc_Vector2_Int0_CharPtr1("*UnityEngineObjectSafeCSharpVector2ForKey_CSharpFunc", this._instanceID, key));
        }
        safeCSharpVector3ForKey(key) {
            return new Vector3(InvokeFunc_Vector3_Int0_CharPtr1("*UnityEngineObjectSafeCSharpVector3ForKey_CSharpFunc", this._instanceID, key));
        }
        safeCSharpVector4ForKey(key) {
            return new Vector4(InvokeFunc_Vector4_Int0_CharPtr1("*UnityEngineObjectSafeCSharpVector4ForKey_CSharpFunc", this._instanceID, key));
        }
        safeCSharpRectForKey(key) {
            return new Rect(InvokeFunc_Rect_Int0_CharPtr1("*UnityEngineObjectSafeCSharpRectForKey_CSharpFunc", this._instanceID, key));
        }
        safeCSharpColorForKey(key) {
            return new Color(InvokeFunc_Vector4_Int0_CharPtr1("*UnityEngineObjectSafeCSharpColorForKey_CSharpFunc", this._instanceID, key));
        }
        safeCSharpStringForKey(key) {
            return InvokeFunc_CharPtr_Int0_CharPtr1("*UnityEngineObjectSafeCSharpStringForKey_CSharpFunc", this._instanceID, key);
        }
        safeCSharpObjectForKey(key) {
            return UnityObject.create(InvokeFunc_Int_Int0_CharPtr1("*UnityEngineObjectSafeCSharpObjectForKey_CSharpFunc", this._instanceID, key));
        }
        
        safeCSharpSetBoolForKey(key, value) {
            InvokeFunc_Void_Int0_CharPtr1_Bool2("*UnityEngineObjectSafeSetCSharpBoolForKey_CSharpFunc", this._instanceID, key, value);
        }
        safeCSharpSetIntForKey(key, value) {
            InvokeFunc_Void_Int0_CharPtr1_Int2("*UnityEngineObjectSafeSetCSharpIntForKey_CSharpFunc", this._instanceID, key, value);
        }
        safeCSharpSetFloatForKey(key, value) {
            InvokeFunc_Void_Int0_CharPtr1_Float2("*UnityEngineObjectSafeSetCSharpFloatForKey_CSharpFunc", this._instanceID, key, value);
        }
        safeCSharpSetDoubleForKey(key, value) {
            InvokeFunc_Void_Int0_CharPtr1_Double2("*UnityEngineObjectSafeSetCSharpDoubleForKey_CSharpFunc", this._instanceID, key, value);
        }
        safeCSharpSetVector2ForKey(key, value) {
            InvokeFunc_Void_Int0_CharPtr1_Vector22("*UnityEngineObjectSafeSetCSharpVector2ForKey_CSharpFunc", this._instanceID, key, value);
        }
        safeCSharpSetVector3ForKey(key, value) {
            InvokeFunc_Void_Int0_CharPtr1_Vector32("*UnityEngineObjectSafeSetCSharpVector3ForKey_CSharpFunc", this._instanceID, key, value);
        }
        safeCSharpSetVector4ForKey(key, value) {
            InvokeFunc_Void_Int0_CharPtr1_Vector42("*UnityEngineObjectSafeSetCSharpVector4ForKey_CSharpFunc", this._instanceID, key, value);
        }
        safeCSharpSetRectForKey(key, value) {
            InvokeFunc_Void_Int0_CharPtr1_Rect2("*UnityEngineObjectSafeSetCSharpRectForKey_CSharpFunc", this._instanceID, key, value);
        }
        safeCSharpSetColorForKey(key, value) {
            InvokeFunc_Void_Int0_CharPtr1_Rect2("*UnityEngineObjectSafeSetCSharpRectForKey_CSharpFunc", this._instanceID, key, value.toVector4());
        }
        safeCSharpSetStringForKey(key, value) {
            InvokeFunc_Void_Int0_CharPtr1_CharPtr2("*UnityEngineObjectSafeSetCSharpStringForKey_CSharpFunc", this._instanceID, key, value);
        }
        safeCSharpSetObjectForKey(key, value) {
            InvokeFunc_Void_Int0_CharPtr1_Int2("*UnityEngineObjectSafeSetCSharpObjectForKey_CSharpFunc", this._instanceID, key, value.instanceID());
        }

        static findObjectsOfType(component) {
            InvokeFunc_Void_CharPtr0("*UnityEngineObjectFindObjectsOfType_CSharpFunc", component)
            const numberArray = InvokeFunc_Id("_UEOCSharpGetLatestData")
            return numberArray.map((num) => UnityObject.create(num));
        }
    }
    
    class Component extends UnityObject {
        get tag() {
            return this.safeCSharpStringForKey("tag")
        }
        get gameObject() {
            return this.safeCSharpObjectForKey("gameObject")
        }
        get transform() {
            return this.safeCSharpObjectForKey("transform")
        }
        getComponent(name) {
            const instanceId = InvokeFunc_Int_Int0_CharPtr1("*UnityEngineComponentGetComponent_CSharpFunc", self.instanceID(), name)
            return UnityObject.create(instanceId);
        }
        getComponents(name) {
            InvokeFunc_Void_Int0_CharPtr1("*UnityEngineComponentGetComponents_CSharpFunc", self.instanceID(), name)
            const numberArray = InvokeFunc_Id("_UEOCSharpGetLatestData")
            return numberArray.map((num) => UnityObject.create(num));
        }
        getComponentInChildren(name) {
            const instanceId = InvokeFunc_Int_Int0_CharPtr1("*UnityEngineComponentGetComponentInChildren_CSharpFunc", self.instanceID(), name)
            return UnityObject.create(instanceId);
        }
        getComponentsInChildren(name) {
            InvokeFunc_Void_Int0_CharPtr1("*UnityEngineComponentGetComponentsInChildren_CSharpFunc", self.instanceID(), name)
            const numberArray = InvokeFunc_Id("_UEOCSharpGetLatestData")
            return numberArray.map((num) => UnityObject.create(num));
        }
        getComponentInParent(name) {
            const instanceId = InvokeFunc_Int_Int0_CharPtr1("*UnityEngineComponentGetComponentInParent_CSharpFunc", self.instanceID(), name)
            return UnityObject.create(instanceId);
        }
        getComponentsInParent(name) {
            InvokeFunc_Void_Int0_CharPtr1("*UnityEngineComponentGetComponentsInParent_CSharpFunc", self.instanceID(), name)
            const numberArray = InvokeFunc_Id("_UEOCSharpGetLatestData")
            return numberArray.map((num) => UnityObject.create(num));
        }
    }
    
    class Screen {
        static get height() {
            return InvokeFunc_Int_CharPtr0_CharPtr1("*UnityEngineObjectSafeCSharpIntForKeyStatic_CSharpFunc", "UnityEngine.Screen", "height");
        }
        static get width() {
            return InvokeFunc_Int_CharPtr0_CharPtr1("*UnityEngineObjectSafeCSharpIntForKeyStatic_CSharpFunc", "UnityEngine.Screen", "width");
        }
    }
    
    class Scene {
        static get activeSceneIsLoaded() {
            return InvokeFunc_Bool("*UnityEngineSceneManagerGetActiveSceneIsLoaded_CSharpFunc");
        }
        static get activeSceneName() {
            return InvokeFunc_CharPtr("*UnityEngineSceneManagerGetActiveSceneName_CSharpFunc");
        }
    }
    
    class GameObject extends UnityObject {
        get layer() {
            return this.safeCSharpIntForKey("layer")
        }
        get tag() {
            return this.safeCSharpStringForKey("tag")
        }
        get activeSelf() {
            return this.safeCSharpBoolForKey("activeSelf")
        }
        get activeInHierarchy() {
            return this.safeCSharpBoolForKey("activeInHierarchy")
        }
        get gameObject() {
            return this.safeCSharpObjectForKey("gameObject")
        }
        get transform() {
            return this.safeCSharpObjectForKey("transform")
        }
        static find(name) {
            const instanceId = InvokeFunc_Int_CharPtr0("*UnityEngineGameObjectFind_CSharpFunc", name);
            return UnityObject.create(instanceId)
        }
        addComponent(name) {
            const instanceId = InvokeFunc_Int_Int0_CharPtr1("*UnityEngineGameObjectAddComponent_CSharpFunc", self.instanceID(), name)
            return UnityObject.create(instanceId);
        }
        getComponent(name) {
            const instanceId = InvokeFunc_Int_Int0_CharPtr1("*UnityEngineGameObjectGetComponent_CSharpFunc", self.instanceID(), name)
            return UnityObject.create(instanceId);
        }
    }
    class Camera extends UnityObject {
        static get main() {
            return UnityObject.create(InvokeFunc_Int_CharPtr0_CharPtr1("*UnityEngineObjectSafeCSharpObjectForKeyStatic_CSharpFunc", "UnityEngine.Camera", "main"));
        }
        
        worldToScreenPoint(screenPoint) {
            return new Vector3(InvokeFunc_Vector3_Int0_Vector31("*UnityEngineCameraWorldToScreenPoint_CSharpFunc", this.instanceID, screenPoint));
        }
    }
    
    class Canvas extends UnityObject {
        get renderMode() {
            let intValue = this.safeCSharpIntForKey("renderMode");
            return Object.keys(Canvas.RenderMode).find(key => Canvas.RenderMode[key] === intValue) || null;
        }
        get worldCamera() {
            return UnityObject.create(this.safeCSharpObjectForKey("worldCamera"));
        }
    }
    
    Canvas.RenderMode = {
        ScreenSpaceOverlay: 0,
        ScreenSpaceCamera: 1,
        WorldSpace: 2,
    };
    
    class Behaviour extends Component {
        get enabled() {
            return this.safeCSharpBoolForKey("enabled");
        }
        set enabled(value) {
            this.safeCSharpSetBoolForKey("enabled", value);
        }
    }
    
    class MonoBehaviour extends Behaviour {
    }
    
    class Transform extends Component {
        find(childName) {
            return UnityObject.create(InvokeFunc_Int_Int0_CharPtr1("*UnityEngineTransformFind_CSharpFunc", this.instanceID, childName));
        }
        get siblingIndex() {
            return this.safeCSharpIntForKey("GetSiblingIndex");
        }
        set siblingIndex(value) {
            this.safeCSharpSetIntForKey("SetSiblingIndex", value);
        }
        get parent() {
            return this.safeCSharpObjectForKey("parent");
        }
        set siblingIndex(value) {
            this.safeCSharpSetObjectForKey("parent", value);
        }
        get position() {
            return this.safeCSharpVector3ForKey("position");
        }
        set position(value) {
            this.safeCSharpSetVector3ForKey("position", value);
        }
        get localScale() {
            return this.safeCSharpVector3ForKey("localScale");
        }
        set localScale(value) {
            this.safeCSharpSetVector3ForKey("localScale", value);
        }
    }
    
    class RectTransform extends Transform {
        getWorldCorners() {
            InvokeFunc_Void_Int0("*UnityEngineRectTransformGetWorldCorners_CSharpFunc", this.instanceID);
            const numberArray = InvokeFunc_Id("_UEOCSharpGetLatestData")
            return numberArray.map((num) => new Vector3(num));
        }
        rectUtilityWorldToScreenPoint(camera, worldPoint) {
            new Vector2(InvokeFunc_Vector2_Int0_Vector31("*UnityEngineRectTransformUtilityWorldToScreenPoint_CSharpFunc", this.instanceID, worldPoint));
        }
    }
    
    class Renderer extends Component {
        get sortingOrder() {
            return this.safeCSharpIntForKey("sortingOrder");
        }
        set sortingOrder(value) {
            this.safeCSharpSetIntForKey("sortingOrder", value);
        }
    }
    
    class Sprite extends UnityObject {
        get textureRect() {
            return this.safeCSharpRectForKey("textureRect");
        }
    }
    
    class SpriteRenderer extends Renderer {
        get sprite() {
            return this.safeCSharpObjectForKey("sprite");
        }
    }
    
    const UI = (() => {
        class Graphic extends MonoBehaviour {
            get canvas() {
                return this.safeCSharpObjectForKey("canvas");
            }
        }
        
        class Text extends Graphic {
            get text() {
                return this.safeCSharpStringForKey("text");
            }
            set text(value) {
                return this.safeCSharpSetStringForKey("text", value);
            }
            get fontSize() {
                return this.safeCSharpIntForKey("fontSize");
            }
            set fontSize(value) {
                return this.safeCSharpSetIntForKey("fontSize", value);
            }
            get fontStyle() {
                let intValue = this.safeCSharpIntForKey("fontSize");
                return Object.keys(Text.FontStyle).find(key => Canvas.RenderMode[key] === intValue) || null;
            }
            set fontStyle(value) {
                return this.safeCSharpSetIntForKey("fontSize", value);
            }
        }
        
        Text.FontStyle = {
            Normal: 0,
            Bold: 1,
            Italic: 2,
            BoldAndItalic: 2,
        };
        
        class TMProTextUGUI extends Graphic {
            get text() {
                return this.safeCSharpStringForKey("text");
            }
            set text(value) {
                return this.safeCSharpSetStringForKey("text", value);
            }
            get fontSize() {
                return this.safeCSharpFloatForKey("fontSize");
            }
            set fontSize(value) {
                return this.safeCSharpSetFloatForKey("fontSize", value);
            }
            get fontStyle() {
                return this.safeCSharpIntForKey("fontStyle");
            }
            set fontStyle(value) {
                return this.safeCSharpSetIntForKey("fontStyle", value);
            }
        }
        TMProTextUGUI.TMProFontStyles = {
            Normal: 0x0,
            Bold: 0x1,
            Italic: 0x2,
            Underline: 0x4,
            LowerCase: 0x8,
            UpperCase: 0x10,
            SmallCaps: 0x20,
            Strikethrough: 0x40,
            Superscript: 0x80,
            Subscript: 0x100,
            Highlight: 0x200
        };
        
        class Selectable extends MonoBehaviour {
            get interactable() {
                return this.safeCSharpIntForKey("interactable");
            }
            set interactable(value) {
                return this.safeCSharpSetIntForKey("interactable", value);
            }
        }
        
        class Image extends Graphic {
            get fillAmount() {
                return this.safeCSharpFloatForKey("fillAmount");
            }
            set fillAmount(value) {
                return this.safeCSharpSetFloatForKey("fillAmount", value);
            }
            get color() {
                return this.safeCSharpColorForKey("color");
            }
            set color(value) {
                return this.safeCSharpSetColorForKey("color", value);
            }
        }
        
        class Button extends Selectable {
        }
        
        class Outline extends MonoBehaviour {
            get effectDistance() {
                return this.safeCSharpVector2ForKey("effectDistance");
            }
            set effectDistance(value) {
                return this.safeCSharpSetVector2ForKey("effectDistance", value);
            }
            get effectColor() {
                return this.safeCSharpColorForKey("effectColor");
            }
            set effectColor(value) {
                return this.safeCSharpSetColorForKey("effectColor", value);
            }
        }
        
        class Toggle extends Selectable {
            get isOn() {
                return this.safeCSharpBoolForKey("isOn");
            }
            set isOn(value) {
                return this.safeCSharpSetBoolForKey("isOn", value);
            }
        }
        
        return {
            Graphic: Graphic,
            Text: Text,
            TMProTextUGUI: TMProTextUGUI,
            Selectable: Selectable,
            Image: Image,
            Button: Button,
            Outline: Outline,
        };
    })();


    return {
        UnityObject: UnityObject,
        Component: Component,
        Behaviour: Behaviour,
        MonoBehaviour: MonoBehaviour,
        Transform: Transform,
        GameObject: GameObject,
        Camera: Camera,
        Canvas: Canvas,
        Sprite: Sprite,
        SpriteRenderer: SpriteRenderer,
        Renderer: Renderer,
        Screen: Screen,
        Scene: Scene,
        UI: UI
    };
})();

console.log(UnityEngine.GameObject.find("/Canvas/Board"));

//var objects = UnityEngine.UnityObject.findObjectsOfType("Tile")
//console.log(objects[0])
//console.log(objects[0].transform)
//console.log("screen height: " + UnityEngine.Screen.height);
//console.log("scene name: " + UnityEngine.Scene.activeSceneName);
//console.log(UnityEngine.Camera.main.worldToScreenPoint({x:0, y: 1, z: 1}));
//var voiceOverRunning = InvokeFunc_Bool("UIAccessibilityIsVoiceOverRunning");
//console.log("VO running" + voiceOverRunning)

//ObjC.createClassPair("__MyImageView_super", "_UnityAXSafeCategory"); ObjC.createClassPair("MyImageViewAccessibility", "__MyImageView_super");
//
//ObjC.addBoolMethodToClass("MyImageViewAccessibility", "isAccessibilityElement", function(obj, sel) { return true; }, "c@:");
//ObjC.addStringMethodToClass("MyImageViewAccessibility", "accessibilityLabel", function(obj, sel) { return "hello javascript"; }, "c@:");
//ObjC.addStringMethodToClass("MyImageViewAccessibility", "accessibilityHint",
//                       function(obj) {
//                         for (const key in obj) {
//
//                           if (Object.prototype.hasOwnProperty.call(obj, key)) {
//                             console.log(`${key}: ${obj[key]}`);
//                           }
//                         }
//
////                        console.log("object is" + obj);
//                        return "This is a random hint";
//}, "c@:");
//
//Utils.installSafeCategory("MyImageViewAccessibility", "MyImageView");
