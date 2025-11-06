param(
  [Parameter(Mandatory=$false)][string]$CompanySlug,
  [Parameter(Mandatory=$false)][ValidateSet("call","email","demo","meeting")][string]$Interaction,
  [Parameter(Mandatory=$false)][ValidateSet("meeting_booked","qualified","no_fit","no_timing","lost","won","follow_up")][string]$Outcome,
  [string[]]$Objections,
  [string[]]$Triggers,
  [string]$Notes,
  [int]$Fit,
  [int]$Timing,
  [int]$Access,
  [switch]$Interactive,
  [switch]$GitCommit
)

$log = "telemetry\LEARN_LOG.yaml"
if($Interactive){
  if(-not $CompanySlug){ $CompanySlug = Read-Host "company_slug (ex: acme-pharma)" }
  if(-not $Interaction){ $Interaction = Read-Host "interaction [call|email|demo|meeting]" }
  if(-not $Outcome){ $Outcome = Read-Host "outcome [meeting_booked|qualified|no_fit|no_timing|lost|won|follow_up]" }
  if(-not $Notes){ $Notes = Read-Host "notes (1-2 phrases max)" }
  if(-not $Objections){ $o = Read-Host "objections (csv, optionnel)"; if($o){ $Objections = $o.Split(",") } }
  if(-not $Triggers){ $t = Read-Host "triggers (csv, optionnel)"; if($t){ $Triggers = $t.Split(",") } }
  if(-not $Fit){ $Fit = [int](Read-Host "fit [0..5] (optionnel, vide=skip)") }
  if(-not $Timing){ $Timing = [int](Read-Host "timing [0..5] (optionnel, vide=skip)") }
  if(-not $Access){ $Access = [int](Read-Host "access [0..5] (optionnel, vide=skip)") }
}

if(-not $CompanySlug -or -not $Interaction -or -not $Outcome){
  throw "Requis: -CompanySlug, -Interaction, -Outcome (ou -Interactive)."
}

function YList([string[]]$arr){
  if(-not $arr -or $arr.Count -eq 0){ return "[]" }
  $vals = $arr | ForEach-Object { '"{0}"' -f ($_.Trim()) }
  return "[{0}]" -f ($vals -join ", ")
}

$today = (Get-Date).ToString('yyyy-MM-dd')
$entry = @"
- date: "$today"
  company_slug: "$CompanySlug"
  interaction: "$Interaction"
  outcome: "$Outcome"
  objections: $(YList $Objections)
  triggers: $(YList $Triggers)
  notes: "$Notes"
"@

if($Fit -or $Fit -eq 0){ $entry += "  fit: $Fit`n" }
if($Timing -or $Timing -eq 0){ $entry += "  timing: $Timing`n" }
if($Access -or $Access -eq 0){ $entry += "  access: $Access`n" }

$dir = Split-Path -Parent $log
if($dir){ if(-not (Test-Path $dir)){ New-Item -ItemType Directory -Force -Path $dir | Out-Null } }
if((Test-Path $log) -and -not ((Get-Content $log -Raw).EndsWith("`n`n"))){ Add-Content -Encoding UTF8 $log "`n" }; Add-Content -Encoding UTF8 $log $entry

Write-Host "✅ Appended debrief -> $log"
if($GitCommit){
  git add $log
  git commit -m "telemetry: add debrief $CompanySlug ($Interaction/$Outcome)"
  Write-Host "✅ Committed"
}

