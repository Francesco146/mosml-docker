#!/usr/bin/env pwsh

$IMAGE_NAME = "ghcr.io/francesco146/mosml:latest"
$DOCKERHUB_IMAGE = "docker.io/francescom0/mosml:latest"
$LOCAL_IMAGE_NAME = "mosml:latest"

if (-not (Test-Path -Path "src")) {
    New-Item -ItemType Directory -Path "src" | Out-Null
}

$localId = docker images -q $LOCAL_IMAGE_NAME 2>$null
$dockerhubId = docker images -q $DOCKERHUB_IMAGE 2>$null
$remoteId = docker images -q $IMAGE_NAME 2>$null
$selectedImage = $null

if ($localId -ne "") {
    Write-Host "Using local image: $LOCAL_IMAGE_NAME" -ForegroundColor Green
    $selectedImage = $LOCAL_IMAGE_NAME
} elseif ($dockerhubId -ne "") {
    Write-Host "Using Docker Hub image: $DOCKERHUB_IMAGE" -ForegroundColor Green
    $selectedImage = $DOCKERHUB_IMAGE
} elseif ($remoteId -ne "") {
    Write-Host "Using GHCR image: $IMAGE_NAME" -ForegroundColor Green
    $selectedImage = $IMAGE_NAME
} else {
    # Prova Docker Hub, poi GHCR, infine build locale
    docker pull $DOCKERHUB_IMAGE 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Pulled $DOCKERHUB_IMAGE" -ForegroundColor Green
        $selectedImage = $DOCKERHUB_IMAGE
    } else {
        docker pull $IMAGE_NAME 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Pulled $IMAGE_NAME" -ForegroundColor Green
            $selectedImage = $IMAGE_NAME
        } else {
            Write-Host "Failed to pull image from registries. Building locally..." -ForegroundColor Yellow
            docker compose build --quiet
            $selectedImage = $LOCAL_IMAGE_NAME
        }
    }
}

$currentPath = (Get-Location).Path.Replace('\', '/')
# Esegue con docker run per evitare pull non necessari
docker run --rm -it `
    --platform linux/amd64 `
    -v "${currentPath}/src:/workspace" `
    $selectedImage @args
