#!/usr/bin/env pwsh

# Moscow ML Docker Wrapper Script
# Automatically pulls from GitHub Container Registry or builds locally if needed

$IMAGE_NAME = "ghcr.io/francesco146/mosml:latest"
$LOCAL_IMAGE_NAME = "mosml:latest"

# Crea la directory src se non esiste
if (-not (Test-Path -Path "src")) {
    New-Item -ItemType Directory -Path "src" | Out-Null
}

# Funzione per buildare l'immagine localmente
function Build-Image {
    Write-Host "Building image locally..." -ForegroundColor Yellow
    docker build --platform linux/amd64 -t $IMAGE_NAME -t $LOCAL_IMAGE_NAME .
}

# Controlla se l'immagine esiste localmente (preferisce il tag locale se presente)
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
        Write-Host "Attempting to pull image from registry: $IMAGE_NAME" -ForegroundColor Cyan
        docker pull $IMAGE_NAME 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Pulled $IMAGE_NAME" -ForegroundColor Green
            $selectedImage = $IMAGE_NAME
        } else {
            Write-Host "Failed to pull image from registry. Building locally..." -ForegroundColor Yellow
            Build-Image
            $selectedImage = $IMAGE_NAME
        }
    }
}

# Esegui il container
$currentPath = (Get-Location).Path.Replace('\', '/')
if (-not $selectedImage) {
    Write-Host "No image selected, aborting." -ForegroundColor Red
    exit 1
}

if ($args.Count -eq 0) {
    # Modalità interattiva
    docker run --rm -it `
        --platform linux/amd64 `
        -v "${currentPath}/src:/workspace" `
        $selectedImage
} else {
    # Esegui file specifico
    docker run --rm -it `
        --platform linux/amd64 `
        -v "${currentPath}/src:/workspace" `
        $selectedImage @args
}
