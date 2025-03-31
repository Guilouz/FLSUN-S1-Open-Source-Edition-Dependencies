#!/bin/bash
# FLSUN S1 Open Source Edition

function restoreJSON() {
    local jsonFile="$1"
    local baseUrl="$2/server/database/item"
	local namespace="$3"
    local namespaceUrl="${baseUrl}?namespace=${namespace}"
    local responseNamespaces=$(curl -s "$2/server/database/list")
    local namespacesArray=$(echo "$responseNamespaces" | jq -r '.result.namespaces[]')
    local existingArray=()
	
	echo -e "${white}"
	info_msg "Restoring ${namespace} settings..."
	echo
	
    if [[ " ${namespacesArray[@]} " =~ "${namespace}" ]]; then
        local responseNamespaceUrl=$(curl -s "$namespaceUrl")
        existingArray=($(echo "$responseNamespaceUrl" | jq -r '.result.value | keys[]'))
    fi
	
	if [[ "${namespace}" == "Fluidd" ]]; then
		local keys=$(jq -r "keys[]" <<< "$(jq -r ".data" "$jsonFile")")
	else
		local keys=$(jq -r 'keys[]' "$jsonFile")
	fi
    
    for key in $keys; do
        if [[ "$key" == "timelapse" || "$key" == "webcams" ]]; then
            local subkeys=$(jq -r "keys[]" <<< "$(jq -r ".${key}" "$jsonFile" 2>/dev/null)" 2>/dev/null)
			if [ -n "$subkeys" ]; then
				if [[ " ${namespacesArray[@]} " =~ "$key" ]]; then
					local url="${baseUrl}?namespace=${key}"
					local response=$(curl -s "$url")
					local objects=$(echo "$response" | jq -r '.result.value | keys[]')
					for item in $objects; do
						echo -e "  Delete ${key}.${item}"
						curl -s -X DELETE "${url}&key=${item}" > /dev/null
					done
				fi

				for key2 in $subkeys; do
					echo -e "  Add ${key}.${item}"
					local value=$(jq -r ".${key}[\"${key2}\"]" "$jsonFile")
					curl -s -X POST "$baseUrl" -H "Content-Type: application/json" -d "{\"namespace\":\"$key\",\"key\":\"$key2\",\"value\":$value}" > /dev/null
				done
			fi
        else
            if [[ " ${existingArray[@]} " =~ "$key" ]]; then
				echo -e "  Delete ${key}"
                curl -s -X DELETE "${namespaceUrl}&key=${key}" > /dev/null
            fi
			echo -e "  Add ${key}"
			if [[ "${namespace}" == "Fluidd" ]]; then
				local value=$(jq -r ".data.${key}" "$jsonFile")
			else
				local value=$(jq -r ".${key}" "$jsonFile")
			fi
            curl -s -X POST "$namespaceUrl" -H "Content-Type: application/json" -d "{\"namespace\":\"${namespace}\",\"key\":\"$key\",\"value\":$value}" > /dev/null
        fi
    done
}

set -e

function web_ui_settings_message(){
    top_line
    title 'Restore Web-UI default settings' "${cyan}"
    inner_line
    hr
    echo -e " │ This allows to restore the pre-configured settings of Mainsail │"
    echo -e " │ and Fluidd Web interfaces.                                     │"
    hr
    bottom_line
}

function restore_web_ui_settings(){
    web_ui_settings_message
    local yn
    while true; do
        read -p "${white}  Are you sure you want to restore ${cyan}Web-UI default settings${white}? (${cyan}y${white}/${cyan}n${white}): ${cyan}" yn
        case "${yn}" in
            Y|y)
            	if [ ! -d "/home/pi/printer_data/config/.theme" ]; then
            		sudo mkdir -p "/home/pi/printer_data/config/.theme"
            	fi
            	cp "/home/pi/flsun-os/installer/files/theme/main-background.png" "/home/pi/printer_data/config/.theme/main-background.png" > /dev/null 2>&1
            	cp "/home/pi/flsun-os/installer/files/theme/sidebar-background.png" "/home/pi/printer_data/config/.theme/sidebar-background.png" > /dev/null 2>&1
            	cp "/home/pi/flsun-os/installer/files/theme/sidebar-logo.png" "/home/pi/printer_data/config/.theme/sidebar-logo.png" > /dev/null 2>&1
            	restoreJSON "/home/pi/flsun-os/installer/files/Backup-Mainsail-FLSUN-S1.json" "http://127.0.0.1:7125" "Mainsail"
            	restoreJSON "/home/pi/flsun-os/installer/files/Backup-Fluidd-FLSUN-S1.json" "http://127.0.0.1:7125" "Fluidd"
            	echo
            	info_msg "Restarting Moonraker service..."
            	restart_moonraker
            	ok_msg "Default Web-UI settings have been restored!"
            	return;;
            N|n)
                error_msg "Restoration canceled!"
                return;;
            *)
                error_msg "Please select a correct choice!";;
        esac
    done
}
