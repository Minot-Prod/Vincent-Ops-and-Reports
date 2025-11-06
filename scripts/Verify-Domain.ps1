=@("banque","assurance","services financiers")
=@("SYNC Productions","événement","audiovisuel","scénographie","hybride","virtuel")
 = git ls-files | % { =; (Get-Content  -Raw -ErrorAction SilentlyContinue) | % { foreach( in ){ if( -match "(?i)\b\b"){ [pscustomobject]@{file=; term=} } } } }
  = git ls-files | % { =; =Get-Content  -Raw -ErrorAction SilentlyContinue; if( -match "(?i)SYNC Productions|événement"){ True } } | ? {  -eq True }
if(){ Write-Error "Domain guard: termes interdits détectés.
"; exit 1 }
if(-not ){ Write-Error "Domain guard: ancres 'SYNC Productions/événement' introuvables."; exit 1 }
Write-Host "✅ Domain guard OK"
