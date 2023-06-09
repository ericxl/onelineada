'use strict';

const AXButtonTrait = (1 << 0);
const AXLinkTrait = (1 << 1);
const AXImageTrait = (1 << 2);
const AXSelectedTrait = (1 << 3);
const AXPlaysSoundTrait = (1 << 4);
const AXKeyboardKeyTrait = (1 << 5);
const AXStaticTextTrait = (1 << 6);
const AXSummaryElementTrait = (1 << 7);
const AXNotEnabledTrait = (1 << 8);
const AXUpdatesFrequentlyTrait = (1 << 9);
const AXSearchFieldTrait = (1 << 10);
const AXStartsMediaSessionTrait = (1 << 11);
const AXAdjustableTrait = (1 << 12);
const AXAllowsDirectInteractionTrait = (1 << 13);
const AXCausesPageTurnTrait = (1 << 14);
const AXTabBarTrait = (1 << 15);
const AXHeaderTrait = (1 << 16);
const AXWebContentTrait = (1 << 17);
const AXTextEntryTrait = (1 << 18);
const AXPickerElementTrait = (1 << 19);
const AXRadioButtonTrait = (1 << 20);
const AXIsEditingTrait = (1 << 21);
const AXLaunchIconTrait = (1 << 22);
const AXStatusBarElementTrait = (1 << 23);
const AXSecureTextFieldTrait = (1 << 24);
const AXInactiveTrait = (1 << 25);
const AXFooterTrait = (1 << 26);
const AXBackButtonTrait = (1 << 27);
const AXTabButtonTrait = (1 << 28);
const AXAutoCorrectCandidateTrait = (1 << 29);
const AXDeleteKeyTrait = (1 << 30);
const AXSelectionDismissesItemTrait = (1 << 31);
const AXVisitedTrait = (1 << 32);
const AXScrollableTrait = (1 << 33);
const AXSpacerTrait = (1 << 34);
const AXTableIndexTrait = (1 << 35);
const AXMapTrait = (1 << 36);
const AXTextOperationsAvailableTrait = (1 << 37);
const AXDraggableTrait = (1 << 38);
const AXGesturePracticeRegionTrait = (1 << 39);
const AXPopupButtonTrait = (1 << 40);
const AXAllowsNativeSlidingTrait = (1 << 41);
const AXMathEquationTrait = (1 << 42);
const AXContainedByTableTrait = (1 << 43);
const AXContainedByListTrait = (1 << 44);
const AXTouchContainerTrait = (1 << 45);
const AXSupportsZoomTrait = (1 << 46);
const AXTextAreaTrait = (1 << 47);
const AXBookContentTrait = (1 << 48);
const AXContainedByLandmarkTrait = (1 << 49);
const AXFolderIconTrait = (1 << 50);
const AXReadOnlyTrait = (1 << 51);
const AXMenuItemTrait = (1 << 52);
const AXToggleTrait = (1 << 53);
const AXIgnoreItemChooserTrait = (1 << 54);
const AXSupportsTrackingDetailTrait = (1 << 55);
const AXAlertTrait = (1 << 56);
const AXContainedByFieldsetTrait = (1 << 57);
const AXAllowsLayoutChangeInStatusBarTrait = (1 << 58);
const AXWebInteractiveVideoTrait = (1 << 59);
const AXProminentIconTrait = (1 << 60);
const AXGestureHandlerRegionTrait = (1 << 61);
const AXRemoveTraitsSenTrait = (1 << 63);

function safeInstanceID(obj) {
    if (obj === undefined) { return 0; }
    return obj.instanceID;
}
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
            this.z = obj.z || obj.width;
        }
        get width() {
          return this.z;
        }
        toString() {
            return `Vector3 { x: ${this.x}, y: ${this.y}, z: ${this.z} }`;
        }
    }
    class Vector4 {
        constructor(obj) {
            this.x = obj.x;
            this.y = obj.y;
            this.z = obj.z || obj.width;
            this.w = obj.w || obj.height;
        }
        get width() {
          return this.z;
        }
        get height() {
          return this.w;
        }
        toString() {
            return `Vector4 { x: ${this.x}, y: ${this.y}, z: ${this.z}, w: ${this.w} }`;
        }
    }
    class Rect {
        constructor(obj) {
            this.x = obj.x;
            this.y = obj.y;
            this.width = obj.z || obj.width;
            this.height = obj.w || obj.height;
        }
        toString() {
            return `Rect { x: ${this.x}, y: ${this.y}, width: ${this.width}, height: ${this.height} }`;
        }
    }
    class Color {
        constructor(r, g, b, a = 1) {
          if (typeof r === 'object' && r !== null) {
            const { r: red1, g: green1, b: blue1, a: alpha1 = 1, red: red2, green: green2, blue: blue2, alpha: alpha2 = 1 } = r;
            this.r = red1 || red2;
            this.g = green1 || green2;
            this.b = blue1 || blue2;
            this.a = alpha1 || alpha2;
          } else {
            this.r = r;
            this.g = g;
            this.b = b;
            this.a = a;
          }
        }
        toString() {
            return `Color { r: ${this.r}, g: ${this.g}, b: ${this.b}, a: ${this.a} }`;
        }
        toVector4() {
          console.log(`Color is ${this.toString()}`);
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
            return new Vector2(InvokeFunc_Rect_Int0_CharPtr1("*UnityEngineObjectSafeCSharpVector2ForKey_CSharpFunc", this._instanceID, key));
        }
        safeCSharpVector3ForKey(key) {
            return new Vector3(InvokeFunc_Rect_Int0_CharPtr1("*UnityEngineObjectSafeCSharpVector3ForKey_CSharpFunc", this._instanceID, key));
        }
        safeCSharpVector4ForKey(key) {
            return new Vector4(InvokeFunc_Rect_Int0_CharPtr1("*UnityEngineObjectSafeCSharpVector4ForKey_CSharpFunc", this._instanceID, key));
        }
        safeCSharpRectForKey(key) {
            return new Rect(InvokeFunc_Rect_Int0_CharPtr1("*UnityEngineObjectSafeCSharpRectForKey_CSharpFunc", this._instanceID, key));
        }
        safeCSharpColorForKey(key) {
            return new Color(InvokeFunc_Rect_Int0_CharPtr1("*UnityEngineObjectSafeCSharpColorForKey_CSharpFunc", this._instanceID, key));
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
            InvokeFunc_Void_Int0_CharPtr1_Rect2("*UnityEngineObjectSafeSetCSharpVector2ForKey_CSharpFunc", this._instanceID, key, value);
        }
        safeCSharpSetVector3ForKey(key, value) {
            InvokeFunc_Void_Int0_CharPtr1_Rect2("*UnityEngineObjectSafeSetCSharpVector3ForKey_CSharpFunc", this._instanceID, key, value);
        }
        safeCSharpSetVector4ForKey(key, value) {
            InvokeFunc_Void_Int0_CharPtr1_Rect2("*UnityEngineObjectSafeSetCSharpVector4ForKey_CSharpFunc", this._instanceID, key, value);
        }
        safeCSharpSetRectForKey(key, value) {
            InvokeFunc_Void_Int0_CharPtr1_Rect2("*UnityEngineObjectSafeSetCSharpRectForKey_CSharpFunc", this._instanceID, key, value);
        }
        safeCSharpSetColorForKey(key, value) {
          let c = { x: value.r, y: value.g, width: value.b, height: value.a};
            InvokeFunc_Void_Int0_CharPtr1_Rect2("*UnityEngineObjectSafeSetCSharpColorForKey_CSharpFunc", this._instanceID, key, c);
        }
        safeCSharpSetStringForKey(key, value) {
            InvokeFunc_Void_Int0_CharPtr1_CharPtr2("*UnityEngineObjectSafeSetCSharpStringForKey_CSharpFunc", this._instanceID, key, value);
        }
        safeCSharpSetObjectForKey(key, value) {
            InvokeFunc_Void_Int0_CharPtr1_Int2("*UnityEngineObjectSafeSetCSharpObjectForKey_CSharpFunc", this._instanceID, key, value.instanceID());
        }

        static findObjectsOfType(component) {
            InvokeFunc_Void_CharPtr0("*UnityEngineObjectFindObjectsOfType_CSharpFunc", component)
            const numberArray = InvokeFunc_Id("_TMinusUnityCSharpGetLatestData")
            return numberArray?.map((num) => UnityObject.create(num));
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
            const instanceId = InvokeFunc_Int_Int0_CharPtr1("*UnityEngineComponentGetComponent_CSharpFunc", this.instanceID, name)
            return UnityObject.create(instanceId);
        }
        getComponents(name) {
            InvokeFunc_Void_Int0_CharPtr1("*UnityEngineComponentGetComponents_CSharpFunc", this.instanceID, name)
            const numberArray = InvokeFunc_Id("_TMinusUnityCSharpGetLatestData")
            return numberArray?.map((num) => UnityObject.create(num));
        }
        getComponentInChildren(name) {
            const instanceId = InvokeFunc_Int_Int0_CharPtr1("*UnityEngineComponentGetComponentInChildren_CSharpFunc", this.instanceID, name)
            return UnityObject.create(instanceId);
        }
        getComponentsInChildren(name) {
            InvokeFunc_Void_Int0_CharPtr1("*UnityEngineComponentGetComponentsInChildren_CSharpFunc", this.instanceID, name)
            const numberArray = InvokeFunc_Id("_TMinusUnityCSharpGetLatestData")
            return numberArray?.map((num) => UnityObject.create(num));
        }
        getComponentInParent(name) {
            const instanceId = InvokeFunc_Int_Int0_CharPtr1("*UnityEngineComponentGetComponentInParent_CSharpFunc", this.instanceID, name)
            return UnityObject.create(instanceId);
        }
        getComponentsInParent(name) {
            InvokeFunc_Void_Int0_CharPtr1("*UnityEngineComponentGetComponentsInParent_CSharpFunc", this.instanceID, name)
            const numberArray = InvokeFunc_Id("_TMinusUnityCSharpGetLatestData")
            return numberArray?.map((num) => UnityObject.create(num));
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
            const instanceId = InvokeFunc_Int_Int0_CharPtr1("*UnityEngineGameObjectAddComponent_CSharpFunc", this.instanceID, name)
            return UnityObject.create(instanceId);
        }
        getComponent(name) {
            const instanceId = InvokeFunc_Int_Int0_CharPtr1("*UnityEngineGameObjectGetComponent_CSharpFunc", this.instanceID, name)
            return UnityObject.create(instanceId);
        }
    }
    class Camera extends UnityObject {
        static get main() {
            return UnityObject.create(InvokeFunc_Int_CharPtr0_CharPtr1("*UnityEngineObjectSafeCSharpObjectForKeyStatic_CSharpFunc", "UnityEngine.Camera", "main"));
        }
        
        worldToScreenPoint(screenPoint) {
            return new Vector3(InvokeFunc_Rect_Int0_Rect1("*UnityEngineCameraWorldToScreenPoint_CSharpFunc", this.instanceID, screenPoint));
        }
    }
    
    class Canvas extends UnityObject {
        get renderMode() {
            let intValue = this.safeCSharpIntForKey("renderMode");
            return Object.keys(Canvas.RenderMode).find(key => Canvas.RenderMode[key] === intValue) || null;
        }
        get worldCamera() {
            return this.safeCSharpObjectForKey("worldCamera");
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
            const numberArray = InvokeFunc_Id("_TMinusUnityCSharpGetLatestData");
            return numberArray?.map((num) => {
                return new Vector3(InvokeFunc_Rect_Id0_Selector1("objc_msgSend", num, "ucCGRectValue"));
            });
        }
        static rectUtilityWorldToScreenPoint(camera, worldPoint) {
            console.log("worldPOoint: " + worldPoint);
            let o = InvokeFunc_Rect_Int0_Rect1("*UnityEngineRectTransformUtilityWorldToScreenPoint_CSharpFunc", safeInstanceID(camera), worldPoint);
            let v = new Vector2(o);
            return v;
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
            Outline: Outline
        };
    })();


    return {
      Vector2: Vector2,
      Vector3: Vector3,
      Vector4: Vector4,
      Rect: Rect,
      Color: Color,
      UnityObject: UnityObject,
      Component: Component,
      Behaviour: Behaviour,
      MonoBehaviour: MonoBehaviour,
      Transform: Transform,
      RectTransform: RectTransform,
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

// bug from Apple. need to call this to take effect later
InvokeFunc_Bool("UIAccessibilityButtonShapesEnabled");
InvokeFunc_Bool("UIAccessibilityIsBoldTextEnabled");