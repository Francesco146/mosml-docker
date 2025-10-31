# Moscow ML Docker

Containerized version of Moscow ML (version 2.10.2) for easy cross-platform usage.

## Quick Start (Using Pre-built Image)

### Prerequisites

- Docker installed and running

### Download and Use

1. Clone the repository or download the wrapper scripts:

    ```bash
    git clone https://github.com/Francesco146/mosml.git
    cd mosml
    ```

2. Run Moscow ML using the provided script (bash, PowerShell, or Fish):

    ```bash
    # Interactive mode
    ./mosml.sh

    # Run a specific file
    ./mosml.sh myprogram.sml

    # Pass Moscow ML options
    ./mosml.sh -P full myprogram.sml
    ```

The script will automatically:

- Pull the pre-built image from GitHub Container Registry
- Fall back to building locally if the pull fails
- Create a `src/` directory for your SML files
- Mount it to the container automatically

### Example Usage

Run the hello world program from `src/hello.sml`:

```bash
./mosml.sh hello.sml
```

## Building Locally

If you prefer to build the image yourself:

```bash
# Build the image
docker build --platform linux/amd64 -t mosml .

# Run it
docker run --rm -it -v $(pwd)/src:/workspace mosml
```

## Using Docker Compose

```bash
# Build
docker-compose build

# Run interactively
docker-compose run --rm mosml

# Run a file
docker-compose run --rm mosml hello.sml
```

## Manual Docker Usage

Without the wrapper scripts:

```bash
# Pull the image and give it a name
docker pull ghcr.io/francesco146/mosml:latest && \
    docker tag ghcr.io/francesco146/mosml:latest mosml

# Run interactively
docker run --rm -it \
    --platform linux/amd64 \
    -v $(pwd)/src:/workspace \
    mosml

# Run a specific file
docker run --rm -it \
    --platform linux/amd64 \
    -v $(pwd)/src:/workspace \
    mosml myprogram.sml
```

## How It Works

1. The wrapper scripts (`mosml.sh`, `mosml.ps1`, `mosml.fish`) first attempt to pull the pre-built image from GitHub Container Registry
2. If the pull fails (network issues, image not yet published, etc.), they automatically build the image locally
3. Your SML files in the `src/` directory are mounted into the container at `/workspace`
4. Moscow ML runs inside the container with access to your local files

## Platform Notes

This image is built for `linux/amd64` architecture. On Apple Silicon (M1/M2/M3) Macs, Docker will automatically use Rosetta emulation.
