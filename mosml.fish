#!/usr/bin/env fish

# Moscow ML Docker Wrapper Script
# Automatically pulls from GitHub Container Registry or builds locally if needed

set IMAGE_NAME "ghcr.io/francesco146/mosml:latest"
set LOCAL_IMAGE_NAME "mosml:latest"

# Crea la directory src se non esiste
mkdir -p src

# Funzione per buildare l'immagine localmente
function build_image
    echo "Building image locally..."
    docker build --platform linux/amd64 -t $IMAGE_NAME -t $LOCAL_IMAGE_NAME .
end

# Controlla se l'immagine esiste localmente (preferisce il tag locale se presente)
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
        echo "Attempting to pull image from registry: $IMAGE_NAME"
        if docker pull $IMAGE_NAME >/dev/null 2>&1
            echo "Pulled $IMAGE_NAME"
            set SELECTED_IMAGE $IMAGE_NAME
        else
            echo "Failed to pull image from registry. Building locally..."
            build_image
            set SELECTED_IMAGE $IMAGE_NAME
        end
    end
end

# Esegui il container con l'immagine selezionata
if test -z "$SELECTED_IMAGE"
    echo "No image selected, aborting."
    exit 1
end

if test (count $argv) -eq 0
    # Modalità interattiva
    docker run --rm -it \
        --platform linux/amd64 \
        -v (pwd)/src:/workspace \
        $SELECTED_IMAGE
else
    # Esegui file specifico
    docker run --rm -it \
        --platform linux/amd64 \
        -v (pwd)/src:/workspace \
        $SELECTED_IMAGE $argv
end