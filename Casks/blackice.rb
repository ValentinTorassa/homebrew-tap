cask "blackice" do
  # scripts/update-cask.sh sets both for each release.
  version "0.2.0"
  sha256 "29d14e99df445914fe092b9ef644b7de3e6eadc2819f6dbe085a699c1c8aba3b"

  url "https://github.com/ValentinTorassa/blackice/releases/download/v#{version}/Blackice-#{version}.zip"
  name "Blackice"
  desc "Headless application firewall operated through a CLI"
  homepage "https://blackice-macos.vercel.app/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Blackice.app"
  # blackice checks that it runs as the signed app and refuses to run through a symbolic link,
  # so the command Homebrew links is a script that runs the app's executable by its full path.
  # The path is fixed because macOS activates system extensions only from /Applications.
  binary "blackice.wrapper.sh", target: "blackice"

  preflight_steps do
    write_file "blackice.wrapper.sh", <<~EOS
      #!/bin/sh
      exec /Applications/Blackice.app/Contents/MacOS/blackice "$@"
    EOS
  end

  # Boots out the daemon's LaunchAgent, if `blackice agent install` loaded it, and deletes
  # ~/Library/LaunchAgents/com.valentorassa.blackice.daemon.plist. The network extension and the
  # content filter stay: only `blackice stop` removes them (see the caveats).
  uninstall launchctl: "com.valentorassa.blackice.daemon"

  # The daemon's logs and event log. ~/.config/blackice holds the user's configuration and stays.
  zap trash: "~/Library/Logs/blackice"

  caveats <<~EOS
    Run `blackice start`. The first time, it asks a few questions to write
    ~/.config/blackice/blackice.toml, then opens System Settings: under General >
    Login Items & Extensions > Network Extensions, turn Blackice on.

    To run the hooks in ask mode, load the daemon (a LaunchAgent for your user):
      blackice agent install

    Before uninstalling, remove the daemon and the extension, which Homebrew cannot do:
      blackice agent uninstall
      blackice stop

    After upgrading, run `blackice start`, then restart the Mac: on macOS 27.0.1 an
    extension upgraded in place could not be reached until a restart. Then run
    `blackice agent uninstall` and `blackice agent install`, so that the daemon runs the
    new binary.

    Install guide: https://blackice-macos.vercel.app/docs/install
  EOS
end
