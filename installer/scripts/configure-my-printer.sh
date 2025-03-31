#!/bin/bash
# FLSUN S1 Open Source Edition

CONFIG_DIR="/home/pi/printer_data/config"

function configure_my_printer_message(){
    top_line
    title 'Configure my printer' "${cyan}"
    inner_line
    hr
    echo -e " │ Configure your printer with features you need.                 │"
    hr
    bottom_line
}

function configure_my_printer(){
    configure_my_printer_message
    local yn
    while true; do
        read -p "${white}  Do you want to configure your printer? (${cyan}y${white}/${cyan}n${white}): ${cyan}" yn
        case "${yn}" in
            Y|y)
                echo -e "${white}"
                while true; do
                    read -p "${white}  Do you use Silent Fan Upgrade Kit (CPAP less noisy) or S1 Pro? (${cyan}y${white}/${cyan}n${white}): ${cyan}" choice1
                    case "${choice1}" in
                        Y|y)
                            edit_config disable "include Configurations/fan-stock.cfg" config > /dev/null 2>&1
                            edit_config enable "include Configurations/fan-silent-kit.cfg" config > /dev/null 2>&1
                            ok_msg "Silent Fan configurations enabled!"
                            break;;
                        N|n)
                            edit_config enable "include Configurations/fan-stock.cfg" config > /dev/null 2>&1
                            edit_config disable "include Configurations/fan-silent-kit.cfg" config > /dev/null 2>&1
                            ok_msg "Stock Fan configurations enabled!"
                            break;;
                        *)
                            error_msg "Please select a correct choice!";;
                    esac
                done
                while true; do
                    read -p "${white}  Do you want to control Camera settings with macros? (${cyan}y${white}/${cyan}n${white}): ${cyan}" choice2
                    case "${choice2}" in
                        Y|y)
                            edit_config enable "include Configurations/camera-control.cfg" config > /dev/null 2>&1
                            ok_msg "Camera Control configurations enabled!"
                            break;;
                        N|n)
                            edit_config disable "include Configurations/camera-control.cfg" config > /dev/null 2>&1
                            ok_msg "Camera Control configurations disabled!"
                            break;;
                        *)
                            error_msg "Please select a correct choice!";;
                    esac
                done
                while true; do
                    read -p "${white}  Do you want to enable Timelapse feature? (${cyan}y${white}/${cyan}n${white}): ${cyan}" choice3
                    case "${choice3}" in
                        Y|y)
                            edit_config enable "include timelapse.cfg" config > /dev/null 2>&1
                            edit_config enable "timelapse" moonraker > /dev/null 2>&1
                            edit_config enable "update_manager Timelapse" moonraker > /dev/null 2>&1
                            ln -srfn "/home/pi/moonraker-timelapse/klipper_macro/timelapse.cfg" "$CONFIG_DIR/timelapse.cfg" > /dev/null 2>&1
                            ok_msg "Timelapse feature enabled!"
                            break;;
                        N|n)
                            edit_config disable "include timelapse.cfg" config > /dev/null 2>&1
                            edit_config disable "timelapse" moonraker > /dev/null 2>&1
                            edit_config disable "update_manager Timelapse" moonraker > /dev/null 2>&1
                            if [ -f "$CONFIG_DIR/timelapse.cfg" ]; then
                                rm -f "$CONFIG_DIR/timelapse.cfg" > /dev/null 2>&1
                            fi
                            ok_msg "Timelapse feature disabled!"
                            break;;
                        *)
                            error_msg "Please select a correct choice!";;
                    esac
                done
                while true; do
                    read -p "${white}  Do you want to enable Klipper Print Time Estimator feature? (${cyan}y${white}/${cyan}n${white}): ${cyan}" choice4
                    case "${choice4}" in
                        Y|y)
                            edit_config enable "analysis" moonraker > /dev/null 2>&1
                            ok_msg "Klipper Print Time Estimator feature enabled!"
                            break;;
                        N|n)
                            edit_config disable "analysis" moonraker > /dev/null 2>&1
                            ok_msg "Klipper Print Time Estimator feature disabled!"
                            break;;
                        *)
                            error_msg "Please select a correct choice!";;
                    esac
                done
                while true; do
                    read -p "${white}  Do you use BigTreeTech MMB Cubic? (${cyan}y${white}/${cyan}n${white}): ${cyan}" choice5
                    case "${choice5}" in
                        Y|y)
                            MMB_CUBIC=$(find /dev/serial/by-id/ -name 'usb-Klipper_rp2040*' 2>/dev/null | head -n 1)
                            if [[ -n "$MMB_CUBIC" ]]; then
                                edit_config enable "mcu MMB_Cubic" config > /dev/null 2>&1
                                sed -i "s|^serial: /dev/serial/by-id/usb-Klipper_rp2040_.*|serial: $MMB_CUBIC|" "$CONFIG_DIR/config.cfg" > /dev/null 2>&1
                                ok_msg "MMB Cubic configured with serial: $MMB_CUBIC"
                                while true; do
                                    read -p "${white}  Do you use Chamber Temperature Sensor? (${cyan}y${white}/${cyan}n${white}): ${cyan}" choice6
                                    case "${choice6}" in
                                        Y|y)
                                            edit_config enable "include Configurations/temp-sensor-mmb-cubic.cfg" config > /dev/null 2>&1
                                            ok_msg "Chamber Temperature Sensor configurations enabled!"
                                            break;;
                                        N|n)
                                            edit_config disable "include Configurations/temp-sensor-mmb-cubic.cfg" config > /dev/null 2>&1
                                            ok_msg "Chamber Temperature Sensor configurations not enabled!"
                                            break;;
                                        *)
                                            error_msg "Please select a correct choice!";;
                                    esac
                                done
                                while true; do
                                    read -p "${white}  Do you use Neopixels LEDs? (${cyan}y${white}/${cyan}n${white}): ${cyan}" choice7
                                    case "${choice7}" in
                                        Y|y)
                                            edit_config disable "include Configurations/led-stock.cfg" config > /dev/null 2>&1
                                            edit_config enable "include Configurations/led-mmb-cubic.cfg" config > /dev/null 2>&1
                                            ok_msg "Neopixels LEDs configurations enabled!"
                                            while true; do
                                                read -p "${white}  Enter the number of LEDs used: ${cyan}" led_count
                                                if [[ "$led_count" =~ ^[0-9]+$ ]]; then
                                                    sed -i "s|^chain_count: [0-9]*|chain_count: $led_count|" "$CONFIG_DIR/Configurations/led-mmb-cubic.cfg" > /dev/null 2>&1
                                                    ok_msg "LEDs count set to $led_count!"
                                                    break
                                                else
                                                    error_msg "Please enter a valid number!"
                                                fi
                                            done
                                            break;;
                                        N|n)
                                            edit_config enable "include Configurations/led-stock.cfg" config > /dev/null 2>&1
                                            edit_config disable "include Configurations/led-mmb-cubic.cfg" config > /dev/null 2>&1
                                            ok_msg "Neopixels LED configurations not enabled!"
                                            break;;
                                        *)
                                            error_msg "Please select a correct choice!";;
                                    esac
                                done
                                #while true; do
                                #    read -p "${white}  Do you use Load Cell Probe feature? (${cyan}y${white}/${cyan}n${white}): ${cyan}" choice8
                                #    case "${choice8}" in
                                #        Y|y)
                                #            edit_config disable "include Configurations/probe-stock.cfg" config > /dev/null 2>&1
                                #            edit_config enable "include Configurations/probe-mmb-cubic.cfg" config > /dev/null 2>&1
                                #            ok_msg "Load Cell Probe feature enabled!"
                                #            break;;
                                #        N|n)
                                #            edit_config enable "include Configurations/probe-stock.cfg" config > /dev/null 2>&1
                                #            edit_config disable "include Configurations/probe-mmb-cubic.cfg" config > /dev/null 2>&1
                                #            ok_msg "Load Cell Probe feature not enabled!"
                                #            break;;
                                #        *)
                                #            error_msg "Please select a correct choice!";;
                                #    esac
                                #done
                                break
                            else
                                error_msg "No MMB Cubic device found! Please check the connection."
                                break
                            fi
                            break;;
                        N|n)
                            edit_config disable "mcu MMB_Cubic" config > /dev/null 2>&1
                            sed -i "s|^\#\serial: /dev/serial/by-id/usb-Klipper_rp2040_.*|#serial: /dev/serial/by-id/usb-Klipper_rp2040_xxxxx|" "$CONFIG_DIR/config.cfg" > /dev/null 2>&1
                            edit_config disable "include Configurations/temp-sensor-mmb-cubic.cfg" config > /dev/null 2>&1
                            edit_config enable "include Configurations/led-stock.cfg" config > /dev/null 2>&1
                            edit_config disable "include Configurations/led-mmb-cubic.cfg" config > /dev/null 2>&1
                            #edit_config enable "include Configurations/probe-stock.cfg" config > /dev/null 2>&1
                            #edit_config disable "include Configurations/probe-mmb-cubic.cfg" config > /dev/null 2>&1
                            ok_msg "BigTreeTech MMB Cubic features disabled!"
                            break;;
                        *)
                            error_msg "Please select a correct choice!";;
                    esac
                done
                while true; do
                    read -p "${white}  Do you use BigTreeTech Smart Filament Sensor V2.0? (${cyan}y${white}/${cyan}n${white}): ${cyan}" choice9
                    case "${choice9}" in
                        Y|y)
                            edit_config disable "include Configurations/filament-sensor-stock.cfg" config > /dev/null 2>&1
                            edit_config enable "include Configurations/filament-sensor-sfs.cfg" config > /dev/null 2>&1
                            ok_msg "BigTreeTech Smart Filament Sensor V2.0 configurations enabled!"
                            break;;
                        N|n)
                            edit_config enable "include Configurations/filament-sensor-stock.cfg" config > /dev/null 2>&1
                            edit_config disable "include Configurations/filament-sensor-sfs.cfg" config > /dev/null 2>&1
                            ok_msg "BigTreeTech Smart Filament Sensor V2.0 configurations not enabled!"
                            break;;
                        *)
                            error_msg "Please select a correct choice!";;
                    esac
                done
                info_msg "Restarting Moonraker service..."
                restart_moonraker
                echo
                info_msg "Restarting Klipper service..."
                restart_klipper
                ok_msg "Your printer has been configured successfully!\n    Please recalibrate your printer."
                return;;
            N|n)
                error_msg "Configuration canceled!"
                return;;
            *)
                error_msg "Please select a correct choice!";;
        esac
    done
}
