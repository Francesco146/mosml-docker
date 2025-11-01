#!/bin/bash

IMAGE_NAME="ghcr.io/francesco146/mosml:latest"
DOCKERHUB_IMAGE="docker.io/francescom0/mosml:latest"
LOCAL_IMAGE_NAME="mosml:latest"

mkdir -p src

SELECTED_IMAGE=""
if [ -n "$(docker images -q "$LOCAL_IMAGE_NAME" 2>/dev/null)" ]; then
    echo "Using local image: $LOCAL_IMAGE_NAME"
    SELECTED_IMAGE="$LOCAL_IMAGE_NAME"
elif [ -n "$(docker images -q "$DOCKERHUB_IMAGE" 2>/dev/null)" ]; then
    echo "Using Docker Hub image: $DOCKERHUB_IMAGE"
    SELECTED_IMAGE="$DOCKERHUB_IMAGE"
elif [ -n "$(docker images -q "$IMAGE_NAME" 2>/dev/null)" ]; then
    echo "Using GHCR image: $IMAGE_NAME"
    SELECTED_IMAGE="$IMAGE_NAME"
else
    # Prova Docker Hub, poi GHCR, infine build locale
    if docker pull "$DOCKERHUB_IMAGE" >/dev/null 2>&1; then
        echo "Pulled $DOCKERHUB_IMAGE"
        SELECTED_IMAGE="$DOCKERHUB_IMAGE"
    elif docker pull "$IMAGE_NAME" >/dev/null 2>&1; then
        echo "Pulled $IMAGE_NAME"
        SELECTED_IMAGE="$IMAGE_NAME"
    else
        echo "Failed to pull image from registries. Building locally..."
        docker compose build --quiet
        SELECTED_IMAGE="$LOCAL_IMAGE_NAME"
    fi
fi

# Esegue con docker run per evitare pull non necessari
docker run --rm -it \
    --platform linux/amd64 \
    -v "$(pwd)/src:/workspace" \
    "$SELECTED_IMAGE" "$@"
