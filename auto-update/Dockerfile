FROM debian:bookworm-slim

# 32-bit compat libs are required by SteamCMD itself, even though the
# Dragonwilds server binary is 64-bit. libcurl4 fixes the bundled
# Sentry/crashpad crash-reporter failing to load on startup.
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates wget tar libcurl4 lib32gcc-s1 libc6:i386 libstdc++6:i386 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/steamcmd \
    && cd /opt/steamcmd \
    && wget -q https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    && tar -xzf steamcmd_linux.tar.gz \
    && rm steamcmd_linux.tar.gz

RUN useradd -m -u 1000 -s /bin/bash -U dragonwilds \
    && chown -R dragonwilds:dragonwilds /opt/steamcmd

USER dragonwilds
WORKDIR /home/dragonwilds

COPY --chown=dragonwilds:dragonwilds entrypoint.sh /home/dragonwilds/entrypoint.sh
RUN chmod +x /home/dragonwilds/entrypoint.sh

VOLUME ["/home/dragonwilds/rs_server"]
EXPOSE 7777/udp

ENTRYPOINT ["/home/dragonwilds/entrypoint.sh"]
CMD ["run"]
