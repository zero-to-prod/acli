# Stage 1: Download ACLI binary
FROM alpine/curl AS downloader

# Version pinning for reproducibility
ARG ACLI_VERSION=latest
ARG ACLI_ARCH=amd64

WORKDIR /download

# Download ACLI binary
RUN if [ "${ACLI_VERSION}" = "latest" ]; then \
        curl -LO "https://acli.atlassian.com/linux/latest/acli_linux_${ACLI_ARCH}/acli"; \
    else \
        curl -LO "https://acli.atlassian.com/linux/${ACLI_VERSION}/acli_linux_${ACLI_ARCH}/acli"; \
    fi && \
    chmod +x acli

# Stage 2: Runtime image
FROM alpine:3.19

# Create non-root user for security
RUN addgroup -g 1000 acli && \
    adduser -D -u 1000 -G acli acli

# Install minimal dependencies
RUN apk add --no-cache ca-certificates

# Copy ACLI binary from downloader stage
COPY --from=downloader --chown=acli:acli /download/acli /usr/local/bin/acli

# Create config directory with proper permissions
RUN mkdir -p /home/acli/.config/acli && \
    chown -R acli:acli /home/acli/.config

# Set working directory
WORKDIR /workspace

# Set environment variables
ENV ACLI_CONFIG_DIR=/home/acli/.config/acli

# Switch to non-root user
USER acli

# OCI Image Labels for documentation and metadata
LABEL org.opencontainers.image.title="ACLI - Atlassian CLI" \
      org.opencontainers.image.description="Containerized wrapper for Atlassian CLI (ACLI) with enhanced security" \
      org.opencontainers.image.url="https://github.com/zero-to-prod/acli" \
      org.opencontainers.image.documentation="https://developer.atlassian.com/cloud/acli/" \
      org.opencontainers.image.source="https://github.com/zero-to-prod/acli" \
      org.opencontainers.image.vendor="ZeroToProd" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.base.name="alpine:3.19" \
      org.opencontainers.image.version="1.0.0" \
      com.docker.security.user="acli:acli" \
      usage="docker run -it --rm -v ~/.config/acli:/home/acli/.config/acli davidsmith3/acli [COMMAND] [OPTIONS]"

# Healthcheck to verify ACLI is working
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["acli", "--version"]

ENTRYPOINT ["acli"]
CMD ["--help"]
