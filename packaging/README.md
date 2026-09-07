# Publishing

This directory builds **unmodified** [RiDDiX/adguard-tray](https://github.com/RiDDiX/adguard-tray)
releases into a signed APT repository on GitHub Pages
(`https://jochemkuipers.github.io/adguard-tray`).

## One-time setup

1. Create a dedicated signing key (not a personal mail key):

   ```bash
   gpg --quick-generate-key "adguard-tray APT <jochem@kuipers.cc>" ed25519 sign 0
   gpg --list-secret-keys --keyid-format LONG
   gpg --export-secret-keys --armor KEYID
   ```

2. Add GitHub Actions secrets on `JochemKuipers/adguard-tray`:
   - `APT_GPG_PRIVATE_KEY` — the armored secret key
   - `APT_GPG_PASSPHRASE` — only if the key has a passphrase

3. After the first successful tag workflow, set the repository Pages source
   to the `gh-pages` branch.

## New upstream version

```bash
./packaging/sync-upstream.sh --update
# commit debian/changelog, tag vX.Y.Z, push
```

`uscan` also works (`debian/watch` points at RiDDiX GitHub tags).
