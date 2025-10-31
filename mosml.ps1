#!/usr/bin/env pwsh

$IMAGE_NAME = "ghcr.io/francesco146/mosml:latest"
$LOCAL_IMAGE_NAME = "mosml:latest"

if (-not (Test-Path -Path "src")) {
    New-Item -ItemType Directory -Path "src" | Out-Null
}

# Preferisce l'immagine locale se presente
# altrimenti prova a pullare dal registry
# altrimenti builda localmente usando il Dockerfile
$selectedImage = $null
$localId = docker images -q $LOCAL_IMAGE_NAME 2>$null
if ($localId -ne "") {
    Write-Host "Found local image: $LOCAL_IMAGE_NAME" -ForegroundColor Green
    $selectedImage = $LOCAL_IMAGE_NAME
} else {
    $remoteId = docker images -q $IMAGE_NAME 2>$null
    if ($remoteId -ne "") {
        Write-Host "Found local image: $IMAGE_NAME" -ForegroundColor Green
        $selectedImage = $IMAGE_NAME
    } else {
        docker pull $IMAGE_NAME 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Pulled $IMAGE_NAME" -ForegroundColor Green
            $selectedImage = $IMAGE_NAME
        } else {
            Write-Host "Failed to pull image from registry. Building locally..." -ForegroundColor Yellow
            docker build --platform linux/amd64 -t $IMAGE_NAME -t $LOCAL_IMAGE_NAME .
            $selectedImage = $IMAGE_NAME
        }
    }
}

$currentPath = (Get-Location).Path.Replace('\', '/')
if (-not $selectedImage) {
    Write-Host "No image selected, aborting." -ForegroundColor Red
    exit 1
}

docker run --rm -it `
    --platform linux/amd64 `
    -v "${currentPath}/src:/workspace" `
    $selectedImage @args
