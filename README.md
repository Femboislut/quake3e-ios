# Quake III Arena for iOS — Quake3e Enhanced Port

An enhanced, independently maintained **Quake III Arena port for iPhone and iPad**, based on [rebelancap's Quake3e iOS port](https://github.com/rebelancap/quake3e-ios) and the [Quake3e engine](https://github.com/ec-/Quake3e).

This project brings the Quake3e engine to iOS with a native ARM64 app, Vulkan rendering through MoltenVK/Metal, internet multiplayer, touch controls, gyroscope aiming, and game-controller support. It is intended for people searching for **Quake III on iOS**, **Quake 3 for iPhone**, **Quake3e iOS**, or a modern **Quake III Arena iPhone port**.

This repository is an enhanced fork, not the original Quake III iOS port. It builds on the upstream iOS work and maintains its own fixes and improvements. It is not affiliated with or endorsed by id Software.

## Highlights

- Quake III Arena engine based on Quake3e.
- Vulkan renderer running through MoltenVK on Apple's Metal graphics API.
- Internet multiplayer and server browser.
- Touch movement and right-side swipe camera-look controls.
- Configurable on-screen controls.
- Gyroscope aiming with separate horizontal and vertical inversion options.
- Game-controller support.
- In-game settings and persistent preferences.
- iOS menu touch/cursor mapping improvements.
- GitHub Actions workflow for building and publishing an iOS IPA.

Features and compatibility may vary by device, iOS version, and game/mod data. This fork targets iOS; visionOS/Apple Vision Pro support is not claimed or tested here.

## Download

Get the latest iOS IPA from **[GitHub Releases](https://github.com/TangiDev69/quake3e-ios/releases/latest)**.

The IPA is unsigned. Depending on your device and setup, installation/import options may include:

- **SideStore** — install the IPA using your configured SideStore workflow.
- **AltStore** — sideload the IPA using AltStore.
- **LiveContainer** — import the IPA into LiveContainer where supported by your configuration.

Signing, refresh limits, compatibility, and installation steps depend on the selected tool and its version. Follow that tool's current instructions.

## You must provide your own game files

The app does not include Quake III Arena copyrighted game data. You must supply your own legally obtained copy of the game.

At launch, use the file picker to import your `baseq3` folder, including `pak0.pk3`. Optional mods may be placed in their own folders alongside `baseq3`, subject to compatibility.

The engine/app and the original commercial game data are separate: this repository does not distribute the retail game assets.

## Controls

- **Touch:** use the left side for movement and drag on the right to look; use the on-screen buttons for actions. Layout and sensitivity can be adjusted in Settings.
- **Gyroscope:** optional gyro aiming, with independent horizontal and vertical inversion.
- **Controller:** gamepad input is supported; bindings can be adjusted through Quake's configuration and console.

## Build

The GitHub Actions workflow builds the iOS IPA and publishes it as a release asset when changes are pushed to the configured build branch. The workflow can also be started manually from the repository's Actions tab.

The build uses the pinned Quake3e upstream revision and applies this fork's patch series. See `upstream.pin`, `patches/`, and `scripts/sync-overlay.sh`.

## Lineage, credits, and license

- **Original iOS port:** [rebelancap/quake3e-ios](https://github.com/rebelancap/quake3e-ios).
- **Engine:** [Quake3e](https://github.com/ec-/Quake3e), based on ioquake3 and the Quake III Arena source.
- **AI-assisted development:** Codex assisted with investigation, debugging, code changes, and build-workflow work in this fork.
- Quake III Arena © id Software. This project is not affiliated with or endorsed by id Software.

This project is licensed under **GNU GPL v2**; see [COPYING](COPYING). Game assets are not included; users must provide their own legally obtained game files.
