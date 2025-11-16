#!/bin/bash

# Determina la container engine installata nel sistema
CONTAINER_ENGINE=$(command -v podman &> /dev/null && echo "podman" || echo "docker")

# Stampa a schermo una hint per debugging
echo "Using container engine: $CONTAINER_ENGINE"

IMAGE_NAME="ghcr.io/francesco146/mosml:latest"
DOCKERHUB_IMAGE="docker.io/francescom0/mosml:latest"
LOCAL_IMAGE_NAME="mosml:latest"

mkdir -p src

SELECTED_IMAGE=""
if [ -n "$("$CONTAINER_ENGINE" images -q "$LOCAL_IMAGE_NAME" 2>/dev/null)" ]; then
    echo "Using local image: $LOCAL_IMAGE_NAME"
    SELECTED_IMAGE="$LOCAL_IMAGE_NAME"
elif [ -n "$("$CONTAINER_ENGINE" images -q "$DOCKERHUB_IMAGE" 2>/dev/null)" ]; then
    echo "Using Docker Hub image: $DOCKERHUB_IMAGE"
    SELECTED_IMAGE="$DOCKERHUB_IMAGE"
elif [ -n "$("$CONTAINER_ENGINE" images -q "$IMAGE_NAME" 2>/dev/null)" ]; then
    echo "Using GHCR image: $IMAGE_NAME"
    SELECTED_IMAGE="$IMAGE_NAME"
else
    # Prova Docker Hub, poi GHCR, infine build locale
    if "$CONTAINER_ENGINE" pull "$DOCKERHUB_IMAGE" >/dev/null 2>&1; then
        echo "Pulled $DOCKERHUB_IMAGE"
        SELECTED_IMAGE="$DOCKERHUB_IMAGE"
    elif "$CONTAINER_ENGINE" pull "$IMAGE_NAME" >/dev/null 2>&1; then
        echo "Pulled $IMAGE_NAME"
        SELECTED_IMAGE="$IMAGE_NAME"
    else
        echo "Failed to pull image from registries. Building locally..."
        "$CONTAINER_ENGINE" compose build --quiet
        SELECTED_IMAGE="$LOCAL_IMAGE_NAME"
    fi
fi

# Esegue con docker run per evitare pull non necessari
"$CONTAINER_ENGINE" run --rm -it \
    --pull=never \
    --platform linux/amd64 \
    -v "$(pwd)/src:/workspace:Z" \
    "$SELECTED_IMAGE" "$@"
