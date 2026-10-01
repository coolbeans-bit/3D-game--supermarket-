# 3D Technology Decision

Decision date: 29 September 2026.

This document chooses the 3D technology for As Mitra Game. No package was added. `lib/main.dart` is still the default Flutter counter app. No game assets were created.

Sources checked against Flutter 3.47.5 / Dart 3.13.4:

- [flutter_scene 0.23.0](https://pub.dev/packages/flutter_scene) and [installation](https://fscene.dev/getting-started/installation/)
- [flutter_scene_rapier 0.5.1](https://pub.dev/packages/flutter_scene_rapier)
- [flame_3d 0.3.0](https://pub.dev/packages/flame_3d), pub.dev analysis on Flutter 3.47.4
- [flutter3d 0.8.2](https://pub.dev/packages/flutter3d) and [flutter3d.pleion.dev](https://flutter3d.pleion.dev/)
- [thermion_flutter 0.5.0](https://pub.dev/packages/thermion_flutter)

## Project Requirements

As Mitra Game is an original mobile-first 3D first-person supermarket simulator.

Shipping platforms are Android and iOS. Development happens on this Windows PC, on the Pixel 2 XL API 34 emulator (`sdk gphone64 x86 64`, Android 14). That emulator already runs this app on Impeller (OpenGL ES). iOS builds wait for a Mac with Xcode.

The renderer must support a first-person camera, original glTF/GLB props, skinned character animation, PBR materials, lights, and shadows, at a frame rate that can hold a stocked aisle on a mid-range phone. The player needs a touch joystick, swipe look, collision with the store, and a raycast to pick up products. Flutter widgets must stay on top of the 3D view for the HUD, joystick, and checkout screens.

Firebase cloud save, analytics, and crash reporting come later. The 3D package must not own that data. The game must keep running with a local save.

The supermarket, customers, checkout, inventory, economy, and Firebase gameplay are out of scope until this technology choice is approved and a small scene spike has run on the emulator.

## Technologies Evaluated

### flutter_scene 0.23.0

A realtime 3D engine published by bdero.dev, built by a former Flutter engine engineer on Flutter GPU and Impeller. The current release requires Flutter 3.47 stable or newer, which this project has. pub.dev scores it 150/160, with about 14k downloads and 342 likes. Android, iOS, web, and desktop are documented. Impeller is already the default native renderer in 3.47. Flutter GPU is a separate switch.

The engine loads glTF/GLB at runtime, or converts them at build time to `.fsceneb`. It has skinned animation, physically based materials, image-based lighting, directional, point, and spot lights, and shadows from directional and spot lights, including cascaded maps, contact shadows, and percentage-closer soft shadows. `PerspectiveCamera` and `SceneView` are the camera and widget. `Scene.raycast` and `raycastNode` hit render geometry from a ray. Physics is a separate contract: a kinematic world ships with the engine, and full rigid-body simulation is `flutter_scene_rapier` or `flutter_scene_box3d`.

`SceneView` is an ordinary Flutter widget, so a joystick and HUD are Flutter widgets stacked above it. Firebase plugins do not share this rendering path.

The published `flutter_scene_rapier` 0.5.1 page still says the package requires the Flutter master channel and pins an older `flutter_scene` constraint. That text is older than the 0.23.0 engine requirement of Flutter 3.47 stable. Rapier is excluded from the first spike until a resolve check on 3.47.5 succeeds. Its prebuilt Android binaries include x64, so the current emulator is a supported ABI if that check passes.

The package is pre-1.0. Minor releases can break APIs. The license is MIT.

### flame_3d 0.3.0

Experimental 3D support for the Flame engine, also on Flutter GPU. The maintainers state that it is experimental, that semver is not guaranteed, and that it should not be used in production. pub.dev analyzed 0.3.0 on Flutter 3.47.4 and scored it 60/160. Static analysis failed in `gpu_backend.dart` because the Flutter GPU calls no longer match the signatures in that release. Android, iOS, and macOS are the tested native platforms. Windows is unsupported, so this PC cannot be a desktop render target.

The repository contains a GLB/glTF parser, metallic-roughness material data, and skeletal animation. Lighting in the published discussion is forward rendering with ambient and point lights. The same discussion states that shadows are not implemented. Flame’s documented collision and raycast system is the 2D one. There is no documented 3D physics world. Touch input would be Flame components plus Flutter overlays. Firebase would sit outside Flame, as it would with any other renderer.

### flutter3d 0.8.2

An independent Flutter GPU engine from pleion.dev, not affiliated with the Flutter team. pub.dev scores 0.8.2 at 160/160 and lists Android and iOS. The project site, checked the same day, says Android has been played on a handset with Impeller Vulkan and touch controls, and iOS runs in the simulator on Metal. It also says Windows and Linux are unverified. Downloads are about 830, with 8 likes. The public API moved from the 0.4 line to 0.8 within the same week. Stability is pre-1.0. Only the graphics hardware layer has a written compatibility promise.

It loads glTF 2.0 / GLB, OBJ, and its own `.f3d` container. Animation covers glTF step, linear, and cubic-spline channels, skinning, and crossfades. Lighting includes a PBR model, up to eight lights, cascaded directional shadows, bloom, and tone mapping. Cameras include orbit and follow cameras. CPU raycasting and a bounding-volume hierarchy are in the scene layer. Physics is a separate package: overlap, sweeps, rays, a character controller, and rigid bodies without rotation. On-screen touch controls live in `flutter3d_game`. Pointer lock for a desktop first-person camera is documented for macOS and the web.

The engine is split across dozens of packages so simulation does not import the renderer. That split matches the architecture this game needs. Adopting the engine would also adopt that package surface, its pre-1.0 breakage, and an unverified Windows backend on the machine used to develop the Android build. Firebase is again an outside plugin. The `flutter3d` library itself does not claim web support, because it imports `dart:isolate`. Web rendering is a different backend and is not a target here.

Shaders are an ahead-of-time bundle. A Flutter upgrade requires rebuilding that bundle.

### thermion_flutter 0.5.0

A Flutter plugin over Google Filament 1.69.1. Documented targets are iOS arm64, Android arm64, macOS, Windows x64, and web through WebAssembly. glTF, KTX textures, skinning, and morph targets are supported. The widget path is `ViewerWidget`, with an orbit manipulator and mobile gestures for camera and entity control. The acknowledgments credit sponsored work on raycasting. A character controller, store collision world, and supermarket-scale scene graph are not part of the published feature list.

Android support is arm64. The emulator already used for this project is `x86_64`. A Filament arm64 binary does not load there. Day-to-day testing would need a physical ARM phone or an ARM system image. Filament’s renderer is mature. The binding is a native-asset download of prebuilt binaries, version 0.5.0, under Apache-2.0. Firebase remains a separate Flutter plugin.

`stage_3d` was reviewed and set aside. Its packaged Filament renderer and Jolt physics target Android. iOS is not a shipping backend in the current package text, so it cannot serve both target platforms.

## Comparison

|  | flutter_scene 0.23.0 | flame_3d 0.3.0 | flutter3d 0.8.2 | thermion_flutter 0.5.0 |
| --- | --- | --- | --- | --- |
| Android | Impeller on arm and x64, including this emulator | Listed, and the 3.47.4 analysis of the GPU backend fails | Handset with Impeller Vulkan, per the project site | arm64 only |
| iOS | Supported on Impeller / Metal | Tested by the authors | Simulator on Metal, per the project site | arm64 |
| GLB/glTF | Runtime import and build-time `.fsceneb` | Parser in the package and `flame_3d_extras` | glTF 2.0 / GLB, plus OBJ and `.f3d` | glTF, plus KTX textures |
| Animations | Skinned clips with blend control | Skeletal clips in the glTF parser | Skinned clips, crossfades, glTF interpolation | Skinning and morph targets |
| Lighting | PBR, image-based lighting, directional, point, and spot | Ambient and point, forward rendering | PBR and five other models, up to eight lights | Filament PBR and image-based lighting |
| Shadows | Directional and spot, cascades, contact shadows, soft shadows | Not implemented | Cascaded directional shadows and point-light shadows | Filament shadow maps |
| Cameras | `PerspectiveCamera` on `SceneView` | `CameraComponent3D` | Orbit and follow cameras | Orbit manipulator on `ViewerWidget` |
| Collision | Kinematic contract in the engine; colliders in a physics backend | No 3D collision system documented | Sweeps, overlaps, and a character controller | Not a documented game collision world |
| Raycasting | `Scene.raycast` on render geometry; physics queries in Rapier | Flame’s documented raycast is 2D | CPU raycast and picking | Raycasting credited as sponsored work |
| Physics | Optional Rapier or box3d backend | None documented for 3D | Grid broadphase; rigid bodies do not rotate | Not documented |
| Performance | Instancing, LODs, and a native Impeller path | Experimental forward renderer | Instancing, LOD, and baked visibility; Windows unverified | Filament, on arm64 Android devices |
| Flutter UI | `SceneView` beside normal widgets, including widgets on meshes | `GameWidget` overlays | A render surface plus the engine’s own touch controls | `ViewerWidget` in a Flutter stack |
| Maturity | Pre-1.0, 14k downloads, active 0.23 line, analyzed on Flutter 3.47.4 | Pre-1.0, authors say not for production, analysis errors on 3.47.4 | Pre-1.0, 0.8.2, about 830 downloads, 38 packages | 0.5.0 binding to Filament 1.69.1 |
| Maintainability | One Dart scene graph on Flutter’s own GPU API | Flame ecosystem, GPU API already drifted from 0.3.0 | Strong internal boundaries, large and fast-moving package set | Native Filament binaries beside Dart |

Firebase compatibility is the same for all four. None of them store player data. `firebase_core`, Analytics, and Crashlytics can be added later behind repository interfaces. Cloud save stays out of the renderer.

## Recommended Technology

**flutter_scene**, package `flutter_scene`.

One package for the first spike. Physics backends stay out until a later milestone proves they resolve on Flutter 3.47.5.

## Why It Fits This Game

The supermarket is a Flutter app with a 3D view, not a second engine embedded in Flutter. `SceneView` leaves the joystick, swipe-look gestures, inventory, and checkout UI in ordinary widgets. Product pickup uses the engine’s geometry raycast. Shelves and products are original glTF models, instanced where the same prop repeats. Customers use the skinned animation clips. The store lighting uses the built-in PBR lights and shadows.

It matches the SDK already installed. Flutter 3.47.5 is the stable line the package requires. The Pixel emulator already runs Impeller, and Flutter Scene’s Android support includes x64, so the next spike can be tested on the same emulator that ran the counter app.

`flame_3d` fails analysis on the current stable Flutter GPU API, and its authors exclude production use. `flutter3d` has the right split between simulation and rendering, and a real feature list, but it is a 38-package pre-1.0 stack with a few hundred downloads and no verified Windows backend. `thermion_flutter` brings a proven renderer and then drops the x86_64 emulator this project uses. Filament remains a fallback only if a later spike shows Flutter Scene cannot hold an aisle on a mid-range phone.

Game rules, save data, and Firebase stay in this repository’s own layers. The engine draws the store. It does not define a product, a price, or a payment.

## Risks and Limitations

- `flutter_scene` 0.23.0 is pre-1.0. A minor upgrade can break scene, material, or animation calls. Pin the version when it is added, and read the changelog before every bump.
- Flutter GPU is off until the app turns it on. A scene spike that forgets the Android metadata key fails at startup.
- The published Rapier readme still requires the master channel. Do not add `flutter_scene_rapier` in the first spike. Before any physics milestone, resolve it on Flutter 3.47.5. If it refuses stable, use the engine’s kinematic world for the player capsule and static shelves, and keep Rapier for a later review.
- A stocked aisle is a performance budget. Instancing, texture size, and shadow cascades have to be measured on the emulator and then on a physical phone. The decision does not claim a frame-rate number yet.
- iOS is documented and untested here. The plist key should be added with the Android key so a Mac build is ready. The first proof is Android.
- SoLoud and FMOD audio backends in the Scene repository are not the plan for game audio. Audio stays a separate published Flutter package when that phase starts.
- Original models, textures, and sounds are required. The engine does not supply a supermarket.

## Proposed Game Architecture

Four layers. Each layer may depend on the ones below it. A feature rule never imports `SceneView`. The scene adapter never imports Firebase.

```text
Flutter UI          joystick, swipe-look, HUD, menus, checkout screens
        |
Game simulation     player intent, inventory, stocking, customers,
                    checkout, prices, deliveries, progression
        |
Scene adapter       Scene, nodes, camera, lights, raycasts, colliders
        |
Data                product and store models, local save, later Firebase
```

- **Data models** are plain Dart: a product id, a shelf slot, a price, an inventory stack, a save snapshot. They know nothing about meshes or widgets.
- **Game simulation** advances those models on a tick. Customer movement, checkout totals, and upgrade rules live here. It emits intents such as “move”, “look”, and “use”.
- **Scene adapter** is the only code that imports `flutter_scene`. It loads the level, places instances, moves the camera from look input, and returns the node id a ray hits. A hit id is mapped back to a product id from data, not from the mesh name alone.
- **Flutter UI** draws the joystick and HUD and forwards pointer deltas. Checkout, barcode entry, and cash, card, and UPI-style payment are widgets over the simulation.
- **Firebase** is a second implementation of the save, analytics, and crash interfaces. The local implementation is the one the game uses until that phase.

First-person movement, when it arrives, is a kinematic capsule in the scene adapter driven by joystick input from the UI. The simulation owns what the player is allowed to carry. The adapter owns whether the capsule overlaps a shelf.

## Proposed Folder Structure

The counter app in `lib/main.dart` stays until the scene spike is approved. The folders below are the target layout. They are not created in this step.

```text
E:\ASmitra-game\
  lib\
    main.dart                     # counter app until the spike is approved
    app\                          # MaterialApp, theme, routes
    data\
      models\                     # product, shelf, price, save snapshot
      local\                      # local save implementation
      remote\                     # Firebase implementations, added in that phase
    game\
      simulation\                 # rules and ticks, no Flutter, no Scene
      scene\                      # flutter_scene adapter, camera, raycasts
    ui\
      hud\
      controls\                   # joystick and look gesture
      checkout\
  assets\                         # original glTF, textures, audio, added later
  test\
    data\
    game\
  docs\
    PROJECT_PLAN.md
    3D_TECHNOLOGY_DECISION.md
```

`game/simulation` tests run with `flutter test` and never open a GPU. `game/scene` is the only folder allowed to import `package:flutter_scene/scene.dart`.

## Development Roadmap

1. **Scene spike.** Add `flutter_scene` only. Enable Flutter GPU on Android and iOS. Show one lit built-in mesh in a `SceneView`, with a Flutter widget still visible above it. Run it on the Pixel emulator. No store, no model files, no physics package.
2. **First-person slice.** Perspective camera, joystick widget, swipe look, and a floor the camera cannot fall through. Use the engine kinematic world if it covers that. Resolve Rapier on 3.47.5 before adding it.
3. **Interaction slice.** One shelf, a few original products, a raycast, pickup, drop, and an inventory model.
4. **Store loop.** Stocking, one customer path, checkout, and cash, card, and UPI-style payment as simulation rules with Flutter screens.
5. **Economy.** Prices, deliveries, upgrades, and progression.
6. **Persistence.** Local save, then Firebase cloud save, analytics, and crash reporting.
7. **Presentation.** Character animation and audio on actions that already exist.

Each step waits for review. The scene spike is the only step this decision unlocks.

## Packages and platform configuration

Not added in this step.

| When | Package | Role |
| --- | --- | --- |
| Scene spike | `flutter_scene` | Rendering, glTF, cameras, animation, lights, shadows, geometry raycasts. `vector_math` comes with it. |
| First-person collision, only after a resolve check | `flutter_scene_rapier` | Character controller, static colliders, physics raycasts. Alternate backend: `flutter_scene_box3d`. |
| Local save | Chosen at that phase | Progress before Firebase |
| Audio | A published Flutter audio package | Playback of original sounds |
| Firebase phase | `firebase_core`, Auth, a cloud database package, Analytics, Crashlytics | Cloud save, analytics, crash reporting |

Platform configuration for the scene spike, applied only after approval:

- Android, inside `<application>` in `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="io.flutter.embedding.android.EnableFlutterGPU"
    android:value="true" />
```

- iOS, inside the top-level dict in `ios/Runner/Info.plist`:

```xml
<key>FLTEnableFlutterGPU</key>
<true/>
```

- Development runs can also pass `flutter run --enable-flutter-gpu`.
- Impeller is already the default on Android and iOS in Flutter 3.47. No Impeller flag is required for those two platforms.
- `dart run flutter_scene:init` is for the asset pipeline, when original models exist. The spike can render a built-in cube without it.

## Next milestone

**Scene spike, after approval.**

Add `flutter_scene` only. Enable Flutter GPU on Android and iOS. Add one screen with a `SceneView`, one lit built-in mesh, and a `PerspectiveCamera`, and keep a Flutter control visible on top of it. Run that screen on the Pixel 2 XL emulator. Leave customers, shelves, products, inventory, checkout, economy, Firebase, and audio unimplemented. Leave Rapier unadded until the following milestone.
