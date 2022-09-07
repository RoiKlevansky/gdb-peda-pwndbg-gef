#!/bin/bash

DEST_FILE="${PWD}/.install_path"

installer_path=$PWD
dest_path="${1:-"${HOME}"}"	# Installation destination path
dest_path="${dest_path%/}/"	# Add trailing slash if needed

echo "[+] Checking access to ${dest_path}..."
if [[ ! -e "${dest_path}" ]]; then
	echo "[-] Destination doesn't exist! Aborting..." 1>&2
	exit 1
elif [[ ! -w "${dest_path}" ]]; then
	echo "[-] Can't write to destination! Aborting..." 1>&2
	exit 1
else
	echo -n "${dest_path}" > "${DEST_FILE}"
	echo "[-] Destination exists and writeable"
fi

echo "[+] Checking for required dependencies..."
if command -v git > /dev/null 2>&1; then
    echo "[-] Git found!"
else
    echo "[-] Git not found! Aborting..." 1>&2
    echo "[-] Please install git and try again." 1>&2
    exit 1
fi

if [ -f ~/.gdbinit ] || [ -h ~/.gdbinit ]; then
    echo "[+] backing up gdbinit file"
    cp ~/.gdbinit ~/.gdbinit.back_up
fi

# download peda and decide whether to overwrite if exists
if [ -d "${dest_path}peda" ] || [ -h ~/.peda ]; then
    echo "[-] PEDA found"
    read -p "skip download to continue? (enter 'y' or 'n') " skip_peda

    if [ $skip_peda = 'n' ]; then
        rm -rf "${dest_path}peda"
        git clone https://github.com/longld/peda.git "${dest_path}peda"
    else
        echo "PEDA skipped"
    fi
else
    echo "[+] Downloading PEDA..."
    git clone https://github.com/longld/peda.git "${dest_path}peda"
fi

# download peda arm
if [ -d "${dest_path}peda-arm" ] || [ -h ~/.peda ]; then
    echo "[-] PEDA ARM found"
    read -p "skip download to continue? (enter 'y' or 'n') " skip_peda

    if [ $skip_peda = 'n' ]; then
        rm -rf "${dest_path}peda-arm"
	git clone https://github.com/alset0326/peda-arm.git "${dest_path}peda-arm"
    else
	echo "PEDA ARM skipped"
    fi
else	    
    echo "[+] Downloading PEDA ARM..."
    git clone https://github.com/alset0326/peda-arm.git "${dest_path}peda-arm"
fi

# download pwndbg
if [ -d "${dest_path}pwndbg" ] || [ -h ~/.pwndbg ]; then
    echo "[-] Pwndbg found"
    read -p "skip download to continue? (enter 'y' or 'n') " skip_pwndbg

    if [ $skip_pwndbg = 'n' ]; then
        rm -rf "${dest_path}pwndbg"
        git clone https://github.com/pwndbg/pwndbg.git "${dest_path}pwndbg"

        cd "${dest_path}pwndbg"
        ./setup.sh
    else
        echo "Pwndbg skipped"
    fi
else
    echo "[+] Downloading Pwndbg..."
    git clone https://github.com/pwndbg/pwndbg.git "${dest_path}pwndbg"
    
    cd "${dest_path}pwndbg"
    ./setup.sh
fi

# download gef FIXME: This aint right.
echo "[+] Downloading GEF..."
git clone https://github.com/hugsy/gef.git "${dest_path}gef"

cd $installer_path

echo "[+] Setting .gdbinit..."
cp gdbinit ~/.gdbinit
sed -i "s%^source ~/%source ${dest_path}%g" ~/.gdbinit

{
  echo "[+] Creating files..."
    sudo cp gdb-peda /usr/bin/gdb-peda &&\
    sudo cp gdb-peda-arm /usr/bin/gdb-peda-arm &&\
    sudo cp gdb-peda-intel /usr/bin/gdb-peda-intel &&\
    sudo cp gdb-pwndbg /usr/bin/gdb-pwndbg &&\
    sudo cp gdb-gef /usr/bin/gdb-gef
} || {
  echo "[-] Permission denied"
    exit
}

{
  echo "[+] Setting permissions..."
    sudo chmod +x /usr/bin/gdb-*
} || {
  echo "[-] Permission denied"
    exit
}

echo "[+] Done"
