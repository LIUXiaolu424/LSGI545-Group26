param(
    [Parameter(Mandatory = $true)][string]$Experiment,
    [Parameter(Mandatory = $true)][string]$OutputName,
    [int]$Threads = 4
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$distro = 'Ubuntu-22.04'

function Convert-ToWslPath([string]$WindowsPath) {
    $full = [System.IO.Path]::GetFullPath($WindowsPath)
    $drive = $full.Substring(0, 1).ToLowerInvariant()
    $rest = $full.Substring(2).Replace('\', '/')
    return "/mnt/$drive$rest"
}

$rootWsl = Convert-ToWslPath $root
$netLogo = "$rootWsl/.runtime/wsl/NetLogo-6.4.0-64"
$model = "$rootWsl/NorovirusDormABM.nlogo"
$setupFile = "$rootWsl/experiments/behaviorspace_experiments.xml"
$output = Join-Path $root "results\$OutputName"
$log = Join-Path $root "logs\$Experiment.log"

$command = @"
java -XX:MaxRAMPercentage=50 -Dfile.encoding=UTF-8 \
  -Dnetlogo.extensions.dir='$netLogo/extensions' \
  -Dnetlogo.models.dir='$netLogo/models' \
  --add-exports=java.base/java.lang=ALL-UNNAMED \
  --add-exports=java.desktop/sun.awt=ALL-UNNAMED \
  --add-exports=java.desktop/sun.java2d=ALL-UNNAMED \
  -classpath '$netLogo/lib/app/netlogo-6.4.0.jar' \
  org.nlogo.headless.Main --model '$model' --setup-file '$setupFile' \
  --experiment '$Experiment' --table - --threads $Threads
"@

Write-Host "Running $Experiment with NetLogo 6.4.0 via WSL..."
$captured = & wsl.exe -d $distro -- bash -lc $command 2>&1
$exitCode = $LASTEXITCODE
$joined = ($captured | ForEach-Object { [string]$_ }) -join [Environment]::NewLine
$joined = $joined.Replace(([string][char]0), '')
[System.IO.File]::WriteAllText($log, $joined + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))

if ($exitCode -ne 0) { throw "$Experiment failed with exit code $exitCode. See $log" }
if ($joined -match 'RUNTIME ERROR|Exception in thread') { throw "$Experiment reported a runtime error. See $log" }
$marker = $joined.IndexOf('"BehaviorSpace results')
if ($marker -lt 0) { throw "BehaviorSpace CSV marker not found. See $log" }
$csv = $joined.Substring($marker).TrimEnd() + [Environment]::NewLine
[System.IO.File]::WriteAllText($output, $csv, [System.Text.UTF8Encoding]::new($false))
Write-Host "Completed: $output"
