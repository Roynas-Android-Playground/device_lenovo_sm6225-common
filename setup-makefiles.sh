#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Initialize the helper for common
setup_vendor "${DEVICE_COMMON}" "${VENDOR}" "${ANDROID_ROOT}" true

# Warning headers and guards
write_headers "tb128fu"

# The standard common blobs
write_makefiles "${MY_DIR}/proprietary-files.txt" true

# Finish
write_footers

# Recovery
if [ -s "${MY_DIR}/proprietary-files-recovery.txt" ]; then
    echo "" >> $PRODUCTMK
    write_makefiles "${MY_DIR}/proprietary-files-recovery.txt" true
fi

if [ -s "${MY_DIR}/../${DEVICE}/proprietary-files.txt" ]; then
    # Reinitialize the helper for device
    setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false

    # Warning headers and guards
    write_headers

    # The standard device blobs
    write_makefiles "${MY_DIR}/../${DEVICE}/proprietary-files.txt" true

    # Finish
    write_footers

    # Recovery
    if [ -s "${MY_DIR}/../${DEVICE}/proprietary-files-recovery.txt" ]; then
	echo "" >> $PRODUCTMK
    	write_makefiles "${MY_DIR}/../${DEVICE}/proprietary-files-recovery.txt" true
    fi

    echo "TARGET_RECOVERY_DEVICE_DIRS += vendor/$VENDOR/$DEVICE/proprietary" >> "$BOARDMK"
fi
