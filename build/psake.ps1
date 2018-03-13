# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
        $ProjectRoot = $ENV:BHProjectPath
        if(-not $ProjectRoot)
        {
            $ProjectRoot = Resolve-Path "$PSScriptRoot\.."
        }

    $Timestamp = Get-Date -UFormat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $lines = '----------------------------------------------------------------------'

    $Verbose = @{}
    if($ENV:BHCommitMessage -match "!verbose")
    {
        $Verbose = @{Verbose = $True}
    }

    # The directory used to publish the module from.  If you are using Git, the
    # $PublishRootDir should be ignored if it is under the workspace directory.
    $PublishRootDir = "$ProjectRoot\release"
    $PublishDir     = "$PublishRootDir\$ENV:BHProjectName"
    $ENV:PublishDir = $PublishDir

    # The following items will not be copied to the $PublishDir.
    # Add items that should not be published with the module.
    $Exclude = @(
    (Split-Path $PSCommandPath -Leaf),
    'release',
    'tests',
    'build'
    '.git*',
    '.vscode',
    # These files are unique to this examples dir.
    'DebugTest.ps1',
    'appveyor.yml'
    'Build.ps1'
    )
}

Task Default -Depends Test

Task Init -requiredVariables PublishDir {
    $lines
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH*
    "`n"
    if (!(Test-Path $PublishDir)) {
        $null = New-Item $PublishDir -ItemType Directory
    }
}

Task Test -Depends Init  {
    $lines
    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    # Gather test results. Store them in a variable and file
    $TestResults = Invoke-Pester -Path $ProjectRoot\tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile"

    # In Appveyor?  Upload our tests! #Abstract this into a function?
    If($ENV:BHBuildSystem -eq 'AppVeyor')
    {
        (New-Object 'System.Net.WebClient').UploadFile(
            "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
            "$ProjectRoot\$TestFile" )
    }

    Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue

    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if($TestResults.FailedCount -gt 0)
    {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }
    "`n"
}

Task Clean -requiredVariables PublishRootDir {
    # Sanity check the dir we are about to "clean".  If $PublishRootDir were to
    # inadvertently get set to $null, the Remove-Item commmand removes the
    # contents of \*.  That's a bad day.  Ask me how I know?  :-(
    if ((Test-Path $PublishRootDir) -and $PublishRootDir.Contains($PSScriptRoot)) {
        Remove-Item $PublishRootDir\* -Recurse -Force
    }
}

Task Build -Depends Clean, Test -requiredVariables PublishDir, Exclude {
    $lines

    # Load the module, read the exported functions, update the psd1 FunctionsToExport
    Set-ModuleFunctions

    # Bump the module version if we didn't already
    Try
    {
        $GalleryVersion = Get-NextNugetPackageVersion -Name $env:BHProjectName -ErrorAction Stop
        $GithubVersion = Get-MetaData -Path $env:BHPSModuleManifest -PropertyName ModuleVersion -ErrorAction Stop
        if($GalleryVersion -ge $GithubVersion) {
            Update-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion -Value $GalleryVersion -ErrorAction stop
        }
        Copy-Item -Path $env:BHModulePath\* -Destination $PublishDir -Recurse -Exclude $Exclude
    }
    Catch
    {
        "Failed to update version for '$env:BHProjectName': $_.`nContinuing with existing version"
    }
}

Task Deploy -Depends Build {
    $lines

    $Params = @{
        Path = "$ProjectRoot\Build"
        Force = $true
        Recurse = $false # We keep psdeploy artifacts, avoid deploying those : )
    }
    Invoke-PSDeploy @Verbose @Params
}