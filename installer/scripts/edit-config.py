#!/usr/bin/env python3
# FLSUN S1 Open Source Edition

import sys
import os

CONFIG_FILES = {
    "moonraker": "/home/pi/printer_data/config/moonraker.conf",
    "config": "/home/pi/printer_data/config/config.cfg",
}

if len(sys.argv) != 4 or sys.argv[1] not in ("enable", "disable") or sys.argv[3] not in CONFIG_FILES:
    print("Usage: edit_config.py <enable|disable> <item> <moonraker|config>")
    sys.exit(1)

action = sys.argv[1]
section_name = sys.argv[2]
config_file = CONFIG_FILES[sys.argv[3]]

if not os.path.isfile(config_file):
    print(f"Erreur : Le fichier '{config_file}' n'existe pas.")
    sys.exit(1)

with open(config_file, "r") as file:
    lines = file.readlines()

inside_section = False
updated_lines = []

for i, line in enumerate(lines):
    stripped_line = line.lstrip()

    if stripped_line.startswith(f"[{section_name}]") or stripped_line.startswith(f"#[{section_name}]"):
        inside_section = True
        updated_lines.append("#" + line.lstrip("# ") if action == "disable" else line.lstrip("# "))
        continue

    if inside_section and (stripped_line == "" or (stripped_line.startswith("[") and not stripped_line.startswith("#["))):
        inside_section = False

    if inside_section:
        updated_lines.append("#" + line.lstrip("# ") if action == "disable" else line.lstrip("# "))
    else:
        updated_lines.append(line)

with open(config_file, "w") as file:
    file.writelines(updated_lines)
