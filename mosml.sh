#!/bin/bash

IMAGE_NAME="ghcr.io/francesco146/mosml:latest"
LOCAL_IMAGE_NAME="mosml:latest"

mkdir -p src

SELECTED_IMAGE=""
if [ -n "$(docker images -q "$LOCAL_IMAGE_NAME" 2>/dev/null)" ]; then
    echo "Using local image: $LOCAL_IMAGE_NAME"
    SELECTED_IMAGE="$LOCAL_IMAGE_NAME"
elif [ -n "$(docker images -q "$IMAGE_NAME" 2>/dev/null)" ]; then
    echo "Using local image: $IMAGE_NAME"
    SELECTED_IMAGE="$IMAGE_NAME"
else
    if docker pull "$IMAGE_NAME" >/dev/null 2>&1; then
        echo "Pulled $IMAGE_NAME"
        SELECTED_IMAGE="$IMAGE_NAME"
    else
        echo "Failed to pull image from registry. Building locally..."
        docker compose build --quiet
        SELECTED_IMAGE="$LOCAL_IMAGE_NAME"
    fi
fi

# Esegue con docker run per evitare pull non necessari
docker run --rm -it \
    --platform linux/amd64 \
    -v "$(pwd)/src:/workspace" \
    "$SELECTED_IMAGE" "$@"
