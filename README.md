# Quake3e for iOS — Enhanced Fork

An improved iPhone/iPad fork of [rebelancap's Quake3e iOS port](https://github.com/rebelancap/quake3e-ios), built on [Quake3e](https://github.com/ec-/Quake3e).

This fork focuses on a reliable iOS experience, refined touch controls, gameplay input, and fixes tested on real devices. It is maintained independently and is **not affiliated with id Software**.

## Highlights

- Quake III Arena engine with Vulkan via MoltenVK/Metal
- Internet multiplayer and server browser
- Touch movement and look controls, with configurable on-screen controls
- Gyroscope aiming with separate horizontal/vertical inversion options
- Game-controller support
- In-game settings and persistent preferences
- Menu touch/cursor mapping fixes for iOS
- Builds distributed as directly downloadable IPA releases

Features and compatibility may vary by device and game/mod data. VisionOS/Apple Vision Pro support is not claimed or tested in this fork.

## Download

Get the latest iOS IPA from **[Releases](https://github.com/Femboislut/quake3e-ios/releases/latest)**.

Install the IPA using a compatible sideloading tool (such as SideStore or AltStore). This is an unsigned build; signing and installation are handled on your device.

## Game files

The app does not include Quake III Arena copyrighted game data. You must supply your own legally obtained game files.

At launch, use the file picker to import your `baseq3` folder (including `pak0.pk3`). Optional mods can be placed in their own folders alongside `baseq3`, subject to compatibility.

## Controls

- **Touch:** left side for movement; drag on the right to look; on-screen buttons for actions. Layout and sensitivity can be adjusted in Settings.
- **Gyroscope:** optional gyro aiming, with independent horizontal and vertical inversion.
- **Controller:** gamepad input is supported; bindings can be adjusted through Quake's configuration/console.

## Build

The GitHub Actions workflow builds the iOS IPA and publishes it as a release asset automatically when changes are pushed to the build branch. The workflow can also be started manually from the repository's Actions tab.

The build uses the pinned Quake3e upstream revision and applies this fork's patch series. See `upstream.pin`, `patches/`, and `scripts/sync-overlay.sh`.

## Credits & attribution

- **Original iOS port:** [rebelancap/quake3e-ios](https://github.com/rebelancap/quake3e-ios)
- **Engine:** [Quake3e](https://github.com/ec-/Quake3e), with ioquake3 and id Software's Quake III Arena source
- **AI-assisted development:** ChatGPT assisted with investigation, debugging, code changes, and build workflow work in this fork.
- Quake III Arena © id Software. This project is not affiliated with or endorsed by id Software.

This project is licensed under **GNU GPL v2**; see [COPYING](COPYING).
