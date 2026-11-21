param(
    [Parameter(Mandatory = $true)]
    [string]$NetLogoHome,
    [ValidateSet('Smoke', 'Validation', 'Main', 'Timeseries')]
    [string]$Stage = 'Smoke',
    [int]$Threads = 2
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$model = Join-Path $projectRoot 'NorovirusDormABM.nlogo'
$setupFile = Join-Path $projectRoot 'experiments\behaviorspace_experiments.xml'
$results = Join-Path $projectRoot 'results'
$logs = Join-Path $projectRoot 'logs'
$headless = Join-Path $NetLogoHome 'netlogo-headless.bat'
if (-not (Test-Path -LiteralPath $headless)) { throw "No NetLogo headless launcher found under $NetLogoHome" }
New-Item -ItemType Directory -Force -Path $results, $logs | Out-Null

function Invoke-Experiment([string]$Name, [string]$OutputName) {
    $output = Join-Path $results $OutputName
    $log = Join-Path $logs ($Name + '.log')
    Write-Host "Running $Name -> $output"
    & $headless --model $model --setup-file $setupFile --experiment $Name --table $output --threads $Threads 2>&1 |
        Tee-Object -FilePath $log
    if ($LASTEXITCODE -ne 0) { throw "$Name failed with exit code $LASTEXITCODE. See $log" }
    if (-not (Test-Path -LiteralPath $output)) { throw "$Name did not create $output" }
}

switch ($Stage) {
    'Smoke' { Invoke-Experiment 'smoke_test_18x2' 'smoke_test_18x2.csv' }
    'Validation' {
        Invoke-Experiment 'validation_zero_initial' 'validation_zero_initial.csv'
        Invoke-Experiment 'validation_zero_transmission' 'validation_zero_transmission.csv'
        Invoke-Experiment 'validation_environment_off' 'validation_environment_off.csv'
    }
    'Main' {
        $smoke = Join-Path $results 'smoke_test_18x2.csv'
        & python (Join-Path $PSScriptRoot 'check_results.py') $smoke
        if ($LASTEXITCODE -ne 0) { throw 'Main experiment blocked because smoke results did not pass.' }
        Invoke-Experiment 'main_interventions_18x50' 'main_interventions_18x50.csv'
    }
    'Timeseries' { Invoke-Experiment 'baseline_timeseries_50' 'baseline_timeseries_50.csv' }
}
