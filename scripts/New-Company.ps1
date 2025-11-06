param([Parameter(Mandatory=True)][string])
function Slug([string]){ =.ToLower(); = -replace "[àáâäãå]","a" -replace "[èéêë]","e" -replace "[ìíîï]","i" -replace "[òóôöõ]","o" -replace "[ùúûü]","u" -replace "ç","c"; = -replace "[^a-z0-9\s-]",""; = -replace "\s+","-"; .Trim("-") }
 = Slug ; ="artifacts\companies\"
New-Item -ItemType Directory -Force -Path "\evidence" | Out-Null
(Get-Content "templates\company_profile_template.md" -Raw) -replace "\{Company Name\}",  -replace "\{company-slug\}",  -replace "\{YYYY-MM-DD\}", (Get-Date -Format 'yyyy-MM-dd') | Set-Content -Encoding UTF8 "\profile.md"
"{}" | Set-Content -Encoding UTF8 "\signals.json"
New-Item -ItemType File -Force -Path "\evidence\.gitkeep" | Out-Null
Write-Host "✅ Company scaffolded: "
