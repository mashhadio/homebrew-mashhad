cask "mashhad" do
  # Apple Silicon and Intel get separate builds — `arch` picks the right one and
  # substitutes into the url below as #{arch}.
  arch arm: "arm64", intel: "x64"

  version "1.0.8"

  # Refresh both on every release, from the published assets:
  #   shasum -a 256 Mashhad-arm64.dmg Mashhad-x64.dmg
  sha256 arm:   "7328a27f8ee46be095baf3be0b1126f139054fb417d6c14919c836ab943aafdf",
         intel: "d0262d5f1d7e694eab505e008e00e4cb2aa6dc7840efec24d5d7c4a66972a311"

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

  # Symbol form already means ">= catalina"; the string form is deprecated and
  # prints a warning on every `brew` invocation that touches the tap.
  depends_on macos: :catalina

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
