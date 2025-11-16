#!/usr/bin/env fish

set CONTAINER_ENGINE (command -v podman &> /dev/null && echo "podman" || echo "docker")

set IMAGE_NAME "ghcr.io/francesco146/mosml:latest"
set DOCKERHUB_IMAGE "docker.io/francescom0/mosml:latest"
set LOCAL_IMAGE_NAME "mosml:latest"

mkdir -p src

set found_local ("$CONTAINER_ENGINE" images -q $LOCAL_IMAGE_NAME 2>/dev/null)
set found_dockerhub ("$CONTAINER_ENGINE" images -q $DOCKERHUB_IMAGE 2>/dev/null)
set found_ghcr ("$CONTAINER_ENGINE" images -q $IMAGE_NAME 2>/dev/null)
set SELECTED_IMAGE ""

if test -n "$found_local"
    echo "Using local image: $LOCAL_IMAGE_NAME"
    set SELECTED_IMAGE $LOCAL_IMAGE_NAME
else if test -n "$found_dockerhub"
    echo "Using Docker Hub image: $DOCKERHUB_IMAGE"
    set SELECTED_IMAGE $DOCKERHUB_IMAGE
else if test -n "$found_ghcr"
    echo "Using GHCR image: $IMAGE_NAME"
    set SELECTED_IMAGE $IMAGE_NAME
else
    # Prova Docker Hub, poi GHCR, infine build locale
    if "$CONTAINER_ENGINE" pull $DOCKERHUB_IMAGE >/dev/null 2>&1
        echo "Pulled $DOCKERHUB_IMAGE"
        set SELECTED_IMAGE $DOCKERHUB_IMAGE
    else if "$CONTAINER_ENGINE" pull $IMAGE_NAME >/dev/null 2>&1
        echo "Pulled $IMAGE_NAME"
        set SELECTED_IMAGE $IMAGE_NAME
    else
        echo "Failed to pull image from registries. Building locally..."
        "$CONTAINER_ENGINE" compose build --quiet
        set SELECTED_IMAGE $LOCAL_IMAGE_NAME
    end
end

# Esegue con docker run per evitare pull non necessari
"$CONTAINER_ENGINE" run --rm -it \
    --platform linux/amd64 \
    --pull=never \
    -v (pwd)/src:/workspace:Z \
    $SELECTED_IMAGE $argv
