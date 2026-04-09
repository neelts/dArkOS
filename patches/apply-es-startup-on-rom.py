#!/usr/bin/env python3
"""
Patches EmulationStation-fcamod source to add START ON ROM setting.
Run from the EmulationStation-fcamod source root.
"""
import sys
import os

def patch_file(path, old, new, description):
    with open(path, 'r') as f:
        content = f.read()
    if old not in content:
        print(f"ERROR: Could not find patch target in {path}: {description}")
        sys.exit(1)
    if new in content:
        print(f"SKIP: {description} already applied.")
        return
    with open(path, 'w') as f:
        f.write(content.replace(old, new, 1))
    print(f"OK: {description}")

# 1. Settings.cpp — register StartupOnRom default
patch_file(
    "es-core/src/Settings.cpp",
    'mStringMap["StartupSystem"] = "";',
    'mStringMap["StartupSystem"] = "";\n\tmStringMap["StartupOnRom"] = "";',
    "Register StartupOnRom default in Settings.cpp"
)

# 2. GuiMenu.cpp — add START ON ROM option list after START ON SYSTEM save func
OLD_MENU = '''\ts->addSaveFunc([systemfocus_list] {
\t\tSettings::getInstance()->setString("StartupSystem", systemfocus_list->getSelected());
\t});'''

NEW_MENU = '''\ts->addSaveFunc([systemfocus_list] {
\t\tSettings::getInstance()->setString("StartupSystem", systemfocus_list->getSelected());
\t});

\tif (Settings::getInstance()->getString("StartupSystem") == "pico-8") {
\t\tauto startOnRom = std::make_shared<OptionListComponent<std::string>>(mWindow, _("START ON ROM"), false);
\t\tstartOnRom->add(_("NONE"),   "",       Settings::getInstance()->getString("StartupOnRom") == "");
\t\tstartOnRom->add(_("SPLORE"), "splore", Settings::getInstance()->getString("StartupOnRom") == "splore");
\t\tstartOnRom->add(_("RECENT"), "recent", Settings::getInstance()->getString("StartupOnRom") == "recent");
\t\tif (!startOnRom->hasSelection())
\t\t\tstartOnRom->selectFirstItem();
\t\ts->addWithLabel(_("START ON ROM"), startOnRom);
\t\ts->addSaveFunc([startOnRom] {
\t\t\tSettings::getInstance()->setString("StartupOnRom", startOnRom->getSelected());
\t\t});
\t}'''

patch_file(
    "es-app/src/guis/GuiMenu.cpp",
    OLD_MENU,
    NEW_MENU,
    "Add START ON ROM option list in GuiMenu.cpp"
)

print("All patches applied successfully.")
