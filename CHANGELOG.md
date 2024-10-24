## Reminders for contributors

- On every release, update `sqlite3.wasm` in the web folder to the latest version.

## Currently in dev

- This release of Liphium is compatible with protocol v7
- Liphium now closes to the tray on desktop
- The WebSocket connection now uses a new packet to authenticate the user instead of protocols
- Web support is now experimental
- Zap now runs at full speed
- Added a button in the message options menu for saving files (just images for now) to a directory
- Added a button in the message options menu for copying an attachment (just images for now) to clipboard

## 0.4.0

- Fixed the shortcut being deleted and re-created when installing a new version causing it to unpinned from the taskbar/start menu (Windows auto updater)
- Added an account management page that talks to the new endpoints for search, deleting and changing the ranks of accounts
- Changed the app icon to better work with white mode on Windows (color still isn't good, but it looks a little better)
- New settings for admins in the Town page in the settings (fully server-rendered, expect different settings to be added over time)
- Fixed a bug where files wouldn't be downloaded because they are below the auto-download size (when pressing the download button)
- Fixed a bug where an image wouldn't fill up the entire space it had in a conversation
- Zap now asks where to save a file instead of just randomly putting it into the downloads folder
- Remote group chats now also show the icon with the tooltip
- Fixed a bug where the remote tooltip would be a little annoying in the profile
- Links within messages are now clickable
