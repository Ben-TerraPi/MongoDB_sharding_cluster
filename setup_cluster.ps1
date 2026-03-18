<#
.SYNOPSIS
    Installation complète d'un cluster MongoDB shardé (2 replica sets)
.DESCRIPTION
    - Import données Paris/Lyon
    - 2 Replica Sets (rs01 + rs02) avec arbitres
    - Config Server + Mongos
    - Sharding par data_city
.EXAMPLE
    .\setup_cluster.ps1
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "MongoDB Sharding Cluster Setup" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ===== ÉTAPE 0 : NETTOYAGE =====
Write-Host "[ÉTAPE 0] Nettoyage..." -ForegroundColor Yellow
Get-Process mongod, mongos -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

Remove-Item C:\mongo-rs\*, C:\mongo-shard\* -Recurse -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

New-Item -ItemType Directory C:\mongo-rs\27017, C:\mongo-rs\27018, C:\mongo-rs\27019, C:\mongo-rs\27020, C:\mongo-shard\rs02-1, C:\mongo-shard\rs02-2, C:\mongo-shard\rs02-3, C:\mongo-shard\rs02-4, C:\mongo-shard\cfg01 | Out-Null
Write-Host "✅ Nettoyage terminé`n" -ForegroundColor Green

# ===== ÉTAPE 1 : IMPORT DONNÉES =====
Write-Host "[ÉTAPE 1] Import des données..." -ForegroundColor Yellow
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--port 27017 --dbpath C:\mongo-rs\27017 --bind_ip 127.0.0.1 --logpath C:\mongo-rs\27017\mongod.log --logappend"
Start-Sleep -Seconds 5

mongoimport --port 27017 --db NosCites --collection listing --file "C:\Users\benoit\Docs\OpenClassrooms\Projets\projet7_listing\listings_Paris.csv" --type csv --headerline

mongosh --port 27017 --eval "db.getSiblingDB('NosCites').listing.updateMany({}, {\$set: {data_city: 'Paris'}})"

mongoimport --port 27017 --db NosCites --collection listing --file "C:\Users\benoit\Docs\OpenClassrooms\Projets\projet7_listing\listings_Lyon.csv" --type csv --headerline

mongosh --port 27017 --eval "db.getSiblingDB('NosCites').listing.updateMany({data_city: {\$ne: 'Paris'}}, {\$set: {data_city: 'Lyon'}})"

$docCount = mongosh --port 27017 --eval "db.getSiblingDB('NosCites').listing.countDocuments()" 2>&1 | Select-Object -Last 1
Write-Host "✅ Import terminé ($docCount documents)`n" -ForegroundColor Green

# ===== ÉTAPE 2 : REPLICA SETS =====
Write-Host "[ÉTAPE 2] Configuration replica sets..." -ForegroundColor Yellow
Get-Process mongod -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

# RS01
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--shardsvr --replSet rs01 --port 27017 --dbpath C:\mongo-rs\27017 --bind_ip 127.0.0.1 --logpath C:\mongo-rs\27017\mongod.log --logappend"
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--shardsvr --replSet rs01 --port 27018 --dbpath C:\mongo-rs\27018 --bind_ip 127.0.0.1 --logpath C:\mongo-rs\27018\mongod.log --logappend"
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--shardsvr --replSet rs01 --port 27019 --dbpath C:\mongo-rs\27019 --bind_ip 127.0.0.1 --logpath C:\mongo-rs\27019\mongod.log --logappend"

Start-Sleep -Seconds 5
mongosh --port 27017 --eval "rs.initiate({_id: 'rs01', members: [{_id: 0, host: '127.0.0.1:27017', priority: 2}, {_id: 1, host: '127.0.0.1:27018', priority: 1}, {_id: 2, host: '127.0.0.1:27019', priority: 1}]})"
Write-Host "✅ rs01 initialisé" -ForegroundColor Green
Start-Sleep -Seconds 10

# RS02
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--shardsvr --replSet rs02 --port 27401 --dbpath C:\mongo-shard\rs02-1 --bind_ip 127.0.0.1 --logpath C:\mongo-shard\rs02-1\mongod.log --logappend"
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--shardsvr --replSet rs02 --port 27402 --dbpath C:\mongo-shard\rs02-2 --bind_ip 127.0.0.1 --logpath C:\mongo-shard\rs02-2\mongod.log --logappend"
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--shardsvr --replSet rs02 --port 27403 --dbpath C:\mongo-shard\rs02-3 --bind_ip 127.0.0.1 --logpath C:\mongo-shard\rs02-3\mongod.log --logappend"

Start-Sleep -Seconds 5
mongosh --port 27401 --eval "rs.initiate({_id: 'rs02', members: [{_id: 0, host: '127.0.0.1:27401', priority: 2}, {_id: 1, host: '127.0.0.1:27402', priority: 1}, {_id: 2, host: '127.0.0.1:27403', priority: 1}]})"
Write-Host "✅ rs02 initialisé`n" -ForegroundColor Green
Start-Sleep -Seconds 10

# ===== ÉTAPE 3 : CONFIG SERVER & MONGOS =====
Write-Host "[ÉTAPE 3] Config Server & Mongos..." -ForegroundColor Yellow
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--configsvr --replSet cfgRS --port 27100 --dbpath C:\mongo-shard\cfg01 --bind_ip 127.0.0.1 --logpath C:\mongo-shard\cfg01\mongod.log --logappend"
Start-Sleep -Seconds 5
mongosh --port 27100 --eval "rs.initiate({_id: 'cfgRS', configsvr: true, members: [{_id: 0, host: '127.0.0.1:27100'}]})"
Write-Host "✅ Config Server initialisé" -ForegroundColor Green
Start-Sleep -Seconds 5

Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongos.exe" -ArgumentList "--configdb cfgRS/127.0.0.1:27100 --port 27050 --bind_ip 127.0.0.1 --logpath C:\mongo-shard\mongos.log --logappend"
Write-Host "✅ Mongos lancé`n" -ForegroundColor Green
Start-Sleep -Seconds 15

# ===== ÉTAPE 4 : SHARDING =====
Write-Host "[ÉTAPE 4] Configuration sharding..." -ForegroundColor Yellow
mongosh --port 27050 --eval "sh.addShard('rs01/127.0.0.1:27017,127.0.0.1:27018,127.0.0.1:27019')"
Start-Sleep -Seconds 5

mongosh --port 27050 --eval "sh.addShard('rs02/127.0.0.1:27401,127.0.0.1:27402,127.0.0.1:27403')"
Start-Sleep -Seconds 5

mongosh --port 27050 --eval "sh.enableSharding('NosCites')"
Start-Sleep -Seconds 3

mongosh --port 27050 --eval "db.getSiblingDB('NosCites').listing.createIndex({data_city: 1})"
Start-Sleep -Seconds 3

mongosh --port 27050 --eval "sh.shardCollection('NosCites.listing', {data_city: 1})"
Write-Host "✅ Sharding configuré`n" -ForegroundColor Green
Start-Sleep -Seconds 5

# ===== ÉTAPE 5 : ARBITRES =====
Write-Host "[ÉTAPE 5] Ajout des arbitres..." -ForegroundColor Yellow

# Arbitre rs01
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--shardsvr --replSet rs01 --port 27020 --dbpath C:\mongo-rs\27020 --bind_ip 127.0.0.1 --logpath C:\mongo-rs\27020\mongod.log --logappend"
Start-Sleep -Seconds 5

mongosh --port 27050 --eval "db.adminCommand({setDefaultRWConcern: 1, defaultWriteConcern: {w: 2}})"
Start-Sleep -Seconds 3

mongosh --port 27017 --eval "rs.add({_id: 3, host: '127.0.0.1:27020', arbiterOnly: true})"
Write-Host "✅ Arbitre rs01 (27020) ajouté" -ForegroundColor Green
Start-Sleep -Seconds 5

# Arbitre rs02
Start-Process "C:\Program Files\MongoDB\Server\8.2\bin\mongod.exe" -ArgumentList "--shardsvr --replSet rs02 --port 27404 --dbpath C:\mongo-shard\rs02-4 --bind_ip 127.0.0.1 --logpath C:\mongo-shard\rs02-4\mongod.log --logappend"
Start-Sleep -Seconds 5

mongosh --port 27401 --eval "rs.add({_id: 3, host: '127.0.0.1:27404', arbiterOnly: true})"
Write-Host "✅ Arbitre rs02 (27404) ajouté`n" -ForegroundColor Green
Start-Sleep -Seconds 5

# ===== ÉTAPE 6 : VÉRIFICATION =====
Write-Host "[ÉTAPE 6] Vérification finale..." -ForegroundColor Yellow
Write-Host "`n--- Cluster Status ---" -ForegroundColor Cyan
mongosh --port 27050 --eval "sh.status()"

Write-Host "`n--- rs01 Config ---" -ForegroundColor Cyan
mongosh --port 27017 --eval "rs.conf()"

Write-Host "`n--- rs02 Config ---" -ForegroundColor Cyan
mongosh --port 27401 --eval "rs.conf()"

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "✅ CLUSTER READY!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green