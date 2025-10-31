# Moscow ML Docker

Containerized version of Moscow ML (version 2.10.2) for easy cross-platform usage.

## Quick Start

### Prerequisites

- Docker and Docker Compose installed and running

### Download and Use

1. Clone the repository:

    ```bash
    git clone https://github.com/Francesco146/mosml-docker.git
    cd mosml-docker
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

The wrapper scripts will automatically:

- Try to pull the pre-built image from GitHub Container Registry
- Fall back to building locally with Docker Compose if the pull fails
- Create a `src/` directory for your SML files
- Mount it to the container automatically

### Example Usage

Run the hello world program from `src/hello.sml`:

```bash
./mosml.sh hello.sml
```

Any SML files you place in the `src/` directory will be accessible inside the container at `/workspace`. You can edit them on your host machine and run them inside the container:

```bash
./mosml.sh myprogram.sml
```

Or using the REPL interactively:

```sml
- use "myprogram.sml";
```

## Building Locally

If you prefer to use Docker Compose directly without the wrapper scripts:

```bash
# Build the image
docker compose build

# Run interactively
docker compose run --rm mosml

# Run a specific file
docker compose run --rm mosml hello.sml

# Pass Moscow ML options
docker compose run --rm mosml -P full myprogram.sml
```

## Platform Notes

This image is built for `linux/amd64` architecture. On Apple Silicon (M1/M2/M3) Macs, Docker will automatically use Rosetta emulation.
