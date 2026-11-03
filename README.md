# valentintorassa/tap

Homebrew casks for [blackice](https://github.com/ValentinTorassa/blackice).

```console
$ brew tap valentintorassa/tap
$ brew install --cask blackice
```

or, in one step, `brew install --cask valentintorassa/tap/blackice`.

| Cask | What it installs |
|---|---|
| `blackice` | Blackice.app, from the zip on blackice's GitHub release, and a `blackice` command. Apple silicon, macOS 14 or later. |

After installing, read the caveats Homebrew prints, or [blackice's install guide](https://github.com/ValentinTorassa/blackice/blob/main/docs/install.md):
the first `blackice start` waits until you allow the network extension in System Settings, `blackice agent install`
loads the daemon, `blackice stop` has to run before `brew uninstall`, and an upgrade needs a restart.

## A new release

```console
$ scripts/update-cask.sh 0.1.1            # reads the SHA-256 from the release's .sha256 file
$ scripts/update-cask.sh 0.1.1 <sha256>   # or takes it from the command line
$ brew style --cask Casks/blackice.rb     # where Homebrew is installed
```
