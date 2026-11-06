# Stremio TV Themes Mod & Remote Function (shell-ng).

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/1ade250c-d640-4317-9a7a-2f3aae6f85a9" />

---

A theme pack for **Stremio 5 on Windows** (stremio-shell-ng). It restyles the whole app as **Apple TV Windows**, Netflix, YouTube, Vision Glass and more, and adds remote-control navigation, an on-screen keyboard, trailers, an Apple-style player and lots of small fixes.

`themes.js` is built into `stremio-shell-ng.exe` (through `webview.rs`), so the mod is installed by replacing that one file.

---

## Install

### Method 1: App copy (easiest, no tools needed)

You only need the ready-made `stremio-shell-ng.exe` from this repo's **Releases**.

1. Install Stremio once (PowerShell):
   ```powershell
   winget install -e --id Stremio.Stremio
   ```
2. Download `stremio-shell-ng.exe` from **Releases** into your **Downloads** folder.
3. close Stremio
   - copy `stremio-shell-ng.exe` into `%LOCALAPPDATA%\Programs\Stremio\` and replace the old file
   - open Stremio

### Method 2: Build from source

Use this method if you want to change `themes.js` yourself.

**Apps needed**

| App | winget id | Why |
|---|---|---|
| Git | `Git.Git` | to download the source |
| Rust (rustup) | `Rustlang.Rustup` | to build the app |
| VS 2022 Build Tools (C++) | `Microsoft.VisualStudio.2022.BuildTools` | the C++ linker Rust needs |
| Inno Setup | `JRSoftware.InnoSetup` | to create the app installer |

**First time**
1. Save `themes.js` in your **Downloads** folder.
2. From the repository folder, run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\setup-build-pc.ps1
   ```

The script installs the build tools, downloads the official Stremio shell source, adds your theme, builds the app, and installs it.

**After changing `themes.js`**
1. Save the updated file in **Downloads**.
2. From the repository folder, run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\update-stremio.ps1
   ```
```

---

## Keys

| Key | What it does |
|---|---|
| `T`, `F8` or `Ctrl+Alt+T` | switch to the next theme |
| `R` | Remote mode on / off |
| `K` | Screen Keyboard on / off |
| `D` (in the theme list) | open with this theme every time (★) |
| `Esc` | exit full screen (in the player it never leaves the episode) |
| Back / Backspace | close the open popup, then hide the controls, then go to the show page |

---

## Themes

| Theme | State |
|---|---|
| **Apple TV Windows** | main theme, most features |
| Apple TV 4K | Apple TV with full-width rows |
| Vision Glass | visionOS glass look |
| YouTube Style | YouTube look |
| Netflix Style | Netflix look |
| Disney / Shahid / OSN+ Style | unfinished |
| Apple TV Light Mode, Liquid Glass, Amazon Prime Style | beta: listed but not selectable, skipped by the theme switch |

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/cf38be9b-6bf0-4d4b-8f6a-ce2379c67b56" />

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/0cb8bd0c-16fa-4dab-bed9-7afd3667c31d" />

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/8e00dfd6-5816-4c2e-ae40-01053c0f9f7d" />

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/f2d9224f-281e-4384-a860-9f338af3bb7d" />

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/463c965d-0681-4f86-958e-35869883a72c" />

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/7cfa80ce-4870-4880-bca3-d3a1989ecc23" />

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/a1247983-dd6e-48a0-b9f7-c691b3ca90d7" />

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/281d7465-a29c-4f30-bf69-3ad65e5b4278" />

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/f0590feb-65e6-4eab-915f-ea862ba4e038" />

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/d8c1c61c-8f42-4c28-a367-60a5e36214b2" />

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/990d0fcf-6953-47e9-aa94-e33e36b68ab6" />

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/50457485-74d4-414b-ae73-0806694d2549" />

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/cda23b51-b34d-4264-9c54-771932339a58" />

---

## Features

### All themes
- Settings panel with themes, a ★ default theme, and switches for Remote mode, Hover Sound, Screen Keyboard, Auto-play trailers and Hide titles without links
- Startup splash screen
- Top 10 TV Shows / Top 10 Movies rows (Cinemeta)
- Subtitle **Upload** button in the subtitles menu
- Saved volume level across all themes (starts at your last level, not 100%)
- A click outside the player menus closes them
- Late video starts outside the player are blocked, and the video engine is stopped when you leave the player

### Apple TV Windows App
**Look and animation**
- Apple sidebar: Home, Movies, TV Shows, Library (Last Watched, Watched, Loved & Liked), Full Screen, Add-ons and your account name, with search and suggestions
- Hero slideshow with trailers that fill the hero, prev / next arrows, dots and a mute button (muted each session)
- **Thumbnail view:** wide Apple cards that run edge to edge, zoom on hover / select, and inset rims on Related posters
- Row arrows that show only when the mouse is near (left arrow only after scrolling)
- Continue Watching row with a ••• menu (Go to Episode, Go to Show, Watchlist, Mark as Watched, Remove) and time left
- Recently Watched row under Featured
- Trailers row: two per page, one plays at a time for 20 s, highest quality, follows the Auto-play setting
- Apple Search page: Top Results, Movies, TV Shows, Browse genres
- Title page: Episodes, Related, Trailers and About stacked, a season dropdown with soft animation, and OK on an episode plays it at once
- Links list as Apple-style cards
- Library: wide cards, a blue Liked & Loved chip, flat menus
- Smooth open and close animations on panels, menus and rows

---
<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/b2e0c461-654b-4732-a24d-b1c459c140b2" />
---

**Player**
- Apple overlay: title, round −10 / play-pause / +10 buttons (the mouse seeks straight on the video engine, so it's instant), and Info and Continue Watching pills with sliding panels
- Volume slider and speaker at the top left under the title. With the remote: OK starts changing it, ← / → change it, OK ends it
- Episodes stack (iPhone-style cards). ↑ / ↓ / Back or a click outside closes it
- Up Next row in the last seconds, with a countdown and auto play. Stremio's "Watch now" popup shows first and hides 3 s before Up Next
- Back never goes to a previous episode. It always ends on the show page
- Auto-hide after 3.5 s with no input
- Stats, speed and cast icons moved to the end; the fullscreen icon is hidden in remote mode
- Stremio's own ±10 bubble is replaced by the count on the round buttons

---
<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/56095831-8c56-4dd6-afa4-47eac6c0395a" />

---
<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/135e0565-f804-4276-aaa3-bfd3d36482e1" />

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/36d8df36-7da9-48af-a544-9222a74db5fd" />

---
### Remote mode
- Full arrow / OK / Back navigation on every page: sidebar, hero, rows, search, title page, seasons, episodes, related, trailers, links, library and settings
- It remembers your position in each row and returns to it
- Player: ↑ from nothing shows the icons, ↑ again goes to the volume, ↓ goes to the seek bar and then the Info / CW pills
- Subtitles opens on **OFF**. Delay / Size / Position: OK, then ← / →, then OK
- Volume keys on the remote always reach Windows
- Screen Keyboard for search; Back closes it

You can use any of these kind of USB remote, the App recognize the keyboard input from the keyboard, You can remap them in the setting.



<img width="260" height="359" alt="image" src="https://github.com/user-attachments/assets/a3afb372-fe58-4de6-a6d1-a19c5bf036c2" /> <img width="407" height="375" alt="image" src="https://github.com/user-attachments/assets/d02c5c8e-39c1-4973-8804-5520bd0d5015" />

---

<img width="503" height="158" alt="image" src="https://github.com/user-attachments/assets/e502464a-c191-406c-9347-12b26b01c1d5" />

---

<img width="311" height="41" alt="image" src="https://github.com/user-attachments/assets/e6674509-0c96-48af-b028-a8562454b619" />

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/a9cc7e3c-84bb-4d26-9ea9-7693f9f1db0a" />

---


### Vision Glass
- Glass sidebar with Continue Watching / Trending and a Latest list (the header stays fixed while the list scrolls)
- Glass player menus and tabs without underlines
---
<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/39c00ce9-e1cf-498b-aaec-a3afaf8945a4" />

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/e8f45cb9-b3df-47f0-b30e-311738a20cbb" />

---

### YouTube Style
- YouTube layout and player
- Hover glow that takes its colour from each thumbnail, like real YouTube
<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/04b282ae-f031-4290-8b67-927b968800d8" />

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/80ce2f19-110e-4cfc-97bd-61621fd71c2a" />

---
### Netflix Style
- Netflix colours, fonts and red accents
- Big hero with trailer, Top 10 rows with big numbers
- Netflix-style player with the episodes card stack
- Remote mode support

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/6a541ead-1b9d-49a5-9129-a88eb6950685" />

---

### Disney Style (unfinished)
- Disney+ dark blue look and tabs on the title page
- Still being worked on

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/ff0c8e37-0c31-4f89-a904-cbe1294b7933" />

---

### Shahid Style (unfinished)
- Shahid look with green accents
- Still being worked on

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/65f4379b-5427-4df5-9d7c-4f5e3709f57c" />

---

### OSN+ Style (unfinished)
- OSN+ look
- Still being worked on

---

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/9513aa97-0b41-4ff5-bc66-13f15ee120ed" />

---

### Beta (coming soon, not selectable yet)
- **Apple TV Light Mode**: Apple TV in light colours
- **Liquid Glass**: Apple TV with liquid glass effects
- **Amazon Prime Style**: Prime Video look
## Files

| File | What it is |
|---|---|
| `themes.js` | the whole mod; goes to `src/stremio_app/themes.js` in stremio-shell-ng |
| `scripts/install-exe.ps1` | Method 1: puts the ready exe into Stremio |
| `scripts/setup-build-pc.ps1` | Method 2: first-time tool install, clone and build |
| `scripts/update-stremio.ps1` | Method 2: rebuild and restart after each edit |

## Notes
- Windows only (Stremio 5 / shell-ng).
- Video and audio are played by Stremio's own engine (mpv), so installing Stremio first is required for both methods.
- A theme can be fully undone by putting the original `stremio-shell-ng.exe` back.
- Send me your bug report IG: Its.Rebel95 
