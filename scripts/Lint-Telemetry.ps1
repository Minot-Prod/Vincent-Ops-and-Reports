param()

$log = "telemetry\LEARN_LOG.yaml"
if (!(Test-Path $log)) {
  Write-Host "ℹ️  Pas de LEARN_LOG.yaml, skip."
  exit 0
}

# Parser très simple par blocs (--- séparateur facultatif non requis)
$raw = Get-Content $log -Raw
$entries = ($raw -split "\n-\s") | Where-Object { $_.Trim() -ne "" }

$errors = @()
$lineOffset = 1

function HasKey($text,$key){ $text -match "(?m)^\s*$key\s*:" }

foreach($e in $entries){
  $block = $e
  $missing = @()
  foreach($k in @("date","company_slug","outcome")){
    if(-not (HasKey $block, $k)){ $missing += $k }
  }
  if($missing.Count -gt 0){
    $errors += "Entrée ~L${lineOffset}: clés manquantes -> " + ($missing -join ", ")
  }
  $lineOffset += ($block -split "`n").Count
}

if($errors.Count -gt 0){
  Write-Error ("Telemetry lint failed:`n" + ($errors -join "`n"))
  exit 1
} else {
  Write-Host "✅ Telemetry OK"
}
