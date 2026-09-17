#!/bin/bash
set -euo pipefail

INSTALL_DIR="/home/dragonwilds/rs_server"
STEAMCMD="/opt/steamcmd/steamcmd.sh"

install_or_update() {
    echo "[dragonwilds] Running SteamCMD install/update..."
    # +app_info_update / +app_info_print before +app_update works around a
    # SteamCMD appinfo-cache race condition seen on freshly-published app
    # IDs (same class of issue documented in mbround18/valheim-docker #1508).
    # Without this, app_update can fail with "Missing configuration" even
    # though the app ID is valid.
    "$STEAMCMD" +force_install_dir "$INSTALL_DIR" \
        +login anonymous \
        +app_info_update 1 \
        +app_info_print 4019830 \
        +app_update 4019830 validate \
        +quit
    chmod +x "$INSTALL_DIR/RSDragonwildsServer.sh"
    echo "[dragonwilds] Done."
}

case "${1:-run}" in
  install|update)
    install_or_update
    ;;
  run)
    if [ ! -f "$INSTALL_DIR/RSDragonwildsServer.sh" ]; then
        echo "[dragonwilds] No server files found - installing first..."
        install_or_update
    else
        echo "[dragonwilds] manual-update image: skipping update check on startup."
        echo "[dragonwilds] To update: stop the container, then run:"
        echo "[dragonwilds]   docker compose run --rm dragonwilds update"
        echo "[dragonwilds] and start it again. See README: 'Why manual-update'"
        echo "[dragonwilds] for why this matters if you're joining from Switch/console."
    fi
    exec "$INSTALL_DIR/RSDragonwildsServer.sh" -log -NewConsole -Port="${DEFAULT_PORT:-7777}"
    ;;
  *)
    echo "Unknown command: $1" >&2
    exit 1
    ;;
esac
