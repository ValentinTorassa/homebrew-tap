cask "blackice" do
  # scripts/update-cask.sh sets both for each release.
  version "1.0.4"
  sha256 "7e8678f2d79322bb27361e6f290dc0c62efd1f651c40f3c39587c99d76b95a23"

  url "https://github.com/ValentinTorassa/blackice/releases/download/v#{version}/Blackice-#{version}.zip"
  name "Blackice"
  desc "Headless application firewall operated through a CLI"
  homepage "https://blackice-macos.vercel.app/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  # 14.4 or later (LSMinimumSystemVersion); Homebrew can name only the major version.
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
    blackice needs macOS 14.4 or later; Homebrew checks only for macOS 14.

    Run `blackice start`. The first time, you pick from lists: the mode, who
    answers in ask mode (fx, Claude Code or you; start sets up the agent you
    pick), and the apps to trust. It writes ~/.config/blackice/blackice.toml,
    then opens System Settings and prints where to allow the network extension.

    To have an agent answer later: blackice agent connect fx
    (or claude-code, codex, opencode).
    For hooks written by hand, load the daemon (a LaunchAgent for your user):
      blackice agent install

    After upgrading, run `blackice start` (Touch ID). If it exits with status 75,
    restart the Mac and run it again.

    Before uninstalling, remove the daemon and the extension, which Homebrew cannot do:
      blackice menu --login off
      blackice agent uninstall
      blackice stop

    Install guide: https://blackice-macos.vercel.app/docs/install
  EOS
end
