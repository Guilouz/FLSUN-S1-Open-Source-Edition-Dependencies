#!/usr/bin/env python3
# FLSUN S1 Open Source Edition
# Script to merge katapult.bin and klipper.bin

import argparse
import os

def combine_binary_files(file1_path, file2_path, output_path):
    try:
        if not os.path.exists(file1_path):
            raise FileNotFoundError(f"Error: {file1_path} not found! Please compile it first.")
        
        if not os.path.exists(file2_path):
            raise FileNotFoundError(f"Error: {file2_path} not found! Please compile it first.")

        with open(file1_path, "rb") as f1:
            data1 = f1.read()

        with open(file2_path, "rb") as f2:
            data2 = f2.read()

        offset = 0x2000

        combined_data = bytearray(data1)

        if len(combined_data) < offset:
            combined_data.extend([0xFF] * (offset - len(combined_data)))

        combined_data.extend(data2)

        with open(output_path, "wb") as output:
            output.write(combined_data)

        print(f"Firmware saved to: {output_path}")
    except FileNotFoundError as e:
        print(e)
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Merge Katapult Bootloader and Klipper Firmware.")
    
    default_katapult = "/home/pi/katapult/out/katapult.bin"
    default_klipper = "/home/pi/klipper/out/klipper.bin"
    default_output = "/home/pi/motherboard_fw.bin"
    
    parser.add_argument("file1", nargs="?", default=default_katapult, help="Path to katapult.bin (default: /home/pi/katapult/out/katapult.bin)")
    parser.add_argument("file2", nargs="?", default=default_klipper, help="Path to klipper.bin (default: /home/pi/klipper/out/klipper.bin)")
    parser.add_argument("outputfile", nargs="?", default=default_output, help="Output file (default: /home/pi/motherboard_fw.bin)")
    
    args = parser.parse_args()

    combine_binary_files(args.file1, args.file2, args.outputfile)
