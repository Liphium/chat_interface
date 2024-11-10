## Reminders for contributors

- On every release, update `sqlite3.wasm` in the web folder to the latest version.

## 0.5.0

- This release of Liphium is compatible with protocol v6
- Liphium now closes to the tray on desktop
- The WebSocket connection now uses a new packet to authenticate the user instead of protocols
- Web support is now experimental
- Zap now runs at full speed
- Added a button in the message options menu for saving files to a directory
- Added a button in the message options menu for copying an attachment to clipboard
- Added a button in the message options menu to launch the file with the default app
- Added an audio player for attachments with an audio file type
- Added a notification sound when a new message arrives when closed to tray (configurable)
- Merged the language, Spaces and notification settings into one tab called "General"
- Removed audio and video chat from Spaces (read below)
- Removed all Rust code related to audio since it's not being used anymore
- Removed tab selector in Spaces (now connects to Tabletop by default)
- Fixed a bug where the Space attachment renderer would make requests even when the widget is disposed
- Added a chat tab to Spaces
- Made Zap ask where to put a file before accepting the request

### The removal of audio and video chat from Spaces

I get that this is a weird move to make especially cause Spaces was supposed to be one of the selling points of Liphium. But over the last few weeks I've just realized that it needs a complete rework and rethinking. LiveKit has constantly caused issues for me and never worked properly. Because I want to ship a good app and not a broken mess, I've decided to remove it for now. The code was all cluttered and completely unreadable and absolute not something that should've ever been shipped. I need to have a little bit of a higher standard for this stuff and I'm going to build my own media engine and server for this project in the future. That will of course take some time, so in the meantime I'll focus on features that actually matter to the current users of the app. I'd rather have a set of features that works well, rather than a set of features where half are broken.

This decision was made by me to make Liphium better and to make the progress of porting it to other platforms faster. When there is a stable release for all platforms that I currently want to target, I'll consider looking into adding voice and video chat again. Until then, expect an Android and iOS (at least alpha) version of Liphium to be released some time next month. That's what I'm going to work on for now.

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
