# Stremio TV Themes Mod & Remote Function (shell-ng) made by claude.

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
3. Run the installer script from the `scripts` folder:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\install-exe.ps1
   ```
   Or do it by hand:
   - close Stremio
   - copy `stremio-shell-ng.exe` into `%LOCALAPPDATA%\Programs\Stremio\` and replace the old file
   - open Stremio

The script keeps your original as `stremio-shell-ng.original.exe`. To undo the mod, rename it back.

### Method 2: Edit your own (build from source)

Use this if you want to change `themes.js` yourself.

**Apps needed**

| App | winget id | Why |
|---|---|---|
| Stremio | `Stremio.Stremio` | the app itself (video engine and files) |
| Git | `Git.Git` | to download the source |
| Rust (rustup) | `Rustlang.Rustup` | to build the exe |
| VS 2022 Build Tools (C++) | `Microsoft.VisualStudio.2022.BuildTools` | the C++ linker Rust needs on Windows |

**First time on a new PC (one command)**
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup-build-pc.ps1 -Repo https://github.com/YOUR-USER/stremio-shell-ng.git
```
This installs the four apps, clones the source to `%USERPROFILE%\stremio-shell-ng`, copies `update-stremio.ps1` to your home folder, and builds once.

If the build step fails right after installing the tools, close PowerShell, open it again and run the same command again.

**Every time you change themes.js**
1. Save your edited `themes.js` into **Downloads**.
2. Run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "$HOME\update-stremio.ps1"
   ```
   It copies the file into `src\stremio_app\themes.js`, runs `cargo build --release`, closes Stremio, puts the new exe in place, and starts it again.

**Manual commands (same thing)**
```powershell
Copy-Item "$HOME\Downloads\themes.js" "$HOME\stremio-shell-ng\src\stremio_app\themes.js" -Force
cd "$HOME\stremio-shell-ng"
cargo build --release
Get-Process stremio* | Stop-Process -Force
Copy-Item ".\target\release\stremio-shell-ng.exe" "$env:LOCALAPPDATA\Programs\Stremio\stremio-shell-ng.exe" -Force
Start-Process "$env:LOCALAPPDATA\Programs\Stremio\stremio-shell-ng.exe"
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
<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/7f60857b-471a-439c-9849-8e94fe978518" />
---
<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/f0590feb-65e6-4eab-915f-ea862ba4e038" />


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

### Apple TV Windows
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

**Player**
- Apple overlay: title, round −10 / play-pause / +10 buttons (the mouse seeks straight on the video engine, so it's instant), and Info and Continue Watching pills with sliding panels
- Volume slider and speaker at the top left under the title. With the remote: OK starts changing it, ← / → change it, OK ends it
- Episodes stack (iPhone-style cards). ↑ / ↓ / Back or a click outside closes it
- Up Next row in the last seconds, with a countdown and auto play. Stremio's "Watch now" popup shows first and hides 3 s before Up Next
- Back never goes to a previous episode. It always ends on the show page
- Auto-hide after 3.5 s with no input
- Stats, speed and cast icons moved to the end; the fullscreen icon is hidden in remote mode
- Stremio's own ±10 bubble is replaced by the count on the round buttons

### Remote mode
- Full arrow / OK / Back navigation on every page: sidebar, hero, rows, search, title page, seasons, episodes, related, trailers, links, library and settings
- It remembers your position in each row and returns to it
- Player: ↑ from nothing shows the icons, ↑ again goes to the volume, ↓ goes to the seek bar and then the Info / CW pills
- Subtitles opens on **OFF**. Delay / Size / Position: OK, then ← / →, then OK
- Volume keys on the remote always reach Windows
- Screen Keyboard for search; Back closes it

### Vision Glass
- Glass sidebar with Continue Watching / Trending and a Latest list (the header stays fixed while the list scrolls)
- Glass player menus and tabs without underlines

### YouTube Style
- YouTube layout and player
- Hover glow that takes its colour from each thumbnail, like real YouTube

---

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
