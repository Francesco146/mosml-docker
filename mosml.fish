#!/usr/bin/env fish

set IMAGE_NAME "ghcr.io/francesco146/mosml:latest"
set LOCAL_IMAGE_NAME "mosml:latest"

mkdir -p src

# Preferisce l'immagine locale se presente
# altrimenti prova a pullare dal registry
# altrimenti builda localmente usando il Dockerfile
set SELECTED_IMAGE ""
set found_local (docker images -q $LOCAL_IMAGE_NAME 2>/dev/null)
if test -n "$found_local"
    echo "Found local image: $LOCAL_IMAGE_NAME"
    set SELECTED_IMAGE $LOCAL_IMAGE_NAME
else
    set found_remote (docker images -q $IMAGE_NAME 2>/dev/null)
    if test -n "$found_remote"
        echo "Found local image: $IMAGE_NAME"
        set SELECTED_IMAGE $IMAGE_NAME
    else
        if docker pull $IMAGE_NAME >/dev/null 2>&1
            echo "Pulled $IMAGE_NAME"
            set SELECTED_IMAGE $IMAGE_NAME
        else
            echo "Failed to pull image from registry. Building locally..."
            docker build --platform linux/amd64 -t $IMAGE_NAME -t $LOCAL_IMAGE_NAME .
            set SELECTED_IMAGE $IMAGE_NAME
        end
    end
end

if test -z "$SELECTED_IMAGE"
    echo "No image selected, aborting."
    exit 1
end

docker run --rm -it \
    --platform linux/amd64 \
    -v (pwd)/src:/workspace \
    $SELECTED_IMAGE $argv