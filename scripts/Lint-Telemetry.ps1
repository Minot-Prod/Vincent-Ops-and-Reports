param()

$log = "telemetry\LEARN_LOG.yaml"
if (!(Test-Path $log)) {
  Write-Host "ℹ️  Pas de LEARN_LOG.yaml, skip."
  exit 0
}

# Normalisation douce pour éviter BOM/CRLF qui perturbent les regex
$raw = Get-Content $log -Raw
$raw = $raw.Replace("`r","").Trim()
# Retire un éventuel BOM UTF8
if($raw.Length -gt 0 -and [int]$raw[0] -eq 0xFEFF){ $raw = $raw.Substring(1) }

$lines = $raw -split "`n"

# State machine: on démarre un bloc quand une ligne commence par "- " en colonne 0 (tolérance espaces)
$blocks = @()
$current = @()
foreach($line in $lines){
  if($line -match '^(?-i)\s*-\s'){         # début d’un nouveau bloc
    if($current.Count -gt 0){ $blocks += ,(@($current)); $current = @() }
    # on retire juste le "- " de tête pour faciliter les checks
    $current += ($line -replace '^\s*-\s*','')
  } else {
    if($line -match '^\s*$' -and $current.Count -eq 0){
      continue
    }
    $current += $line
  }
}
if($current.Count -gt 0){ $blocks += ,(@($current)) }

$errors = @()
$lineOffset = 1

foreach($blockLines in $blocks){
  $text = ($blockLines -join "`n")

  # Checks clés
  $hasDate = $text -match '(?im)^\s*date\s*:'
  $hasCo   = $text -match '(?im)^\s*company_slug\s*:'
  $hasOut  = $text -match '(?im)^\s*outcome\s*:'

  $missing = @()
  if(-not $hasDate){ $missing += 'date' }
  if(-not $hasCo){   $missing += 'company_slug' }
  if(-not $hasOut){  $missing += 'outcome' }

  if($missing.Count -gt 0){
    $errors += ("Entrée ~L{0}: clés manquantes -> {1}" -f $lineOffset, ($missing -join ", "))
  }

  $lineOffset += $blockLines.Count
}

if($errors.Count -gt 0){
  Write-Error ("Telemetry lint failed:`n" + ($errors -join "`n"))
  exit 1
} else {
  Write-Host "✅ Telemetry OK"
}
