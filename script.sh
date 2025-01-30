#!/bin/bash

BACKUP_ZIP="zsh-syntax-highlighting_backup.zip"
NEW_ZIP="zsh-syntax-highlighting.zip"
TARGET_DIR="/usr/share/zsh-syntax-highlighting"
COLOR_SCHEME_5="/usr/share/qtermwidget5/color-schemes/"
COLOR_SCHEME_6="/usr/share/qtermwidget6/color-schemes/"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# ANSI color codes
TXTCOLOR="\e[0;92m"
TXTERROR="\e[0;91m"
TXTDONE="\e[0;96m"
RESET="\e[0m"

# Check if script is run as root
if [[ "$EUID" -ne 0 ]]; then
    echo -e "${TXTERROR}This script must be run as root. Please use sudo or run as root.${RESET}"
    exit 1
fi

restore_backup() {
    echo -e "${TXTCOLOR}Restoring backup...${RESET}"
    sudo rm -f "$COLOR_SCHEME_5/Kali-Dark.colorscheme"
    
    if [[ ! -f "$SCRIPT_DIR/$BACKUP_ZIP" ]]; then
        read -p "Backup file not found. Please enter the correct ZIP filename: " user_zip
        if [[ ! -f "$SCRIPT_DIR/$user_zip" || "${user_zip: -4}" != ".zip" ]]; then
            echo -e "${TXTERROR}Error: The file does not exist or is not a valid ZIP archive.${RESET}"
            exit 1
        else
            BACKUP_ZIP="$user_zip"
        fi
    fi
    
    sudo unzip -o "$SCRIPT_DIR/$BACKUP_ZIP" -d /usr/share/
    sudo find "$TARGET_DIR" -type f -exec chmod 644 {} \;
    sudo find "$TARGET_DIR" -type d -exec chmod 755 {} \;
    sudo chown -R root:root "$TARGET_DIR"
    echo -e "${TXTCOLOR}Reset complete!${RESET}"
}

backup_files() {
    echo -e "${TXTCOLOR}Creating backup...${RESET}"
    cd /usr/share/ || exit
    sudo zip -r "$SCRIPT_DIR/$BACKUP_ZIP" "zsh-syntax-highlighting" --exclude="/usr/share/*"
    echo -e "${TXTCOLOR}Backup created: $BACKUP_ZIP${RESET}"
}

restore_files() {
    echo -e "${TXTCOLOR}Restoring the Kali-Dark theme...${RESET}"
    sudo unzip -o "$SCRIPT_DIR/$NEW_ZIP" -d /usr/share/
    sudo find "$TARGET_DIR" -type f -exec chmod 644 {} \;
    sudo find "$TARGET_DIR" -type d -exec chmod 755 {} \;
    sudo chown -R root:root "$TARGET_DIR"
    echo -e "${TXTCOLOR}Changes applied successfully!${RESET}"
}

copy_color_schemes() {
    echo -e "${TXTCOLOR}Copying Kali-Dark color schemes...${RESET}"
    sudo cp -r "$COLOR_SCHEME_6"* "$COLOR_SCHEME_5"
    echo -e "${TXTCOLOR}Color schemes copied.${RESET}"
}

echo -e "${TXTCOLOR}Select an option:${RESET}"
echo "1. Create the Kali-Dark theme and fix the terminal highlighting."
echo "2. Reset to defaults using a backup file."
read -p "Enter your choice (1/2): " choice

if [[ "$choice" == "2" ]]; then
    restore_backup
elif [[ "$choice" == "1" ]]; then
    copy_color_schemes
    backup_files
    restore_files
    echo
    echo -e "${TXTDONE}All steps completed. Please switch the profile to Kali-Dark in Terminal preferences (File - Preferences - Appearance - Color scheme - Kali-Dark).${RESET}"
    echo -e "${TXTDONE}Re-open your terminal for changes to take effect. Or a full system restart, if you want to be really sure. ;-) ${RESET}"
else
    echo -e "${TXTERROR}Invalid option. Exiting.${RESET}"
    exit 1
fi
