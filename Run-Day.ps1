powershell -ExecutionPolicy Bypass -File scripts\Normalize-CRM.ps1
powershell -ExecutionPolicy Bypass -File scripts\Score-Companies.ps1
powershell -ExecutionPolicy Bypass -File scripts\Generate-DailyTopN.ps1 -Top 5
git add artifacts/crm/companies_* reports/daily/*_topN.md
git commit -m "Daily: normalize/score/topN"
git push
