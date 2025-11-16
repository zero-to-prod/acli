FROM alpine/curl

WORKDIR /app

RUN curl -LO "https://acli.atlassian.com/linux/latest/acli_linux_amd64/acli"

RUN chmod +x ./acli

RUN install -o root -g root -m 0755 acli /usr/local/bin/acli

# OCI Image Labels for documentation
LABEL org.opencontainers.image.title="ACLI - Atlassian CLI"
LABEL org.opencontainers.image.description="Containerized wrapper for Atlassian CLI (ACLI)"
LABEL org.opencontainers.image.url="https://github.com/zero-to-prod/acli"
LABEL org.opencontainers.image.documentation="https://developer.atlassian.com/cloud/acli/"
LABEL org.opencontainers.image.source="https://github.com/zero-to-prod/acli"
LABEL org.opencontainers.image.vendor="ZeroToProd"
LABEL org.opencontainers.image.licenses="MIT"
LABEL usage="docker run -it --rm -v ~/.config/acli:/root/.config/acli davidsmith3/acli [COMMAND] [OPTIONS]"

ENTRYPOINT ["acli"]
CMD ["--help"]