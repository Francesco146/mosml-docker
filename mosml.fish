#!/usr/bin/env fish

# Moscow ML Docker Wrapper Script
# Automatically pulls from GitHub Container Registry or builds locally if needed

set IMAGE_NAME "ghcr.io/YOUR_GITHUB_USERNAME/mosml-docker:latest"
set LOCAL_IMAGE_NAME "mosml-docker:latest"

# Crea la directory src se non esiste
mkdir -p src

# Funzione per buildare l'immagine localmente
function build_image
    echo "Building image locally..."
    docker build --platform linux/amd64 -t $IMAGE_NAME -t $LOCAL_IMAGE_NAME .
end

# Prova a pullare l'immagine dal registry
echo "Attempting to pull image from registry..."
if not docker pull $IMAGE_NAME 2>/dev/null
    echo "Failed to pull image from registry. Building locally..."
    build_image
end

# Esegui il container
if test (count $argv) -eq 0
    # Modalità interattiva
    docker run --rm -it \
        --platform linux/amd64 \
        -v (pwd)/src:/workspace \
        $IMAGE_NAME
else
    # Esegui file specifico
    docker run --rm -it \
        --platform linux/amd64 \
        -v (pwd)/src:/workspace \
        $IMAGE_NAME $argv
end