#!/usr/bin/env bash
# Add this machine's adguard-tray APT repository and install the package.
# The application itself comes from https://github.com/RiDDiX/adguard-tray
set -euo pipefail

REPO_URL="https://jochemkuipers.github.io/adguard-tray"
KEYRING="/etc/apt/keyrings/adguard-tray.asc"
LIST="/etc/apt/sources.list.d/adguard-tray.list"

if [[ "$(id -u)" -ne 0 ]]; then
  if [[ ! -f "${BASH_SOURCE[0]}" || "${BASH_SOURCE[0]}" == "bash" || "${BASH_SOURCE[0]}" == "-bash" ]]; then
    echo "Run this script as root, e.g.:" >&2
    echo "  curl -fsSL ${REPO_URL}/install.sh | sudo bash" >&2
    exit 1
  fi
  exec sudo -- "$0" "$@"
fi

if [[ "${1:-}" == "--uninstall" ]]; then
  apt-get remove -y adguard-tray || true
  rm -f "${KEYRING}" "${LIST}"
  apt-get update
  echo "Removed adguard-tray and its APT source."
  echo "Kept: ~/.config/adguard-tray (settings), ~/.local/share/adguard-tray (logs)"
  exit 0
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends ca-certificates curl

install -d -m 0755 /etc/apt/keyrings
curl -fsSL "${REPO_URL}/adguard-tray.asc" -o "${KEYRING}"
chmod 0644 "${KEYRING}"

printf 'deb [signed-by=%s] %s stable main\n' "${KEYRING}" "${REPO_URL}" > "${LIST}"

apt-get update
apt-get install -y adguard-tray

echo ""
echo "Installation complete. Run: adguard-tray"
echo "Uninstall:  bash install.sh --uninstall"
echo "Update:     sudo apt update && sudo apt install --only-upgrade adguard-tray"
