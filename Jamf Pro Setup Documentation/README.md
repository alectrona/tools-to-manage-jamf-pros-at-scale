<!-- markdownlint-disable MD033 -->

# Initial Jamf Pro Instance Configuration

This documentation highlights the steps to configuring and setting up a new Jamf Pro instance for a customer.

## Jamf Pro Configuration Prerequisites

Recommended steps prior to configuring your Jamf instance include:

<details>
<summary>Institutional Apple ID for a Push Certificate</summary>

- Create a new Apple ID at <https://appleid.apple.com>

- This Apple ID should be a generic, institutionally-owned Apple ID that can be used to login to <https://identity.apple.com/pushcert> on an annual basis to renew the Jamf Pro server's Push Certificate.

</details>

<details>
<summary>Jamf ID for Cloud Services Connection and Push Proxy Certificate</summary>

- Create a Jamf ID: <https://id.jamf.com/CommunitiesSelfReg>

- In some scenarios you may use the same Jamf ID that you've used in your other Jamf Pro servers. This Jamf ID should be a generic, institutionally-owned Jamf ID.

- Manage your Jamf ID and access subscription and account information, the training catalog, and Jamf Support access at <https://id.jamf.com/>

</details>

<details>
<summary>Apple Business/School Manager</summary>

- Sign up for Apple Business Manager: <https://support.apple.com/en-mk/guide/apple-business-manager/axm402206497/web>

- Sign up for Apple School Manager: <https://support.apple.com/en-mk/guide/apple-school-manager/axm402206497/web>

</details>

<details>
<summary>Email </summary>
<br>

To leverage Email notifications in Jamf, creating a service account or configuring your email provider appropriately is required.

- Gmail: <https://support.google.com/a/answer/176600?hl=en>

- O365: <https://learn.microsoft.com/en-us/exchange/mail-flow-best-practices/how-to-set-up-a-multifunction-device-or-application-to-send-email-using-microsoft-365-or-office-365>

</details>

## Jamf Pro Setup Assistant

Complete the initial setup for your Jamf Pro instance: <https://learn.jamf.com/bundle/jamf-pro-getting-started/page/Completing_the_Jamf_Pro_Setup_Assistant.html>

## System Settings

Review the below sections in Settings>System:

<details>
<summary>User Accounts and Groups</summary>
<br>

Creating user groups first and leveraging those group-based permissions is recommended prior to creating new user accounts. This allows you to easily adjust permissions as needed for a group of individuals instead of needing to adjust permissions on each individual account. This also ensures that desired permissions are identical for all users assigned to a specific group.

Below are recommended default settings for two user groups: Full Administrators and Limited Administrators. The recommended Full Administrators permissions allows almost all access on the Jamf Pro instance, but limits key permissions like Send Computer Remote Wipe Command. Limited Administrators allows primarily read-only access but has permissions to adjust certain items as needed (i.e. Advanced Searches) and push certain MDM commands.

1. Create a new user group called **Full Administrators** with the below settings:

    - Jamf Pro Server Objects: **Full permissions**
    - Jamf Pro Server Settings: Read permissions for everything and write permissions for all **except**:
      - Change Management
      - Log Flushing
      - Password Policy
      - Security
      - SSO settings
    - Jamf Pro Server Actions: All permissions **except**:
      - Send Computer Remote Wipe Command
      - Send Disable Bootstrap Token Command
      - Send Local Admin Password Command
      - Send MDM Check In Command
      - Send Mobile Device Remote Wipe Command
      - Update Local Admin Password Settings
      - View Local Admin Password
      - View Local Admin Password Audit History
    - Jamf Admin: **Full permissions**
2. Create a new user group called **Limited Administrators**
   - Jamf Pro Server Objects: Full read permissions for everything. Set create and update permissions for:
     - Advanced Computer Searches
     - Advanced Mobile Device Searches
     - Advanced User Searches
     - Computers
     - Mobile Devices
     - Scripts
     - Self Service Bookmarks
   - Jamf Pro Server Settings: Read permissions for everything
   - Jamf Pro Server Actions: Permissions for:
     - Allow User to Enroll
     - Assign Users to Computers
     - Assign Users to Mobile Devices
     - Change Password
     - Enroll Computers and Mobile Devices
     - Flush Policy Logs
     - Read and Download Jamf Application Assets
     - Send Blank Pushes to Mobile Devices
     - Send Computer Remote Lock Command
     - Send Mobile Device Lost Mode Command
     - Send Mobile Device Remove Passcode Command
     - Send Mobile Device Remove Restrictions Password Command
     - Send Mobile Device Restart Device Command
     - Send Mobile Device Set Device Name Command
     - Send Mobile Device Shut Down Command
     - View Activation Lock Bypass Code
     - View Disk Encryption Recovery Key
     - View Event Logs
     - View Jamf Pro Server Information
     - View License Serial Numbers
     - View Mobile Device Lost Mode Location
   - Jamf Admin: Enable Use Jamf Admin

3. Create accounts as needed, assigning them to relevant user groups

4. Create any required API/service accounts with the appropriate permissions

5. Set an appropriate password policy

</details>

<details>
<summary>Single Sign-On</summary>
<br>

Configure Single Sign-on for your identity provider: <https://learn.jamf.com/bundle/jamf-pro-documentation-current/page/Single_Sign-On.html>

</details>

<details>
<summary>Cloud Identity Providers</summary>
<br>

Integrate your Cloud Identity provider with Jamf to leverage user based settings/data in Jamf Pro: <https://learn.jamf.com/bundle/jamf-pro-documentation-current/page/Cloud_Identity_Providers.html>

</details>

<details>
<summary>SMTP Server</summary>
<br>

Configure SMTP settings as appropriate: <https://learn.jamf.com/bundle/jamf-pro-documentation-current/page/SMTP_Server_Integration.html>

</details>

<details>
<summary>Log Flushing</summary>

1. Set the following logs from the default of Three Months to One Year:

    - Computer and Mobile Device Management History

    - Jamf Pro Access Logs

    - Change Management Logs

    - Event Logs

2. Set logs to flush at 4AM (Note: this time is relative to the Jamf Cloud server - not your account's timezone)

</details>

<details>
<summary>Customer Metrics</summary>
<br>

1. Disable Engage
2. Turn off CEM (Customer experience metrics) in Settings > Information > Customer experience metrics

</details>

## Global Settings

Review the below sections in Settings>Global:

<details>
<summary>Push Certificates</summary>

1. Configure APNS Certificate: <https://learn.jamf.com/bundle/jamf-pro-getting-started/page/Creating_a_Push_Certificate.html>

2. Create Push Proxy Certificate: <https://learn.jamf.com/bundle/jamf-pro-documentation-current/page/Jamf_Push_Proxy.html>

</details>

<details>
<summary>Automated Device Enrollment</summary>

- Follow instructions to download the public key from Jamf, upload it to Apple Business/School Manager and then download the server token file from ABM/ASM and upload it to Jamf Pro: <https://learn.jamf.com/bundle/jamf-pro-documentation-current/page/Automated_Device_Enrollment_Integration.html>

- Assign devices as appropriate in ABM/ASM and ensure they sync correctly into Jamf: <https://support.apple.com/en-ae/guide/apple-business-manager/axmf500c0851/web>

</details>

<details>
<summary>Volume Purchasing</summary>

- Follow instructions to download the appropriate content token from Apple School/Business Manager and upload the token to Jamf. If needed, create a new Location: <https://learn.jamf.com/bundle/jamf-pro-documentation-current/page/Volume_Purchasing_Integration.html>

- Purchase apps as needed and ensure content syncs over appropriately to Jamf

</details>

<details>
<summary>User-Initiated Enrollment (UIE)</summary>
<br>

Follow the below instructions to enable UIE, but to not create the management account on the Mac during enrollment:

**Note: If the management account is configured to be created in UIE settings, the account will always be created on any enrolled Mac regardless of enrollment method.**

- General:

  - **Check**: Skip certificate installation during enrollment

  - **Uncheck**: Restrict re-enrollment to authorized users only and Use a third-party signing certificate

- macOS:

  - **Check**: Enable user-initiated enrollment for computers

  - Enter an appropriate username for the Management Account

  - Ensure Method for Setting Password is set to **Randomly generate passwords**
  
  - **Uncheck**: Create Management Account, Ensure SSH is enabled, Launch Self Service when done,
Sign QuickAdd Package

</details>

<details>
<summary>Re-Enrollment</summary>

- **Check**: Clear user and location information on mobile devices and computers

- **Uncheck**: Clear user and location history information on mobile devices and computers

- **Check**: Clear policy logs on computers

- **Check**: Clear extension attribute values on computers and mobile devices

- Set: Clear Management History On Mobile Devices And Computers to **Clear completed, failed and pending commands**

</details>

<details>
<summary>Cloud Distribution Point</summary>

1. In the **Content Delivery Network** pop-up menu, choose **Jamf Cloud**

2. **Check** Use as principal distribution point and click Save

</details>

<details>
<summary>Cloud Services Connection</summary>

1. Login with a valid Jamf ID account

2. Click Save and confirm connection is enabled

For additional details: <https://learn.jamf.com/bundle/jamf-pro-documentation-current/page/Cloud_Services_Connection.html>

</details>

## Self Service

Review the below sections in Settings>Self Service:

<details>
<summary>macOS</summary>

1. **Check** Install Automatically and Enable Self Service Notifications

2. **Uncheck** Enable Self Service User Login

3. Set the Landing Page to **Browse** and category to **All Items**

</details>

<details>
<summary>Branding</summary>
<br>

Add branding as appropriate, customizing the Application name, header, and/or icon: <https://learn.jamf.com/bundle/jamf-pro-documentation-current/page/Jamf_Self_Service_for_macOS_Branding_Settings.html>

</details>

<details>
<summary>Bookmarks</summary>
<br>

Create any bookmarks as appropriate, recommend bookmarks include support portal URL, password reset URL, company intranet page, etc.: <https://learn.jamf.com/bundle/jamf-pro-documentation-current/page/Bookmarks.html>

</details>

## Computer Management

Review the below sections in Settings>Computer Management:

<details>
<summary>Inventory Collection</summary>
<br>

The default values are recommended. If desired, adjust as needed: <https://learn.jamf.com/bundle/jamf-pro-documentation-current/page/Computer_Inventory_Collection.html>

</details>

<details>
<summary>Check-in</summary>

- Adjust the **Recurring Check-in Frequency** following the below recommendations, based on the number of Managed Macs in the Jamf Pro Instance:

  | Managed Macs | Check-in Frequency |
  |---|---|
  | 1-499 | Every 5 Minutes |
  | 500-2,499 | Every 15 Minutes |
  | 2,500-9,999 | Every 30 Minutes |
  | 10,000+ | Every 60 Minutes |

- **Check** the below boxes:

  - Allow Network State Change Triggers

  - Create startup script

    - Log Computer Usage information at startup

    - Check for policies triggered by startup

  - Create login events

    - Log Computer Usage information at login

    - Check for policies triggered by login

</details>

<details>
<summary>Security</summary>
<br>

The default values are recommended. If deploying Jamf Connect or Jamf Protect, select the appropriate checkbox. For more information: <https://learn.jamf.com/bundle/jamf-pro-documentation-current/page/Security_Settings.html>

</details>

<details>
<summary>App Updates</summary>
<br>

**Check** the below boxes:

- Automatically Force App Updates

- Automatically update apps installed via Self Service

- Schedule Jamf Pro to automatically check the App Store for updates

  - Set App Store Sync Time to 9pm (please note, this time is relative to your Jamf Cloud server, not your account's timezone)

</details>

## Copy Jamf Pro Template Data

With the appropriate settings in place on the Jamf Pro Server, the next steps involve configuring initial scripts, policies, computer smart groups, etc. For this process, we recommend leveraging Jamf Migrator: (<https://github.com/jamf/JamfMigrator>) and copying over desired settings from another server.

The settings should include copying over default/initial:

- Categories

- Scripts

- Extension Attributes

- Configuration Profiles

- Smart Computer Groups

- Policies

- Restricted Software

## Final Steps

With all settings and initial policies, configuration profiles, etc. in place, follow the below steps to complete the initial setup and configuration of your Jamf Pro server.

<details>
<summary>PreStage Enrollment</summary>
<br>

Create a default PreStage Enrollment, tailored to your environment's needs: <https://learn.jamf.com/bundle/jamf-pro-documentation-current/page/Automated_Device_Enrollment_for_Computers.html>

</details>

<details>
<summary>Plan Enrollment</summary>
<br>

Plan the process of how you will enroll your organization's Macs to your Jamf Pro server. Options include:

- User-initiated enrollment: Users are directed to a your Jamf Server's enrollment URL or sent an enrollment invitation via email: <https://learn.jamf.com/bundle/jamf-pro-documentation-current/page/Device_Enrollment_for_Computers.html>

- Automated device enrollment: For either new or existing computers, Automated device enrollment (<https://learn.jamf.com/bundle/jamf-pro-documentation-current/page/Automated_Device_Enrollment_for_Computers.html>) allows you to leverage zero-touch deployment if configured appropriately.
  
    For new or wiped computers, Automated device enrollment will take effect during Apple Setup. For existing Macs that are assigned to your Jamf Server in ABM/ASM, you can leverage the `sudo profiles renew -type enrollment` command to enroll the Mac without needing to wipe the computer: <https://support.apple.com/en-ae/guide/deployment/dep26505df5d/web>

Regardless of the deployment method chosen, we recommend providing detailed documentation to the end-user on how to enroll their device successfully.

</details>

<details>
<summary>Update Existing Workflows</summary>

- Review any existing workflows, including CI workflows/pipelines, to include the new Jamf Pro instance

- Review and update any existing documentation with new Jamf Pro instance details

</details>
