Place local binary sources here when a package cannot be fetched reproducibly.

For `pkgs.macos-tahoe-cursor`:

1. Download `MacOS-Tahoe-Cursor.zip` from https://www.gnome-look.org/p/2300466
2. Save it as `pkgs/distfiles/MacOS-Tahoe-Cursor.zip`
3. Run `git add pkgs/distfiles/MacOS-Tahoe-Cursor.zip`

The file does not need to be committed, but it must be tracked locally so the
flake can see it.
