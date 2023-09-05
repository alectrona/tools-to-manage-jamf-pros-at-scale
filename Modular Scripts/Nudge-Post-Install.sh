#!/bin/bash

####################################################################################################
#
#    Nudge Post-install
#
#    Purpose: Configures Nudge to company standards post-install
#    https://github.com/dan-snelson/Nudge-Post-install/wiki
#
####################################################################################################
#
#  Based on version 0.0.17, 03-Jan-2023, Dan K. Snelson (@dan-snelson)
#  - Updates for Nudge [`1.1.10`](https://github.com/macadmins/nudge/pull/435)
#  - Modified for Alectrona Jamf Deployment [6-7-2023 - Andrew Myers]
#  Version 1.2.0, 30-Aug-2023, Andrew Myers
#  - Modified for Alectrona URL based JSON deployment
#
####################################################################################################

####################################################################################################
#
# Initial Variables Setup
#
####################################################################################################

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Global Variables
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

scriptVersion="1.2.0"
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin/
loggedInUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
defaultJSONURL="https://your.available.url.json"
plistDomain="${4:-"com.alectrona"}"                   # Reverse Domain Name Notation (i.e., "com.alectrona")
resetConfiguration="${5:-"All"}"                      # Configuration Files to Reset (i.e., None (blank) | All (default) | JSON | LaunchAgent | LaunchDaemon)
launchInterval="${6:-"7200"}"                         # LaunchAgent - 2 Hour (7200 seconds) by default
nudgeJSONURL="${7:-"$defaultJSONURL"}"                # JSON Nudge Array (https://your.available.url.json)

scriptLog="/var/log/${plistDomain}.NudgePostInstall.log"
jsonPath="/Library/Preferences/${plistDomain}.Nudge.json"
launchAgentPath="/Library/LaunchAgents/${plistDomain}.Nudge.plist"
launchDaemonPath="/Library/LaunchDaemons/${plistDomain}.Nudge.logger.plist"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Set deadline variable based on OS version, use for Sonoma
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# deadline="${requiredInstallationDate}"

# osProductVersion=$( sw_vers -productVersion )
# case "${osProductVersion}" in
#     12* ) deadline="${requiredMontereyInstallationDate}"    ;;
#     13* ) deadline="${requiredVenturaInstallationDate}"  ;;
#     14* ) deadline="${requiredSonomaInstallationDate}"   ;;
# esac

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Validate logged-in user
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

if [[ -z "${loggedInUser}" || "${loggedInUser}" == "loginwindow" ]]; then
    echo "No user logged-in; exiting."
    exit #1
else
    loggedInUserID=$(id -u "${loggedInUser}")
fi

####################################################################################################
#
# Functions
#
####################################################################################################

function updateScriptLog() {
    # Client-side Script Logging
    echo -e "$( date +%Y-%m-%d\ %H:%M:%S ) - ${1}" | tee -a "${scriptLog}"
}

function runAsUser() {
    # Run command as logged-in user (thanks, @scriptingosx!)
    updateScriptLog "Run \"$@\" as \"$loggedInUserID\" … "
    launchctl asuser "$loggedInUserID" sudo -u "$loggedInUser" "$@"
}

function killNudgeProcess(){
    # Make sure Nudge stops running (in case aggresive mode may be active, or whether deadline has passed)
    updateScriptLog "Stopping Nudge process..."
    pkill -l -U "${loggedInUser}" nudge
    updateScriptLog "Stopped Nudge process"
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Reset Configurations
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

function clearOGNudgeLaunchAgent(){
    # Original LaunchAgent filename and location
    launch_agent_plist_name='com.github.macadmins.Nudge.plist'
    launch_agent_base_path='/Library/LaunchAgents/'
    launch_agent_full_path=$launch_agent_base_path$launch_agent_plist_name
    # Current console user information
    console_user=$(/usr/bin/stat -f "%Su" /dev/console)
    console_user_uid=$(/usr/bin/id -u "$console_user")
    
    if [[ ! -f ${launch_agent_full_path} ]]; then
        echo "No older setup, continuing"
    else
        # Unload the agent so it can be triggered on re-install
        /bin/launchctl asuser "${console_user_uid}" /bin/launchctl unload -w "${launch_agent_base_path}${launch_agent_plist_name}"
        # Kill Nudge just in case (say someone manually opens it and not launched via launchagent
        /usr/bin/killall Nudge
        # Delete the launch agent
        rm -f "${launch_agent_full_path}"
    fi
}

function resetLocalUserPreferences(){
    # For testing only; see:
    # * https://github.com/macadmins/nudge/wiki/User-Deferrals#resetting-values-when-a-new-nudge-event-is-detected
    # * https://github.com/macadmins/nudge/wiki/User-Deferrals#testing-and-resetting-nudge

    updateScriptLog "Removing User Preferences (/Users/${loggedInUser}/Library/Preferences/${plistDomain}.Nudge.plist)"
    rm -f /Users/"${loggedInUser}"/Library/Preferences/"${plistDomain}".Nudge.plist 2>&1
    updateScriptLog "Stopping Core Foundation Preferences daemon … "
    pkill -l -U "${loggedInUser}" cfprefsd
    updateScriptLog "Removed User Preferences"
}

function resetLocalJSON(){
    updateScriptLog "Removing ${jsonPath} … "
    rm -f "${jsonPath}" 2>&1
    updateScriptLog "Removed ${jsonPath}"
}

function resetLaunchAgent(){
    updateScriptLog "Unloading ${launchAgentPath} … "
    runAsUser launchctl unload -w "${launchAgentPath}" 2>&1
    updateScriptLog "Removing ${launchAgentPath} … "
    rm -f "${launchAgentPath}" 2>&1
    updateScriptLog "Removed ${launchAgentPath}"
}

function resetLaunchDaemon(){
    updateScriptLog "Unloading ${launchDaemonPath} … "
    /bin/launchctl unload -w "${launchDaemonPath}" 2>&1
    updateScriptLog "Removing ${launchDaemonPath} … "
    rm -f "${launchDaemonPath}" 2>&1
    updateScriptLog "Removed ${launchDaemonPath}"
}

function hideNudgeInFinder(){
    updateScriptLog "Hiding Nudge in Finder … "
    chflags hidden "/Applications/Utilities/Nudge.app" 
    updateScriptLog "Hid Nudge in Finder"
}

function hideNudgeInLaunchpad(){
    updateScriptLog "Hiding Nudge in Launchpad … "
    if [[ -z "$loggedInUser" ]]; then
        updateScriptLog "Did not detect logged-in user"
    else
        sqlite3 $(sudo find /private/var/folders \( -name com.apple.dock.launchpad -a -user ${loggedInUser} \) 2> /dev/null)/db/db "DELETE FROM apps WHERE title='Nudge';"
        killall Dock
        updateScriptLog "Hid Nudge in Launchpad for ${loggedInUser}"
    fi
}

function resetConfiguration() {

    killNudgeProcess

    updateScriptLog "Reset Configuration: ${1}"

    case ${1} in

        "All" )
            # Reset JSON, LaunchAgent, LaunchDaemon, Hide Nudge in Launchpad
            updateScriptLog "Reset All Configuration Files … "
            clearOGNudgeLaunchAgent
            resetLocalUserPreferences
            resetLocalJSON
            resetLaunchAgent
            resetLaunchDaemon
            hideNudgeInLaunchpad

            updateScriptLog "Reset All Configuration Files"
            ;;

        "Uninstall" )
           # Uninstall Nudge Post-install
            updateScriptLog "Uninstalling Nudge Post-install … "
            clearOGNudgeLaunchAgent
            resetLocalJSON
            resetLaunchAgent
            resetLaunchDaemon

            # Exit
            updateScriptLog "Uninstalled all Nudge Post-install configuration files"
            updateScriptLog "Thanks for using Nudge Post-install!"
            exit 0
            ;;

        "JSON" )
            # Reset JSON
            resetLocalJSON
            ;;

        "LaunchAgent" )
            # Reset LaunchAgent
            clearOGNudgeLaunchAgent
            resetLaunchAgent
            ;;

        "LaunchDaemon" )
            resetLaunchDaemon
            ;;

        * )
            # None of the expected options was entered; don't reset anything
            updateScriptLog "None of the expected reset options was entered; don't reset anything"
            ;;

    esac

}

####################################################################################################
#
# Program
#
####################################################################################################

# Client-side Logging
if [[ ! -f "${scriptLog}" ]]; then
    touch "${scriptLog}"
    updateScriptLog "*** Created log file ***"
fi

# Logging preamble
updateScriptLog "Nudge Post-install (${scriptVersion})"

# Reset Configuration
resetConfiguration "${resetConfiguration}"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Nudge Logger LaunchDaemon
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

if [[ ! -f ${launchDaemonPath} ]]; then

    updateScriptLog "Create ${launchDaemonPath} … "

    cat <<EOF > "${launchDaemonPath}"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${plistDomain}.Nudge.Logger</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/log</string>
        <string>stream</string>
        <string>--predicate</string>
        <string>subsystem == 'com.github.macadmins.Nudge'</string>
        <string>--style</string>
        <string>syslog</string>
        <string>--color</string>
        <string>none</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/var/log/${plistDomain}.log</string>
</dict>
</plist>
EOF

    /bin/launchctl load -w "${launchDaemonPath}" 2>&1

else
    updateScriptLog "${launchDaemonPath} exists"
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Nudge LaunchAgent
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

if [[ ! -f ${launchAgentPath} ]]; then

    updateScriptLog "Create ${launchAgentPath} … "

    cat <<EOF > "${launchAgentPath}"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>AssociatedBundleIdentifiers</key>
	<array>
		<string>com.github.macadmins.Nudge</string>
	</array>
    <key>Label</key>
    <string>${plistDomain}.Nudge.plist</string>
    <key>LimitLoadToSessionType</key>
    <array>
        <string>Aqua</string>
    </array>
    <key>ProgramArguments</key>
    <array>
        <string>/Applications/Utilities/Nudge.app/Contents/MacOS/Nudge</string>
        <string>-json-url</string>
        <string>${nudgeJSONURL}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StartInterval</key>
    <integer>${launchInterval}</integer>
</dict>
</plist>
EOF

    updateScriptLog "Created ${launchAgentPath}"
    updateScriptLog "Set ${launchAgentPath} file permissions ..."
    chown root:wheel "${launchAgentPath}"
    chmod 644 "${launchAgentPath}"
    chmod +x "${launchAgentPath}"
    updateScriptLog "Set ${launchAgentPath} file permissions"

else
    updateScriptLog "${launchAgentPath} exists"
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Load Nudge LaunchAgent
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# https://github.com/macadmins/nudge/blob/main/build_assets/postinstall-launchagent
# Only enable the LaunchAgent if there is a user logged in, otherwise rely on built in LaunchAgent behavior
if [[ -z "$loggedInUser" ]]; then
    updateScriptLog "Did not detect user"
elif [[ "$loggedInUser" == "loginwindow" ]]; then
    updateScriptLog "Detected Loginwindow Environment"
elif [[ "$loggedInUser" == "_mbsetupuser" ]]; then
    updateScriptLog "Detect SetupAssistant Environment"
elif [[ "$loggedInUser" == "root" ]]; then
    updateScriptLog "Detect root as currently logged-in user"
else
    # Unload the LaunchAgent so it can be triggered on re-install
    runAsUser launchctl unload -w "${launchAgentPath}"
    # Kill Nudge just in case (say someone manually opens it and not launched via LaunchAgent
    killall Nudge
    # Load the LaunchAgent
    runAsUser launchctl load -w "${launchAgentPath}"
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Exit
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

updateScriptLog "Goodbye!"

exit 0
