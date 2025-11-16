FROM alpine/curl:8.11.1 AS builder

WORKDIR /builder

RUN curl -LO "https://acli.atlassian.com/linux/latest/acli_linux_amd64/acli" && \
    chmod +x ./acli

FROM alpine:3.21

WORKDIR /app

LABEL org.opencontainers.image.title="ACLI - Atlassian CLI"
LABEL org.opencontainers.image.description="Containerized wrapper for Atlassian CLI (ACLI)"
LABEL org.opencontainers.image.url="https://github.com/zero-to-prod/acli"
LABEL org.opencontainers.image.documentation="https://developer.atlassian.com/cloud/acli/"
LABEL org.opencontainers.image.source="https://github.com/zero-to-prod/acli"
LABEL org.opencontainers.image.vendor="ZeroToProd"
LABEL org.opencontainers.image.licenses="MIT"
LABEL usage="docker run -it --rm -v ~/.config/acli:/root/.config/acli davidsmith3/acli [COMMAND] [OPTIONS]"

COPY --from=builder /builder/acli /usr/local/bin/acli

ENTRYPOINT ["acli"]
CMD ["--help"]