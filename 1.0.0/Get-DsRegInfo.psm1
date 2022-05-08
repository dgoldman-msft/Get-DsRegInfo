# Module created by Microsoft.PowerShell.Crescendo
class PowerShellCustomFunctionAttribute : System.Attribute {
    [bool]$RequiresElevation
    [string]$Source
    PowerShellCustomFunctionAttribute() { $this.RequiresElevation = $false; $this.Source = "Microsoft.PowerShell.Crescendo" }
    PowerShellCustomFunctionAttribute([bool]$rElevation) {
        $this.RequiresElevation = $rElevation
        $this.Source = "Microsoft.PowerShell.Crescendo"
    }
}

function Format-DsRegCmdOutput {
    <#
        .SYNOPSIS
            Format Output

        .DESCRIPTION
            Format the output from DSREGCMD

        .PARAMETER Input
            DSREGCMD stream object

        .EXAMPLE
            None

        .NOTES
            Custom formatter for DSREGCMD output
    #>
    [CmdletBinding()]
    param (
        [object]
        $InboundResult,

        [object]
        $Parameters
    )

    begin {
        Write-Verbose "Formatting DSREGCMD informtion"
        [System.Collections.ArrayList]$customObjects = @()
        $showAll = $true
    }

    process {
        foreach ($line in $InboundResult) {
            if ($Parameters.Help.IsPresent) {
                $line
                if ($line.contains('refreshprt')) { break } else { continue }
            }

            if ($Parameters.DebugInfo.IsPresent) {
                $line
                if ($line.contains('can')) { break } else { continue }
            }

            if (($line.contains('+')) -or ($line.length -eq 0) -or ($line.contains('For more information'))) { continue }
            if ($line.contains('|')) {
                $splitLine = ($line.Split('|', [System.StringSplitOptions]::RemoveEmptyEntries) -replace ' ', '')
                $customObject = New-Object PSCustomObject
                $customObject | Add-Member -TypeName $splitLine[0]
                $customObject | Add-Member -MemberType NoteProperty -Name 'Object' -value $splitLine

                # Save custom object
                $null = $customObjects.Add($customObject)
                continue
            }

            if ($line -match "(http[s])(:\/\/)([^\s,]+)") {
                $splitLines = ($line.Split(' :', [System.StringSplitOptions]::RemoveEmptyEntries) -replace ' ', '')
                $customObject | Add-Member -MemberType NoteProperty -Name $splitLines[0] -value $matches[0] -force
                continue
            }

            if ($line.contains("urn")) {
                $splitLines = ($line.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries) -replace ' ', '')
                $customObject | Add-Member -MemberType NoteProperty -Name $splitLines[0] -value $splitLines[2] -force
                continue
            }

            else {
                $splitLines = ($line.Split(' :', [System.StringSplitOptions]::RemoveEmptyEntries) -replace ' ', '')
                $customObject | Add-Member -MemberType NoteProperty -Name $splitLines[0] -value $splitLines[1] -force
            }
        }

        # Display the output
        if ($Parameters.ShowDeviceState.IsPresent) {
            foreach ($object in $customObjects) { if ($object.pstypenames -eq 'DeviceState') { $Object } }
            $showAll = $false
        }

        if ($Parameters.ShowDeviceDetails.IsPresent) {
            foreach ($object in $customObjects) { if ($object.pstypenames -eq 'DeviceDetails') { $Object } }
            $showAll = $false
        }

        if ($Parameters.ShowUserState.IsPresent) {
            foreach ($object in $customObjects) { if ($object.pstypenames -eq 'UserState') { $Object } }
            $showAll = $false
        }

        if ($Parameters.ShowSSOState.IsPresent) {
            foreach ($object in $customObjects) { if ($object.pstypenames -eq 'SSOState') { $Object } }
            $showAll = $false
        }

        if ($Parameters.ShowWorkAccounts.IsPresent) {
            foreach ($object in $customObjects) { if ($object.pstypenames -like 'Work*') { $Object } }
            $showAll = $false
        }

        if ($Parameters.ShowTenantDetails.IsPresent) {
            foreach ($object in $customObjects) { if ($object.pstypenames -like 'Tenant*') { $Object } }
            $showAll = $false
        }

        if ($Parameters.ShowDiagnosticData.IsPresent) {
            foreach ($object in $customObjects) { if ($object.pstypenames -like 'Diagnostic*') { $Object } }
            $showAll = $false
        }

        if ($Parameters.ShowProxyConfig.IsPresent) {
            foreach ($object in $customObjects) { if ($object.pstypenames -like '*Proxy*') { $Object } }
            $showAll = $false
        }

        if ($showAll -and (-NOT ($Parameters.Help.IsPresent))) { foreach ($obj in $customObjects) { $obj } }
    }
}

function Get-DsRegInfo {
    <#
        .SYNOPSIS
            Run Get-DsRegInfo

        .DESCRIPTION
            Show current directory registration status of a windows machine

        .PARAMETER Help
            Displays the help for DSREGCMD

        .PARAMETER Status
            Displays the device join status

        .PARAMETER OldStatus
            Displays the device join status in old format

        .PARAMETER Join
            Schedules and monitors the Autojoin task to Hybrid Join the device

        .PARAMETER Leave
            Preforms Hybrid Unjoin

        .PARAMETER DebugInfo
            Displays debug messages

        .PARAMETER RefreshPrimaryPRT
            Refreshes PRT in the CloudAP cache
    #>

    [PowerShellCustomFunctionAttribute(RequiresElevation = $False)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [OutputType('PSCustomObject')]
    [CmdletBinding()]

    param(
        [Parameter()]
        [PSDefaultValue(Value = "")]
        [switch]
        $Help,

        [Parameter()]
        [PSDefaultValue(Value = "")]
        [switch]
        $Status,

        [Parameter()]
        [PSDefaultValue(Value = "")]
        [switch]
        $OldStatus,

        [Parameter()]
        [PSDefaultValue(Value = "")]
        [switch]
        $Join,

        [Parameter()]
        [PSDefaultValue(Value = "")]
        [switch]
        $Leave,

        [Parameter()]
        [PSDefaultValue(Value = "")]
        [switch]
        $DebugInfo,

        [Parameter()]
        [PSDefaultValue(Value = "")]
        [switch]
        $RefreshPrimaryPRT,

        [Parameter()]
        [PSDefaultValue(Value = "")]
        [switch]
        $ShowDeviceState,

        [Parameter()]
        [PSDefaultValue(Value = "")]
        [switch]
        $ShowDeviceDetails,

        [Parameter()]
        [PSDefaultValue(Value = "")]
        [switch]
        $ShowTenantDetails,

        [Parameter()]
        [PSDefaultValue(Value = "")]
        [switch]
        $ShowUserState,

        [Parameter()]
        [PSDefaultValue(Value = "")]
        [switch]
        $ShowSSOState,

        [Parameter()]
        [PSDefaultValue(Value = "")]
        [switch]
        $ShowWorkAccounts,

        [Parameter()]
        [PSDefaultValue(Value = "")]
        [switch]
        $ShowDiagnosticData,

        [Parameter()]
        [PSDefaultValue(Value = "")]
        [switch]
        $ShowProxyConfig
    )

    BEGIN {
        $__PARAMETERMAP = @{
            Help              = @{
                OriginalName      = '/?'
                OriginalPosition  = '0'
                Position          = '2147483647'
                ParameterType     = 'switch'
                ApplyToExecutable = $False
                NoGap             = $False
            }
            Status            = @{
                OriginalName      = '/status'
                OriginalPosition  = '0'
                Position          = '2147483647'
                ParameterType     = 'switch'
                ApplyToExecutable = $False
                NoGap             = $False
            }
            OldStatus         = @{
                OriginalName      = '/status_old'
                OriginalPosition  = '0'
                Position          = '2147483647'
                ParameterType     = 'switch'
                ApplyToExecutable = $False
                NoGap             = $False
            }
            Join              = @{
                OriginalName      = '/join'
                OriginalPosition  = '0'
                Position          = '2147483647'
                ParameterType     = 'switch'
                ApplyToExecutable = $False
                NoGap             = $False
            }
            Leave             = @{
                OriginalName      = '/leave'
                OriginalPosition  = '0'
                Position          = '2147483647'
                ParameterType     = 'switch'
                ApplyToExecutable = $False
                NoGap             = $False
            }
            DebugInfo         = @{
                OriginalName      = '/debug'
                OriginalPosition  = '0'
                Position          = '2147483647'
                ParameterType     = 'switch'
                ApplyToExecutable = $False
                NoGap             = $False
            }
            RefreshPrimaryPRT = @{
                OriginalName      = '/refreshprt'
                OriginalPosition  = '0'
                Position          = '2147483647'
                ParameterType     = 'switch'
                ApplyToExecutable = $False
                NoGap             = $False
            }
        }

        $__outputHandlers = @{ Default = @{ StreamOutput = $true; Handler = { $input } } }
    }

    PROCESS {
        $__boundParameters = $PSBoundParameters
        $__defaultValueParameters = $PSCmdlet.MyInvocation.MyCommand.Parameters.Values.Where({ $_.Attributes.Where({ $_.TypeId.Name -eq "PSDefaultValueAttribute" }) }).Name
        $__defaultValueParameters.Where({ !$__boundParameters["$_"] }).ForEach({ $__boundParameters["$_"] = get-variable -value $_ })
        $__commandArgs = @()
        $MyInvocation.MyCommand.Parameters.Values.Where({ $_.SwitchParameter -and $_.Name -notmatch "Debug|Whatif|Confirm|Verbose" -and ! $__boundParameters[$_.Name] }).ForEach({ $__boundParameters[$_.Name] = [switch]::new($false) })
        if ($__boundParameters["Debug"]) { wait-debugger }
        foreach ($paramName in $__boundParameters.Keys |
            Where-Object { !$__PARAMETERMAP[$_].ApplyToExecutable } |
            Sort-Object { $__PARAMETERMAP[$_].OriginalPosition }) {
            $value = $__boundParameters[$paramName]
            $param = $__PARAMETERMAP[$paramName]
            if ($param) {
                if ($value -is [switch]) {
                    if ($value.IsPresent) {
                        if ($param.OriginalName) { $__commandArgs += $param.OriginalName }
                    }
                    elseif ($param.DefaultMissingValue) { $__commandArgs += $param.DefaultMissingValue }
                }
                elseif ( $param.NoGap ) {
                    $pFmt = "{0}{1}"
                    if ($value -match "\s") { $pFmt = "{0}""{1}""" }
                    $__commandArgs += $pFmt -f $param.OriginalName, $value
                }
                else {
                    if ($param.OriginalName) { $__commandArgs += $param.OriginalName }
                    $__commandArgs += $value | Foreach-Object { $_ }
                }
            }
        }
        $__commandArgs = $__commandArgs | Where-Object { $_ -ne $null }
        if ($__boundParameters["Debug"]) { wait-debugger }
        if ( $__boundParameters["Verbose"]) {
            Write-Verbose -Verbose -Message $env:windir/system32/dsregcmd.exe
            $__commandArgs | Write-Verbose -Verbose
        }
        $__handlerInfo = $__outputHandlers[$PSCmdlet.ParameterSetName]
        if (! $__handlerInfo ) {
            $__handlerInfo = $__outputHandlers["Default"] # Guaranteed to be present
        }
        $__handler = $__handlerInfo.Handler
        if ( $PSCmdlet.ShouldProcess("$env:windir/system32/dsregcmd.exe $__commandArgs")) {
            # check for the application and throw if it cannot be found
            if ( -not (Get-Command -ErrorAction Ignore "$env:windir/system32/dsregcmd.exe")) {
                throw "Cannot find executable '$env:windir/system32/dsregcmd.exe'"
            }
            if ( $__handlerInfo.StreamOutput ) {
                $result = & "$env:windir/system32/dsregcmd.exe" $__commandArgs | & $__handler
                Format-DsRegCmdOutput -InboundResult $result -Parameters $__boundParameters
            }
            else {
                $result = & "$env:windir/system32/dsregcmd.exe" $__commandArgs
                Format-DsRegCmdOutput -InboundResult $result -Parameters $__boundParameters
            }
        }
    } # end PROCESS
}
Export-ModuleMember -Function Get-DsRegInfo


