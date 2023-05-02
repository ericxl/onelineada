#!/usr/bin/env python3

import os
import sys
import shutil

include_source = True;
xcodeproj_name = next((item for item in os.listdir(os.getcwd()) if os.path.isdir(os.path.join(os.getcwd(), item)) and item.endswith('.xcodeproj')), None).rstrip(".xcodeproj")
plugin_name = f"{xcodeproj_name}Plugin"
plugin_folder = os.path.join(os.getcwd(), f"unity_package/{plugin_name}");
if os.path.exists(plugin_folder):
  shutil.rmtree(plugin_folder)

if include_source:
  shutil.copytree(os.path.join(os.path.dirname(os.path.dirname(os.getcwd())), "Plugins/UnityObjC/Runtime"), os.path.join(plugin_folder, "Accessibility/UnityObjC/Runtime"))
  shutil.copytree(os.path.join(os.path.dirname(os.path.dirname(os.getcwd())), "Plugins/UnityAXUtils/Runtime"), os.path.join(plugin_folder, "Accessibility/UnityAXUtils/Runtime"))
  shutil.copytree(os.path.join(os.getcwd(), "Accessibility/Runtime"), os.path.join(plugin_folder, "Accessibility/Runtime"))
else:
  shutil.copytree(os.path.join(os.path.dirname(os.path.dirname(os.getcwd())), "Plugins/UnityObjC/Runtime"), os.path.join(plugin_folder, "Runtime"))
  shutil.rmtree(os.path.join(plugin_folder, "Runtime/iOS"))
  shutil.copytree(os.environ["BUILT_PRODUCTS_DIR"], os.path.join(plugin_folder, "Runtime/iOS"))

with open(os.path.join(plugin_folder, "package.json"), "w") as file:
    file.write(f'''{{
  "name": "com.ai.revui.unityplugin.{xcodeproj_name.lower()}",
  "displayName": , "{plugin_name}"
  "description": "Provides iOS accessibility for this project",
  "version": "1.0.0",
  "unity": "2019.2",
  "keywords": [
    "accessibility"
  ],
  "author": {{
    "name": "revui AI",
    "url": "https://revui.ai"
  }}
}}''')
