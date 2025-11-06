param()

$in  = "artifacts\crm\companies_normalized.csv"
$out = "artifacts\crm\companies_scored.csv"
if (!(Test-Path $in)) { throw "Fichier normalisé manquant: $in (lance Normalize-CRM.ps1)" }

# Poids & règles (SYNC)
$W_fit = 0.40; $W_timing = 0.40; $W_access = 0.20
$sectorPattern = "marketing|communication|événement|technologie|immobilier|institution|santé|éducation|agence|retail"
$eventKeywords = @("lancement","congrès","gala","expo","salon","colloque","festival","webinaire","campagne","événement","hybride","virtuel")
$recentCommWindowDays = 60

function Clamp([double]$x,[double]$min,[double]$max){ if($x -lt $min){return $min} elseif($x -gt $max){return $max} else {return $x} }

$rows = Import-Csv -Path $in
$scored = foreach($r in $rows){
  # FIT
  $fit = 0.0
  if ($r.sector -and ($r.sector -match $sectorPattern)) { $fit += 0.6 }
  switch ($r.size) { "enterprise" { $fit += 0.4 } "mid" { $fit += 0.28 } default { $fit += 0.12 } }
  $fit = Clamp $fit 0 1

  # TIMING
  $timing = 0.0
  if ([int]$r.recent_comm_days -le $recentCommWindowDays) { $timing += 0.3 }
  if ($r.news_keywords) {
    $kw = ($r.news_keywords -split ",") | ForEach-Object { $_.Trim().ToLower() }
    if ($kw | Where-Object { $eventKeywords -contains $_ }) { $timing += 0.5 }
  }
  $timing = Clamp $timing 0 1

  # ACCESS
  $access = 0.0
  if ([int]$r.known_contacts -gt 0) { $access += 0.2 }
  if ([bool]$r.warm_intro -eq $true) { $access += 0.3 }
  if ([bool]$r.prev_project -eq $true) { $access += 0.4 }
  $access = Clamp $access 0 1

  # SCORE GLOBAL
  $score01 = $W_fit*$fit + $W_timing*$timing + $W_access*$access
  $score   = [math]::Round(100 * (Clamp $score01 0 1), 1)

  [pscustomobject]@{
    company_name = $r.company_name
    slug         = $r.slug
    website      = $r.website
    sector       = $r.sector
    size         = $r.size
    fit          = [math]::Round(100*$fit,1)
    timing       = [math]::Round(100*$timing,1)
    access       = [math]::Round(100*$access,1)
    score        = $score
  }
}

$scored | Sort-Object score -Descending | Export-Csv -NoTypeInformation -Encoding UTF8 $out
Write-Host "✅ Scored -> $out"
