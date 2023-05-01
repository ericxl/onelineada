#!/usr/bin/env python3

import os
import sys
import shutil

# print("helo" + os.environ["BUILT_PRODUCTS_DIR"])
plugin_folder = os.path.join(os.getcwd(), "unity_package/iOSUnityAccessibilityPlugin");
if os.path.exists(plugin_folder):
    shutil.rmtree(plugin_folder)
shutil.copytree(os.path.join(os.path.dirname(os.path.dirname(os.getcwd())), "Plugins/UnityObjC/Runtime"), os.path.join(plugin_folder, "UnityObjC/Runtime"))
shutil.copytree(os.path.join(os.path.dirname(os.path.dirname(os.getcwd())), "Plugins/UnityAXUtils/Runtime/iOS"), os.path.join(plugin_folder, "UnityAXUtils/Runtime/iOS"))
# shutil.copytree(os.path.join(os.path.dirname(os.path.dirname(os.getcwd())), "Plugins/UnityObjC/Source"), os.path.join(os.getcwd(), "Packages/iOSUnityAccessibilityPlugin/UnityObjC/Runtime/iOS"))
# shutil.copytree(os.environ["BUILT_PRODUCTS_DIR"], os.path.join(os.getcwd(),  os.path.join(os.getcwd(), "Packages/iOSUnityAccessibilityPlugin/Runtime/iOS")))
# shutil.copytree(os.path.join(os.path.dirname(os.path.dirname(os.getcwd())), "Plugins/UnityAXUtils"), os.path.join(os.getcwd(), "Packages/iOSUnityAccessibilityPlugin/UnityAXUtils"))
shutil.copytree(os.path.join(os.getcwd(), "Accessibility/Runtime/iOS"), os.path.join(plugin_folder, "Accessibility/Runtime/iOS"))
with open(os.path.join(os.getcwd(), "Packages/iOSUnityAccessibilityPlugin/package.json"), "w") as file:
    file.write("""{
  "name": "com.xiaoyongliang.iosunityaccessibilityplugin",
  "displayName": "iOSUnityAccessibilityPlugin",
  "description": "Provides accessibility for Unity game",
  "version": "1.0.0",
  "unity": "2019.2",
  "keywords": [
    "accessibility"
  ],
  "author": {
    "name": "Xiaoyong Liang",
    "email": "jklelxy@gmail.com",
    "url": "https://www.xiaoyongliang.com"
  }
}""")
