#!/bin/bash

# Moscow ML Docker Wrapper Script
# Automatically pulls from GitHub Container Registry or builds locally if needed

IMAGE_NAME="ghcr.io/francesco146/mosml:latest"
LOCAL_IMAGE_NAME="mosml:latest"

# Crea la directory src se non esiste
mkdir -p src

# Funzione per buildare l'immagine localmente
build_image() {
    echo "Building image locally..."
    docker build --platform linux/amd64 -t "$IMAGE_NAME" -t "$LOCAL_IMAGE_NAME" .
}

# Verifica se l'immagine esiste localmente (preferisce il tag locale se presente)
SELECTED_IMAGE=""
if [ -n "$(docker images -q "$LOCAL_IMAGE_NAME" 2>/dev/null)" ]; then
    echo "Found local image: $LOCAL_IMAGE_NAME"
    SELECTED_IMAGE="$LOCAL_IMAGE_NAME"
elif [ -n "$(docker images -q "$IMAGE_NAME" 2>/dev/null)" ]; then
    echo "Found local image: $IMAGE_NAME"
    SELECTED_IMAGE="$IMAGE_NAME"
else
    # Prova a pullare l'immagine dal registry
    echo "Attempting to pull image from registry: $IMAGE_NAME"
    if docker pull "$IMAGE_NAME" >/dev/null 2>&1; then
        echo "Pulled $IMAGE_NAME"
        SELECTED_IMAGE="$IMAGE_NAME"
    else
        echo "Failed to pull image from registry. Building locally..."
        build_image
        SELECTED_IMAGE="$IMAGE_NAME"
    fi
fi

# Esegui il container con l'immagine selezionata
if [ -z "$SELECTED_IMAGE" ]; then
    echo "No image selected, aborting."
    exit 1
fi

if [ $# -eq 0 ]; then
    # Modalità interattiva
    docker run --rm -it \
        --platform linux/amd64 \
        -v "$(pwd)/src:/workspace" \
        "$SELECTED_IMAGE"
else
    # Esegui file specifico
    docker run --rm -it \
        --platform linux/amd64 \
        -v "$(pwd)/src:/workspace" \
        "$SELECTED_IMAGE" "$@"
fi
