<#
.SYNOPSIS
    Arrêt propre du cluster MongoDB (sans supprimer les données)
.DESCRIPTION
    Arrête tous les processus mongod et mongos
    Les données restent intactes dans les dossiers de stockage
.EXAMPLE
    .\stop_cluster.ps1
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "MongoDB Cluster Shutdown" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[1] Arret de Mongos..." -ForegroundColor Yellow
Get-Process mongos -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host "[2] Arret de tous les Mongod..." -ForegroundColor Yellow
Get-Process mongod -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

Write-Host "[3] Verification des processus..." -ForegroundColor Yellow
$remaining = Get-Process mongod, mongos -ErrorAction SilentlyContinue
if ($remaining) {
    Write-Host " Processus restants:" -ForegroundColor Yellow
    $remaining | ForEach-Object { Write-Host "  - $($_.ProcessName) (PID: $($_.Id))" }
} else {
    Write-Host " Aucun processus MongoDB actif`n" -ForegroundColor Green
}

Write-Host "========================================" -ForegroundColor Green
Write-Host " CLUSTER ARRETE" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

Write-Host " Donnees preservees dans:" -ForegroundColor Cyan
Write-Host "  C:\mongo-rs\27017, 27018, 27019, 27020" -ForegroundColor Cyan
Write-Host "  C:\mongo-shard\rs02-1, rs02-2, rs02-3, rs02-4" -ForegroundColor Cyan
Write-Host "  C:\mongo-shard\cfg01`n" -ForegroundColor Cyan

Write-Host "Pour relancer le cluster :" -ForegroundColor Yellow
Write-Host "  .\restart_cluster.ps1" -ForegroundColor Yellow
Write-Host "" -ForegroundColor Yellow