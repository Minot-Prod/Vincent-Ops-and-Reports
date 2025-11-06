param()

$in  = "artifacts\crm\companies_raw.csv"
$out = "artifacts\crm\companies_normalized.csv"
if (!(Test-Path $in)) { throw "Fichier manquant: $in" }

function Slug([string]$s){
  $s = $s.ToLower()
  $s = $s -replace "[àáâäãå]","a" -replace "[èéêë]","e" -replace "[ìíîï]","i" -replace "[òóôöõ]","o" -replace "[ùúûü]","u" -replace "ç","c"
  $s = $s -replace "[^a-z0-9\s-]",""
  $s = $s -replace "\s+","-"
  return $s.Trim("-")
}

$rows = Import-Csv -Path $in
$norm = foreach($r in $rows){
  $kc = 0; if ($r.known_contacts -ne $null -and $r.known_contacts -ne "") { $kc = [int]$r.known_contacts }
  $wi = $false; if ($r.warm_intro) { if ($r.warm_intro.ToString().ToLower() -in @("true","1","yes","y","vrai","oui")) { $wi = $true } }
  $rcd = 9999; if ($r.recent_comm_days -ne $null -and $r.recent_comm_days -ne "") { $rcd = [int]$r.recent_comm_days }
  $pp = $false; if ($r.prev_project) { if ($r.prev_project.ToString().ToLower() -in @("true","1","yes","y","vrai","oui")) { $pp = $true } }

  [pscustomobject]@{
    company_name     = $r.company_name
    slug             = Slug $r.company_name
    website          = $r.website
    sector           = ($r.sector).ToLower()
    size             = ($r.size).ToLower()           # small|mid|enterprise
    known_contacts   = $kc
    warm_intro       = $wi
    recent_comm_days = $rcd
    news_keywords    = $r.news_keywords
    prev_project     = $pp
  }
}

$norm | Export-Csv -NoTypeInformation -Encoding UTF8 $out
Write-Host "✅ Normalized -> $out"
