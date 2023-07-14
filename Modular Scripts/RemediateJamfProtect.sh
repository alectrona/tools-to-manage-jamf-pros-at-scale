#!/bin/bash

protectTenant="$4"
protectGUID="$5"

uuid=$(/usr/bin/uuidgen)
workDir="/private/tmp/$uuid"
uninstallURL="https://${protectTenant}.protect.jamfcloud.com/uninstaller.pkg?${protectGUID}"
installURL="https://${protectTenant}.protect.jamfcloud.com/installer.pkg?${protectGUID}"
unset version

function clean_up() {
    echo "Cleaning up installation files..."
    /bin/rm -Rf "$workDir"
    /bin/ps -p "$caffeinatePID" > /dev/null && /bin/kill "$caffeinatePID"; wait "$caffeinatePID" 2>/dev/null
}

# Clean up our temporary files upon exiting at any time
trap "clean_up" EXIT

# Caffeinate the Mac so it does not sleep
/usr/bin/caffeinate -d -i -m -u &
caffeinatePID=$!

# Make our working directory with our unique UUID generated in the variables section
/bin/mkdir -p "$workDir"

# If tenant or guid is empty then exit
if [[ -z "$protectTenant" ]] || [[ -z "$protectGUID" ]]; then
    echo "Error: Required parameter(s) are empty - protectTenant (parameter 4) or protectGUID (parameter 5); exiting."
    exit 1
fi

# Uninstall Jamf Protect if installed
if [[ -e /Applications/JamfProtect.app ]]; then

    echo "Jamf Protect is installed; downloading uninstaller..."
    if ! /usr/bin/curl -s -L -f "$uninstallURL" -o "$workDir/uninstaller.pkg" ; then
        echo "Error: Failed to download uninstaller ; exiting."
        exit 3
    fi

    echo "Running the uninstaller..."
    if ! /usr/sbin/installer -pkg "$workDir/uninstaller.pkg" -target / ; then
        echo "Uninstall failed; exiting."
        exit 4
    fi
fi

# Exit if there was an error with the curl
echo "Downloading the Jamf Protect installer..."
if ! /usr/bin/curl -s -L -f "$installURL" -o "$workDir/installer.pkg" ; then
    echo "Error while downloading the Jamf Protect installer; exiting."
    exit 5
fi

# Exit if the PKG errored during install
if ! /usr/sbin/installer -pkg "$workDir/installer.pkg" -target / ; then
    echo "Failed to install Jamf Protect; exiting."
    exit 6
fi

version=$(/usr/local/bin/protectctl version | awk '{print $NF}')
echo "Successfully installed Jamf Protect version: $version."

exit 0