#!/bin/bash

# Moscow ML Docker Wrapper Script
# Automatically pulls from GitHub Container Registry or builds locally if needed

IMAGE_NAME="ghcr.io/YOUR_GITHUB_USERNAME/mosml-docker:latest"
LOCAL_IMAGE_NAME="mosml-docker:latest"

# Crea la directory src se non esiste
mkdir -p src

# Funzione per buildare l'immagine localmente
build_image() {
    echo "Building image locally..."
    docker build --platform linux/amd64 -t "$IMAGE_NAME" -t "$LOCAL_IMAGE_NAME" .
}

# Prova a pullare l'immagine dal registry
if ! docker pull "$IMAGE_NAME" 2>/dev/null; then
    echo "Failed to pull image from registry. Building locally..."
    build_image
fi

# Esegui il container
if [ $# -eq 0 ]; then
    # Modalità interattiva
    docker run --rm -it \
        --platform linux/amd64 \
        -v "$(pwd)/src:/workspace" \
        "$IMAGE_NAME"
else
    # Esegui file specifico
    docker run --rm -it \
        --platform linux/amd64 \
        -v "$(pwd)/src:/workspace" \
        "$IMAGE_NAME" "$@"
fi
