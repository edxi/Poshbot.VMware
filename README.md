# VMwareBaslineCheck

[![Build status][appveyor-badge]][appveyor-build]
[![PowerShell Gallery][psgallery-badge]][psgallery]

A PoshBot plugin to pass PowerCLI cmdlets.

## Install Module

> This module does not put powercli modules into requirment module list. So you'd better confirm related powercli modules installed already.
To install the module from the [PowerShell Gallery](https://www.powershellgallery.com/):

```powershell
PS C:\> Install-Module -Name PoshBot.VMware -Repository PSGallery
PS C:\> &("$(Split-Path (Get-Module Poshbot.VMware -ListAvailable).path -Parent)\Set-VIServer.ps1")
```

## Install Plugin

To install the plugin from within PoshBot (But you can only set VIServer in powershell):

```powershell
!install-plugin -name poshbot.vmware
```

## Features

* Store vcenter credential encrypted.
* Invoke PowerCLI cmdlet by PoshBot command.

## Examples

```powershell
!getsnapshot vm1 'vm2' 'vm 3'
!newsnapshot vm1 'vm2' 'vm 3'
!removesnapshot vm1 'vm2' 'vm 3'
```

## Feedback

Please send your feedback to <https://github.com/edxi/Poshbot.VMware/issues>

[appveyor-badge]: https://ci.appveyor.com/api/projects/status/m1pj53yvvl7tutv0?svg=true
[appveyor-build]: https://ci.appveyor.com/project/edxi/poshbot-vmware
[psgallery-badge]: https://img.shields.io/powershellgallery/dt/poshbot.VMware.svg
[psgallery]: https://www.powershellgallery.com/packages/Poshbot.VMware