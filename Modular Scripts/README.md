# Modular Scripts
## [Automated Deployment with swiftDialog and SetupYourMac](#automated-deployment-with-swiftdialog-and-setupyourmac)
## [Automated Deployment with DEPNotify](https://github.com/alectrona/automated-deployment)
## [Remediate Jamf Protect](#remediate-jamf-protect-1)
## [Nudge Post Install](#nudge-post-install-1)


### Alectrona Automated Deployment with swiftDialog and SetupYourMac
An easy to configure automated deployment workflow for macOS leveraging Jamf Pro and DEPNotify.

#### Features
* Automatically downloads and installs [swiftDialog](https://github.com/bartreardon/swiftDialog) so you don't have to.
* Allows for custom branding for your organization including downloading a custom logo of your choosing from the web to display in swiftDialog/SetupYourMac.
* Installs [Rosetta 2](https://support.apple.com/en-us/HT211861) by default on Apple Silicon Macs prior to running Jamf Pro policies.
* Being completely configured using Jamf Pro script parameters in a JSON, the same script can be used in multiple policies without changing the script itself.
* Allows for a Debug Mode option so you can test the workflow without making any changes to the Mac.

#### Deploy with Jamf Pro
1. Add the [automated-deployment.sh](automated-deployment.sh) script to your Jamf Pro server and set up the Parameter Labels by referencing [Jamf Pro Parameters](#jamf-pro-parameters).
2. Create a Jamf Pro policy using the following options:
    1. Options > General > Trigger: `Enrollment Complete`.
    2. Options > General > Execution Frequency: `Ongoing`.
    3. Options > Scripts > Add the script you created in Step 1 and configure the Parameters by referencing [Jamf Pro Parameters](#jamf-pro-parameters).
    4. Scope > Define a target for the policy. *Typically in production this would be "All Computers"*.
3. Enroll a computer and test.

#### Jamf Pro Parameters
When adding the script to Jamf Pro, you will configure the labels for Parameters 4 through 9 using the information below. Additionally, the descriptions below will help you populate the Parameters within your Jamf Pro policy.

| Parameter | Parameter Label | Description |
| ----------- | --------------- | ----------- |
| Parameter 4 | Debug Mode (`true`\|`false`) | Set to `true` to test the workflow without making any changes to the Mac. Leaving this parameter empty will default to `true`. |
| Parameter 5 | Company | The company name to display in SetupYourMac. |
| Parameter 6 | Welcome Dialog (`true`\|`false`) | Set to `true` to prompt the user to enter Departmental information. Leaving this parameter emtpy will default to `false`. Requires Parameters 9 and 10|
| Parameter 7 | Completion Action |Set the action to take after then enrollment has completed. Options include `wait`, `sleep (with seconds)`, `Shut Down`, or `Restart`. Leaving this parameter empty will default to `wait`. |
| Parameter 8 | JSON Policy Array URL | A specifically formatted JSON that combines SetupYourMac Status and Jamf Pro policy Custom Events. See [Policy JSON Array](#policy-detail-json) for more details. |
| Parameter 9 | JamfPro API User | Set to your API User account with permissions to `Read` and `Update` Computers and `Read` Departments. Leaving this parameter empty will default to `false`. |
| Parameter 10 | Encrypted API Password | Set to the encrypted password of your Jamf Pro API User. |

#### Policy JSON Array
The Policy JSON Array is a specifically formatted JSON that combines SetupYourMac Status and Jamf Pro policy Custom Events. This allows you to configure just one parameter, but define many policies to execute. Consequently, this eliminates the need to have separate copies of the same script for use with different workflows within your environment. The JSON needs to be hosted at a known, accessible URL. This allows for greater flexibility with editing and deploying to other environments.

Lets break down the following Policy JSON Array
```json
{
	"listitem": "1Password",
	"icon": "7be8817a86bec512832573c0f4e6f1c027a520bcead4f2a231d16e59c17d76d8",
	"progresstext": "A password manager, digital vault, form filler and secure digital wallet. 1Password remembers all your passwords for you to help keep account information safe.",
	"trigger_list": [
		{
			"trigger": "1password",
			"validation": "/Applications/1Password.app/Contents/Info.plist"
		}
	]
},
```
* `listitem`: The text to be displayed in the list
* `icon`: The hash of the icon to be displayed on the left
* `progresstext`: The text to be displayed below the progress bar
* `trigger`: The Jamf Pro Policy Custom Event Name
* `validation`: [ `{absolute path}` | `Local` | `Remote` | `None` ]

Note: You can validate the JSON by copying everything between the beginning and ending curly braces { … } and pasting at jsonlint.com

### Remediate Jamf Protect

| Parameter | Parameter Label | Description |
| ----------- | --------------- | ----------- |
| Parameter 4 | Jamf Protect Tenant Name | https://`JamfProtectTenantName`.protect.jamfcloud.com |
| Parameter 5 | Jamf Protect GUID | See Below |
1. In the Protect console, go to Administrative>Downloads
2. If not already created, follow the prompts to Generate Download URL
3. Parse the generated URL to extract the appropriate installer GUID: 
i.e. - Download URL: curl -f "https://yourprotectinstance.protect.jamfcloud.com/installer.pkg?1234346-ffff-1234-9876-987654321aa" -o installer.pkg
- GUID is: 1234346-ffff-1234-9876-987654321aa

### Nudge Post Install
Easily manage your macOS updates with Nudge and a web host JSON file.

#### Features
* Provide custom client or mass scale JSON configurations for Nudge with web hosten JSON files
* Allows for custom or generic JSON configurations based on the JSON Nudge Array specified
* Set Nudge to launch when you or the client prefers with Nudge LaunchAgent parameters

| Parameter | Parameter Label | Description |
| ----------- | --------------- | ----------- |
| Parameter 4 | Reverse Domain Name Notation (i.e., "com.alectrona") |
| Parameter 5 | Configuration Files to Reset (i.e., None (blank) | All (default) | JSON | LaunchAgent | LaunchDaemon) |
| Parameter 6 | Configure Nudge LaunchAgent - 2 Hour (7200 seconds) by default |
| Parameter 7 | JSON Nudge Array (https://your.available.url.json) |
