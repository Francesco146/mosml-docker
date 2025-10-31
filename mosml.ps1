#!/usr/bin/env pwsh

# Moscow ML Docker Wrapper Script
# Automatically pulls from GitHub Container Registry or builds locally if needed

$IMAGE_NAME = "ghcr.io/YOUR_GITHUB_USERNAME/mosml-docker:latest"
$LOCAL_IMAGE_NAME = "mosml-docker:latest"

# Crea la directory src se non esiste
if (-not (Test-Path -Path "src")) {
    New-Item -ItemType Directory -Path "src" | Out-Null
}

# Funzione per buildare l'immagine localmente
function Build-Image {
    Write-Host "Building image locally..." -ForegroundColor Yellow
    docker build --platform linux/amd64 -t $IMAGE_NAME -t $LOCAL_IMAGE_NAME .
}

# Prova a pullare l'immagine dal registry
Write-Host "Attempting to pull image from registry..." -ForegroundColor Cyan
docker pull $IMAGE_NAME 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to pull image from registry. Building locally..." -ForegroundColor Yellow
    Build-Image
}

# Esegui il container
$currentPath = (Get-Location).Path.Replace('\', '/')
if ($args.Count -eq 0) {
    # Modalità interattiva
    docker run --rm -it `
        --platform linux/amd64 `
        -v "${currentPath}/src:/workspace" `
        $IMAGE_NAME
} else {
    # Esegui file specifico
    docker run --rm -it `
        --platform linux/amd64 `
        -v "${currentPath}/src:/workspace" `
        $IMAGE_NAME @args
}
