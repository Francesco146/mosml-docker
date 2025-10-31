#!/bin/bash

IMAGE_NAME="ghcr.io/francesco146/mosml:latest"
LOCAL_IMAGE_NAME="mosml:latest"

mkdir -p src

# Preferisce l'immagine locale se presente
# altrimenti prova a pullare dal registry
# altrimenti builda localmente usando il Dockerfile
SELECTED_IMAGE=""
if [ -n "$(docker images -q "$LOCAL_IMAGE_NAME" 2>/dev/null)" ]; then
    echo "Found local image: $LOCAL_IMAGE_NAME"
    SELECTED_IMAGE="$LOCAL_IMAGE_NAME"
elif [ -n "$(docker images -q "$IMAGE_NAME" 2>/dev/null)" ]; then
    echo "Found local image: $IMAGE_NAME"
    SELECTED_IMAGE="$IMAGE_NAME"
else
    if docker pull "$IMAGE_NAME" >/dev/null 2>&1; then
        echo "Pulled $IMAGE_NAME"
        SELECTED_IMAGE="$IMAGE_NAME"
    else
        echo "Failed to pull image from registry. Building locally..."
        docker build --platform linux/amd64 -t "$IMAGE_NAME" -t "$LOCAL_IMAGE_NAME" .
        SELECTED_IMAGE="$IMAGE_NAME"
    fi
fi

if [ -z "$SELECTED_IMAGE" ]; then
    echo "No image selected, aborting."
    exit 1
fi


docker run --rm -it \
    --platform linux/amd64 \
    -v "$(pwd)/src:/workspace" \
    "$SELECTED_IMAGE" "$@"