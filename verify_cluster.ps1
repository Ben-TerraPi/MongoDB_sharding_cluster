Write-Host "========================================" -ForegroundColor Cyan
Write-Host "MongoDB Cluster Verification" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[1] Cluster Status" -ForegroundColor Yellow
mongosh --port 27050 --eval "sh.status()"

Write-Host "`n[2] rs01 Members" -ForegroundColor Yellow
mongosh --port 27017 --eval "rs.status().members[*].name"

Write-Host "`n[3] rs02 Members" -ForegroundColor Yellow
mongosh --port 27401 --eval "rs.status().members[*].name"

Write-Host "`n[4] Paris Documents" -ForegroundColor Yellow
mongosh --port 27050 --eval "db.NosCites.listing.countDocuments({data_city: 'Paris'})"

Write-Host "`n[5] Lyon Documents" -ForegroundColor Yellow
mongosh --port 27050 --eval "db.NosCites.listing.countDocuments({data_city: 'Lyon'})"

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "✅ Verification Complete" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green