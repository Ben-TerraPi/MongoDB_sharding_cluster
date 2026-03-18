Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Restarting MongoDB Cluster" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# RS01
Write-Host "Starting rs01..." -ForegroundColor Yellow
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--shardsvr --replSet rs01 --port 27017 --dbpath C:\mongo-rs\27017 --bind_ip 127.0.0.1 --logpath C:\mongo-rs\27017\mongod.log --logappend"
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--shardsvr --replSet rs01 --port 27018 --dbpath C:\mongo-rs\27018 --bind_ip 127.0.0.1 --logpath C:\mongo-rs\27018\mongod.log --logappend"
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--shardsvr --replSet rs01 --port 27019 --dbpath C:\mongo-rs\27019 --bind_ip 127.0.0.1 --logpath C:\mongo-rs\27019\mongod.log --logappend"
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--shardsvr --replSet rs01 --port 27020 --dbpath C:\mongo-rs\27020 --bind_ip 127.0.0.1 --logpath C:\mongo-rs\27020\mongod.log --logappend"
Start-Sleep -Seconds 5
Write-Host "✅ rs01 started`n" -ForegroundColor Green

# RS02
Write-Host "Starting rs02..." -ForegroundColor Yellow
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--shardsvr --replSet rs02 --port 27401 --dbpath C:\mongo-shard\rs02-1 --bind_ip 127.0.0.1 --logpath C:\mongo-shard\rs02-1\mongod.log --logappend"
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--shardsvr --replSet rs02 --port 27402 --dbpath C:\mongo-shard\rs02-2 --bind_ip 127.0.0.1 --logpath C:\mongo-shard\rs02-2\mongod.log --logappend"
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--shardsvr --replSet rs02 --port 27403 --dbpath C:\mongo-shard\rs02-3 --bind_ip 127.0.0.1 --logpath C:\mongo-shard\rs02-3\mongod.log --logappend"
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--shardsvr --replSet rs02 --port 27404 --dbpath C:\mongo-shard\rs02-4 --bind_ip 127.0.0.1 --logpath C:\mongo-shard\rs02-4\mongod.log --logappend"
Start-Sleep -Seconds 5
Write-Host "✅ rs02 started`n" -ForegroundColor Green

# Config & Mongos
Write-Host "Starting Config Server & Mongos..." -ForegroundColor Yellow
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--configsvr --replSet cfgRS --port 27100 --dbpath C:\mongo-shard\cfg01 --bind_ip 127.0.0.1 --logpath C:\mongo-shard\cfg01\mongod.log --logappend"
Start-Sleep -Seconds 5
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongos.exe" -ArgumentList "--configdb cfgRS/127.0.0.1:27100 --port 27050 --bind_ip 127.0.0.1 --logpath C:\mongo-shard\mongos.log --logappend"
Start-Sleep -Seconds 10
Write-Host "✅ Config Server & Mongos started`n" -ForegroundColor Green

Write-Host "========================================" -ForegroundColor Green
Write-Host "✅ Cluster Restarted" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

mongosh --port 27050 --eval "sh.status()"