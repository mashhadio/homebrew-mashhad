cask "mashhad" do
  # Apple Silicon and Intel get separate builds — `arch` picks the right one and
  # substitutes into the url below as #{arch}.
  arch arm: "arm64", intel: "x64"

  version "1.0.11"

  # Refresh both on every release, from the published assets:
  #   shasum -a 256 Mashhad-arm64.dmg Mashhad-x64.dmg
  sha256 arm:   "8b45597c399dd07926e950aef5aa35895484c6c6ecfc8fa74c9bfdf85e948fa2",
         intel: "4d06f94950ff1d9c3c18baf1f28247c3d93b17ae188e223a9cf40daa642dde2d"

  # Attached to the tagged release in the public mashhad-releases repo, so Homebrew can
  # verify the sha256 against a URL that never changes under it. The filename carries no
  # version — the tag in the path already pins it — but it must keep #{arch}: both macOS
  # builds land in the same release and a bare Mashhad.dmg would collide. Renamed as of
  # 1.0.5; do not point this at 1.0.2 or earlier, whose assets are Mashhad-<version>-<arch>.dmg.
  url "https://github.com/mashhadio/mashhad-releases/releases/download/v#{version}/Mashhad-#{arch}.dmg"
  name "مشهد"
  name "Mashhad"
  desc "Screen recorder with cursor-tracking smooth zoom and mic noise cleanup"
  homepage "https://mashhad.io"

  # No `depends_on macos:`. Homebrew disabled `:catalina` (it fails to load the cask
  # outright, "There is no replacement") because Homebrew itself no longer runs on
  # anything that old, so the floor it expressed was already guaranteed.

  # The bundle inside the .dmg is "Mashhad.app" (electron-builder falls back to
  # `executableName` for the bundle filename because productName is non-ASCII).
  # Its CFBundleName is still "مشهد", which is what Finder and the menu bar show.
  # This must be the on-disk filename or Homebrew fails with "App source ... is not there".
  app "Mashhad.app"

  # The build is ad-hoc signed under its own identifier (com.abdul.mashhad) but NOT
  # notarized — notarization needs a paid Developer ID. macOS therefore still
  # quarantines a downloaded .dmg, so strip the attribute on install to launch cleanly.
  #
  # As of 1.0.8 the identifier is ours. Before that the bundle carried stock Electron's
  # ad-hoc signature (Identifier=Electron), sharing one CDHash with every unsigned
  # Electron build; Apple revoked that hash and Gatekeeper blocked Mashhad outright with
  # "contains malware" — which this block could not help with, because revocation is
  # enforced separately from quarantine. Keep the identifier unique.
  #
  # Remove this block only once the app is properly signed + notarized.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Mashhad.app"],
                   sudo: false
  end

  zap trash: [
    "~/Library/Application Support/مشهد",
    "~/Library/Preferences/com.abdul.mashhad.plist",
    "~/Library/Saved Application State/com.abdul.mashhad.savedState",
    "~/Library/Logs/مشهد",
  ]
end
