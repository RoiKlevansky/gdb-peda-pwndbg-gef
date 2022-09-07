#!/bin/bash

DEST_FILE="${PWD}/.install_path"

dest_path="${1:-$(cat "${DEST_FILE}" 2> /dev/null)}"	# Priority: 1. args, 2. file, 3. fallback
dest_path="${dest_path:-"${HOME}"}"           		# Set fallback in case var is unset
dest_path="${dest_path%/}/"     			# Add trailing slash if needed

echo "[+] Checking access to ${dest_path}..."
if [[ ! -e "${dest_path}" ]]; then
        echo "[-] Destination doesn't exist! Aborting..." 1>&2
	rm "${DEST_FILE}" > /dev/null 2>&1
        exit 1
elif [[ ! -w "${dest_path}" ]]; then
        echo "[-] Can't write to destination! Aborting..." 1>&2
	rm "${DEST_FILE}" > /dev/null 2>&1
        exit 1
else
        echo -n "${dest_path}" > "${DEST_FILE}"
        echo "[-] Destination exists and writeable"
fi

echo "[+] Updating PEDA..."
cd "${dest_path}peda"
git pull

echo "[+] Updating PEDA-ARM..."
cd "${dest_path}peda-arm"
git pull

echo "[+] Updating Pwndbg..."
cd "${dest_path}pwndbg"
git pull

echo "[+] Updating GEF..."
cd "${dest_path}gef"
git pull
