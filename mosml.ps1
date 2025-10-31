#!/usr/bin/env pwsh

$IMAGE_NAME = "ghcr.io/francesco146/mosml:latest"
$LOCAL_IMAGE_NAME = "mosml:latest"

if (-not (Test-Path -Path "src")) {
    New-Item -ItemType Directory -Path "src" | Out-Null
}

$localId = docker images -q $LOCAL_IMAGE_NAME 2>$null
$remoteId = docker images -q $IMAGE_NAME 2>$null
$selectedImage = $null

if ($localId -ne "") {
    Write-Host "Using local image: $LOCAL_IMAGE_NAME" -ForegroundColor Green
    $selectedImage = $LOCAL_IMAGE_NAME
} elseif ($remoteId -ne "") {
    Write-Host "Using local image: $IMAGE_NAME" -ForegroundColor Green
    $selectedImage = $IMAGE_NAME
} else {
    docker pull $IMAGE_NAME 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Pulled $IMAGE_NAME" -ForegroundColor Green
        $selectedImage = $IMAGE_NAME
    } else {
        Write-Host "Failed to pull image from registry. Building locally..." -ForegroundColor Yellow
        docker compose build --quiet
        $selectedImage = $LOCAL_IMAGE_NAME
    }
}

$currentPath = (Get-Location).Path.Replace('\', '/')
# Esegue con docker run per evitare pull non necessari
docker run --rm -it `
    --platform linux/amd64 `
    -v "${currentPath}/src:/workspace" `
    $selectedImage @args
