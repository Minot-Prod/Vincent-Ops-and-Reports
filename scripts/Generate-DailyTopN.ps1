param([int]$Top=5)

$scored   = "artifacts\crm\companies_scored.csv"
$template = "templates\daily_topN_template.md"
$today    = Get-Date -Format 'yyyy-MM-dd'
$out      = "reports/daily/${today}_topN.md"

if (!(Test-Path $scored))   { throw "Manque $scored (lance Score-Companies.ps1)" }
if (!(Test-Path $template)) { throw "Manque $template" }

$rows = Import-Csv $scored | Sort-Object score -Descending | Select-Object -First $Top

$lines = @(); $i = 1
foreach($r in $rows){
  $lines += ("{0}) {1} — Score {2} — Angle: {{événement à valider}} — CTA: {{call/email/LD}}" -f $i, $r.company_name, $r.score)
  $i++
}
$topBlock = ($lines -join "`r`n")

$content = (Get-Content $template -Raw) -replace "\{YYYY-MM-DD\}", $today
$content = [regex]::Replace($content, '(?s)## Top 5 Comptes & Actions.*?## Contexte rapide', "## Top 5 Comptes & Actions`r`n$topBlock`r`n`r`n## Contexte rapide")

Set-Content -Encoding UTF8 $out $content
Write-Host "✅ Daily generated -> $out"
