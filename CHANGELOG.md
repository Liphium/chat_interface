## Reminders for contributors

- On every release, update `sqlite3.wasm` in the web folder to the latest version.

## 0.6.0

### Major changes

- Compatability with protocol v8
- Added voice calling in Spaces using Lightwire, our own audio engine
- Added connecting to Studio, our WebRTC implementation, in Spaces
- Added a new conversation type called Square
  - Multiple conversations (called Topics) can be created inside of them
  - Spaces created inside of it will be displayed in the sidebar

### Minor changes and fixes

- Fixed that you couldn't invite people to a Space
- Fixed same addresses sometimes not being recognized
- Rewrote the entire code using new state management for a better structure
  - It now uses [signals](https://pub.dev/packages/signals) instead of GetX
  - It's now devided into services and controllers for a better overview
  - Tabletop's architecture still needs to be improved
- Fixed Warp crashing when sharing invalid ports
- Fixed Warp allowing to share already shared ports
- Fixed being able to add accounts that are already friends as a friend
- Rewrote the entire vault synchronization for better performance and maintainability
- Rewrote the text formatting detection to make it more extensible and also more stable (\*\*\*\* no longer breaks the app)
  - Regression: Links are no longer clickable (TODO: Fix before 1.0.0 Beta)
- Fixed cards in rotated inventories having an incorrect rotation
- Fixed not creating a new inventory when the old one has been deleted
- Fixed the "Edit title" button not actually doing anything
- Changed member and search sidebar to one consistent design
- Fixed member and search sidebar both being open when searching in group chats
- Fixed search not being scoped to individual conversations (and basically unusable)
- You can now choose how many dots appear
- All creation buttons are now in one menu in the sidebar
- Added a right click context menu in the sidebar
- More reliable notification handling
- The chat view now opens where the newest messages are

## 0.6.0

### Architecture changes and new features

- This release of Liphium is compatible with protocol v7
- Added Warp in Spaces: A way to share ports (and with that Minecraft servers) over Liphium
- Made the startup of the app significantly faster by reducing the amount of server interactions
- Messages are now stored in the local database to make loading them even faster
- Added automatic layering to Tabletop to make playing card games with card stacking easier
- Conversation search is now available directly inside every conversation
- Support for the new Spaces decentralization

### Minor fixes and updates

- Added a max length attribute to the SSR renderer for input fields (now being used by the server)
- Made the app startup seem faster by first loading local data
- Fixed a bug where the profile picture wouldn't load (because of the new attachment container schema)
- Made the profile picture selector more stable with smaller images
- Profile pictures that couldn't be found no longer show error popups
- The chat in Spaces is now open by default
- Made the protocol version error specify which version is out of date (client or server)
- The Zap requests and Spaces invites are now embedded into the message itself to make relation more clear
- Made the updater more reliable by having it always download and start the latest version
- Optimized Zap chunking size to perform better on faster internet connections
- Fixed a bug where Zap wouldn't show progress when receiving a file
- Fixed a bug where a file sent over Zap would not match the size of the original file due to an optimization error
- Updated the version of the package used to open files using native apps
- Decreased the amount of data needed for profile pictures (now only the container)
- Only media files will be copied over into the Liphium's file because others can stay on the server
- Added a hide animation for buttons that only work when you're online (they will hide when offline to make it clear they don't work)
- Non-media files are no longer cached when uploaded (because they aren't displayed)
- When downloading a non-media file (like a zip file) you will now be asked for a save location
- You are now asked if you want to also delete attachments when deleting a message
- Fixed Tabletop objects not being rotatable after first rotation
- Fixed slow load times when decentralized conversations are unreachable
- Fixed a setup bug that would break the local database

## 0.5.2

- Liphium is now one-instanced meaning you won't have to look for that pesky tray icon again :)

## 0.5.1

- Quick fix for client app developers, now opens 'default' in non-debug mode

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
