#!/usr/bin/env fish

set IMAGE_NAME "ghcr.io/francesco146/mosml:latest"
set LOCAL_IMAGE_NAME "mosml:latest"

mkdir -p src

set found_local (docker images -q $LOCAL_IMAGE_NAME 2>/dev/null)
set found_remote (docker images -q $IMAGE_NAME 2>/dev/null)
set SELECTED_IMAGE ""

if test -n "$found_local"
    echo "Using local image: $LOCAL_IMAGE_NAME"
    set SELECTED_IMAGE $LOCAL_IMAGE_NAME
else if test -n "$found_remote"
    echo "Using local image: $IMAGE_NAME"
    set SELECTED_IMAGE $IMAGE_NAME
else
    if docker pull $IMAGE_NAME >/dev/null 2>&1
        echo "Pulled $IMAGE_NAME"
        set SELECTED_IMAGE $IMAGE_NAME
    else
        echo "Failed to pull image from registry. Building locally..."
        docker compose build --quiet
        set SELECTED_IMAGE $LOCAL_IMAGE_NAME
    end
end

# Esegue con docker run per evitare pull non necessari
docker run --rm -it \
    --platform linux/amd64 \
    -v (pwd)/src:/workspace \
    $SELECTED_IMAGE $argv
