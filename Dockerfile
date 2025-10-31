FROM --platform=linux/amd64 ubuntu:22.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    ca-certificates && \
    wget -q https://launchpad.net/~kflarsen/+archive/ubuntu/mosml/+files/mosml_2.10.2-0ubuntu0_amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

FROM --platform=linux/amd64 ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libgmp10 \
    libc6 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /mosml_2.10.2-0ubuntu0_amd64.deb /tmp/

RUN dpkg -i /tmp/mosml_2.10.2-0ubuntu0_amd64.deb && \
    rm /tmp/mosml_2.10.2-0ubuntu0_amd64.deb

WORKDIR /workspace

VOLUME ["/workspace"]

ENTRYPOINT ["mosml"]
