cask "blackice" do
  # scripts/update-cask.sh sets both for each release.
  version "0.4.1"
  sha256 "864b66c18231a5cd9ae095e1864b7a7909f862b03108a0354dd3b583627e97ef"

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
    Run `blackice start`. The first time, you pick from lists: the mode, who
    answers in ask mode (fx, which start installs and sets up, or you), and the
    apps to trust. It writes ~/.config/blackice/blackice.toml, then opens System
    Settings and prints where to allow the network extension.

    To have fx answer later: blackice agent connect fx
    For hooks written by hand, load the daemon (a LaunchAgent for your user):
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
