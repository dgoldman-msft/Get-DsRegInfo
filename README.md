# Get-DsRegInfo
Crescendo PowerShell wrapper for DSCREGCMD

This is a PowerShell wrapper module for running the Windows Native command DSREGCMD

Instructions
1. Copy this folder and put it in your module path
2. Run Import-Module Get-DsRegInfo 

> Example 1: Get-DsRegInfo -Help

    Retrieves the help menu

> Example 2 : Get-DsRegInfo -Status

    Display the registration status of a machine

> Example 3: Get-DsRegInfo -DebugInfo

    Displays dscmdreg debug information

> Example 4: Get-DsRegInfo -Leave

    Unregister a Hybrid Joined device

> Example 5: Get-DsRegInfo -Join

    Hybrid Join a device

> Example 6: Get-DsRegInfo -ListAllAccounts

    List all WAM accounts on the device

> Example 7: Get-DsRegInfo -ListAllAccounts

    List all WAM accounts on the device

> Example 8: Get-DsRegInfo -CleanAccounts

    Remove all WAM accounts on the device
    
> Example 9: Get-DsRegInfo -UpdateDevice

    Update a devices registration status

> Example 9: Get-DsRegInfo -RefreshPrimaryPRT

    Refresh the devices Primary Refresh Token in the cache