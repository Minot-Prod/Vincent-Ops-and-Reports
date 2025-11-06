param()

$log = "telemetry\LEARN_LOG.yaml"
if (!(Test-Path $log)) {
  Write-Host "ℹ️  Pas de LEARN_LOG.yaml, skip."
  exit 0
}

# Normalisation
$raw = Get-Content $log -Raw
$raw = $raw.Replace("`r","")
if($raw.Length -gt 0 -and [int]$raw[0] -eq 0xFEFF){ $raw = $raw.Substring(1) }
$lines = $raw -split "`n"

# State machine avec tracking de la ligne de départ et ignorance du préambule
$blocks = @()
$current = @()
$startLine = $null
$lineNum = 0
$seenStart = $false

foreach($line in $lines){
  $lineNum++

  if($line -match '^(?-i)\s*-\s'){        # nouvelle entrée YAML
    $seenStart = $true
    if($current.Count -gt 0){
      $blocks += [pscustomobject]@{ Lines = @($current); Start = $startLine }
      $current = @()
    }
    $startLine = $lineNum
    $current += ($line -replace '^\s*-\s*','')
    continue
  }

  if(-not $seenStart){
    # tout ce qui précède la première entrée ("- ") = commentaires / entête -> on ignore
    continue
  }

  if($current.Count -eq 0 -and $line -match '^\s*$'){ continue }
  $current += $line
}
if($current.Count -gt 0){
  $blocks += [pscustomobject]@{ Lines = @($current); Start = $startLine }
}

$errors = @()

foreach($b in $blocks){
  $text = ($b.Lines -join "`n")

  $hasDate = $text -match '(?im)^\s*date\s*:'
  $hasCo   = $text -match '(?im)^\s*company_slug\s*:'
  $hasOut  = $text -match '(?im)^\s*outcome\s*:'

  $missing = @()
  if(-not $hasDate){ $missing += 'date' }
  if(-not $hasCo){   $missing += 'company_slug' }
  if(-not $hasOut){  $missing += 'outcome' }

  if($missing.Count -gt 0){
    $errors += ("Entrée ~L{0}: clés manquantes -> {1}" -f $b.Start, ($missing -join ", "))
  }
}

if($errors.Count -gt 0){
  Write-Error ("Telemetry lint failed:`n" + ($errors -join "`n"))
  exit 1
} else {
  Write-Host "✅ Telemetry OK"
}
