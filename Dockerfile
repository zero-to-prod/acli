FROM alpine/curl

WORKDIR /app

RUN curl -LO "https://acli.atlassian.com/linux/latest/acli_linux_amd64/acli"

RUN chmod +x ./acli

RUN install -o root -g root -m 0755 acli /usr/local/bin/acli

ENTRYPOINT ["acli"]