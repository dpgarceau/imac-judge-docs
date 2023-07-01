Param (
    [Parameter(Mandatory)]
    [string[]]$BuildCommands,

    [Parameter()]
    [switch]$DryRun
)

if ($DryRun) {
    Write-Information "INFO: DryRun: $DryRun" -InformationAction Continue
}

$global:ScriptDir = "$Env:WorkSpaceFolder\bin";

function checkEnvironment($Path) {
    $pythonCommandParams = "$global:ScriptDir/checkEnvironment.py $Path"
    $p = Start-Process -FilePath python.exe -ArgumentList $pythonCommandParams -Wait -NoNewWindow -PassThru
    return $p.ExitCode
}

function executeBuildCmd($Path, $BuildCommand) {
    Write-Information "INFO: Executing: $Path $BuildCommand" -InformationAction Continue
    $p = Start-Process -FilePath $Path -ArgumentList $BuildCommand -Wait -NoNewWindow -PassThru
    return $p.ExitCode
}

$envOK = checkEnvironment -Path "$Env:WorkSpaceFolder\.env"
if ($envOK -ne 0) {
    Write-Error "ERROR: Environment is Not OK" -ErrorAction Stop
}

$makefiles = Get-ChildItem -Path "$Env:WorkSpaceFolder\docs\" -Filter Make.bat -Recurse -ErrorAction SilentlyContinue -Name -Depth 1
foreach ($makefile in $makefiles) {
    $sphinxDir = Split-Path -Path "$Env:WorkSpaceFolder\docs\$makefile"
    Write-Information "Processing Sphinx Document : $sphinxDir" -InformationAction Continue

    foreach ($cmd in $BuildCommands) {
        $execResult = executeBuildCmd -Path "$Env:WorkSpaceFolder\docs\$makefile" -BuildCommand $cmd
        if ($execResult -ne 0) {
            Write-Error "ERROR: Build command failed($execResult)." -ErrorAction Stop
        }
    }
}