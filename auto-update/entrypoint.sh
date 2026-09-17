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
    echo "[dragonwilds] auto-update image: checking for updates before launch..."
    echo "[dragonwilds] NOTE: every restart of this image re-checks for an update,"
    echo "[dragonwilds] and every server restart regenerates the Switch/console"
    echo "[dragonwilds] join code. If you rely on the join-code workaround to"
    echo "[dragonwilds] connect (see README), use the manual-update image instead."
    install_or_update
    exec "$INSTALL_DIR/RSDragonwildsServer.sh" -log -NewConsole -Port="${DEFAULT_PORT:-7777}"
    ;;
  *)
    echo "Unknown command: $1" >&2
    exit 1
    ;;
esac
