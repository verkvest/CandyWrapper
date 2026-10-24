#!/usr/bin/env python3
"""Write Godot editor settings so headless Android export can find the SDK."""
import os
import sys

java = os.environ.get("JAVA_HOME", "")
sdk = os.environ.get("ANDROID_HOME", "") or os.environ.get("ANDROID_SDK_ROOT", "")
if not java or not sdk:
    print("JAVA_HOME and ANDROID_HOME are required", file=sys.stderr)
    sys.exit(1)

text = """[gd_resource type="EditorSettings" format=3]

[resource]
export/android/java_sdk_path = "%s"
export/android/android_sdk_path = "%s"
export/android/debug_keystore = ""
export/android/debug_keystore_user = ""
export/android/debug_keystore_pass = ""
export/android/build/automatically_delete_build_directory = true
""" % (java, sdk)

paths = [
    "export-tools/editor_data/editor_settings-4.tres",
    "export-tools/editor_data/editor_settings-4.7.tres",
    os.path.expanduser("~/.config/godot/editor_settings-4.tres"),
    os.path.expanduser("~/.config/godot/editor_settings-4.7.tres"),
]
for path in paths:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as handle:
        handle.write(text)
    print("wrote", path)
