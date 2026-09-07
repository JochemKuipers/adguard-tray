# adguard-tray Debian package

Unofficial Debian packages of [RiDDiX/adguard-tray](https://github.com/RiDDiX/adguard-tray).
This repo does **not** carry a fork of the app — CI downloads the upstream
release tarball, wraps it in `debian/`, and uploads the `.deb` for the
combined APT repo at [jochemkuipers.github.io/apt-repo](https://jochemkuipers.github.io/apt-repo).

## Install

```bash
curl -fsSL https://jochemkuipers.github.io/apt-repo/jochem.sources \
  | sudo tee /etc/apt/sources.list.d/jochem.sources
sudo apt update
sudo apt install adguard-tray
```

Then `adguard-tray`. Updates come in with the rest of the system:

```bash
sudo apt update && sudo apt upgrade
```

Remove any old `adguard-tray.list` that pointed at `jochemkuipers.github.io/adguard-tray`.

`adguard-cli` is still installed with [AdGuard's official script](https://github.com/AdguardTeam/AdGuardCLI).

The app's own "Application update" button talks to GitHub; on an apt install
use `apt upgrade` instead.

CI checks [RiDDiX/adguard-tray](https://github.com/RiDDiX/adguard-tray) twice a day.
When there is a newer release it bumps `debian/changelog`, builds the `.deb`,
and uploads a GitHub Release. You can also run the **Release** workflow by hand.

To package a version yourself:

```bash
./packaging/sync-upstream.sh          # compare to the latest GitHub release
./packaging/sync-upstream.sh --update # bump debian/changelog
git add debian/changelog
git commit -m "chore: package upstream X.Y.Z"
git tag vX.Y.Z
git push origin HEAD vX.Y.Z
```

CI fetches `https://github.com/RiDDiX/adguard-tray/archive/refs/tags/vX.Y.Z.tar.gz`
and builds the `.deb`.

Local build (no publish):

```bash
sudo apt install build-essential debhelper dh-python dpkg-dev devscripts curl
./packaging/build-deb.sh          # version from debian/changelog
sudo apt install ./dist/adguard-tray_*_all.deb
```

## Layout

| Path | Role |
|---|---|
| `debian/` | Packaging only (not shipped by upstream) |
| `packaging/` | Fetch and build helpers |
