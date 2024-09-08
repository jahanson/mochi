#!/usr/bin/env bash

find_usb_device() {
    local idVendor=$1
    local idProduct=$2
    local device_id="${idVendor}:${idProduct}"

    for device in /sys/bus/usb/devices/*; do
        if [ -f "$device/idVendor" ] && [ -f "$device/idProduct" ]; then
            vendor=$(cat "$device/idVendor")
            product=$(cat "$device/idProduct")
            if [ "${vendor}:${product}" = "$device_id" ]; then
                echo "$device"
                return 0
            fi
        fi
    done

    return 1
}

# Example usage
idVendor="27c6"
idProduct="609c"

device_path=$(find_usb_device "$idVendor" "$idProduct")

if [ -n "$device_path" ]; then
    echo "Device found at: $device_path"

    # Print additional information
    manufacturer=$(cat "$device_path/manufacturer" 2>/dev/null)
    product=$(cat "$device_path/product" 2>/dev/null)

    echo "Manufacturer: ${manufacturer:-N/A}"
    echo "Product: ${product:-N/A}"
else
    echo "Device not found"
fi
