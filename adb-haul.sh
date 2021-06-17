#!/bin/bash
# Author:       sickcodes
# Contact:      https://twitter.com/sickcodes
# Copyright:    sickcodes (C) 2021
# License:      GPLv3+
# Project:      https://github.com/sickcodes/adb-download-all

# IGNORE_DIRS=(
# '.'
# './proc'
# './dev'
# './sys'
# )

# OUTPUT_DIR="${PWD}"
OUTPUT_DIR=./output

mkdir -p "${OUTPUT_DIR}"

ROOT_DIRS=($(adb shell find -maxdepth 1))

for ROOT_DIR in "${ROOT_DIRS[@]}"; do {

    # skip directories from IGNORE_DIRS
    # [[ -n "${IGNORE_DIRS["${ROOT_DIR}"]}" ]] && continue

    case "${ROOT_DIR}" in
        '.' )         continue
            ;;
        './proc' )    continue
            ;;
        './dev' )     continue
            ;;
        './sys' )     continue
            ;;
    esac

    echo "### Pulling directory: ${ROOT_DIR}"

    # find all files in the next folder and enter into an array
    unset FILES
    readarray -t FILES <<< "$(adb shell find "${ROOT_DIR}/" 2>/dev/null)"

    echo "${FILES[@]}"

    for FILE in "${FILES[@]}"; do {
        OUTPUT_FILE="${OUTPUT_DIR}/${FILE}"
        # create directories, rather than pull them
        # skip symbolic links
        case "$(adb shell file "${FILE}")" in
            *directory* )   mkdir -p "${OUTPUT_FILE}" && continue
                ;;
            *symbolic* )    continue
                ;;
            * )             touch "${OUTPUT_FILE}"
                ;;
        esac
        # base64 encrypt and decrypt the file to the output directory
        base64 -d <<< "$(adb shell "base64 <  \"${FILE}\"")" > "${OUTPUT_FILE}"
    }
    done
}
done