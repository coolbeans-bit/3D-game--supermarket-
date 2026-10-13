# As Mitra Game — Project Plan

Status: Milestones 1–8 are complete. Milestone 9 has not started.

## Milestone record

Updated 1 October 2026. The inspection notes and phase list below are the original foundation plan. Delivery followed the later milestone briefs.

| Milestone | Status | Delivered |
| --- | --- | --- |
| 1 | Complete | Flutter Scene, Flutter GPU, a lit scene, a camera, and a Flutter HUD |
| 2 | Complete | First-person movement, joystick, look, and collision |
| 3 | Complete | Raycast interaction, prompts, and the use button |
| 4 | Complete | Supermarket blockout: entrance, aisles, shelves, checkout, storage |
| 5 | Complete | Product catalog, shelf stock, and product visuals |
| 6 | Complete | Pickup, carry, and place |
| 7 | Complete | Checkout transaction, barcode scan, cash, and change |
| 8 | Complete | Customer spawn, shopping lists, waypoint visit, and exit. Chiku is mascot data only |

Customers do not take products or pay yet. That waits for a later milestone. Visual direction is recorded in `docs/VISUAL_DESIGN_DIRECTION.md`.

Inspection date: 29 September 2026.

## Inspection snapshot

The workspace `E:\ASmitra-game` was an empty folder when this plan was written. It was not a Flutter application and it was not a Git repository. There was no `pubspec.yaml`, no `lib/`, and no `test/` to preserve.

| Check | Result |
| --- | --- |
| Flutter | 3.43.0-0.1.pre, beta channel, framework revision 66c2526ea1 (11 March 2026) |
| Dart | 3.12.0 (3.12.0-210.1.beta) |
| DevTools | 2.56.0 |
| Flutter SDK | `C:\Users\pc\FLutter Development\flutter` |
| Android SDK | 35.0.0 at `C:\Users\pc\AppData\Local\Android\sdk` |
| Android platform / build-tools | android-36, build-tools 35.0.0 |
| Java | OpenJDK 21, bundled with Android Studio |
| Android licenses | Accepted |
| `flutter doctor` | No issues found |
| Connected devices | Windows desktop, Chrome, Edge. No phone attached. |
| Android emulator | Pixel 2 XL API 34 installed, not running |
| iOS | Cannot be built on this Windows PC. A Mac with Xcode is required later. |
| `flutter analyze` | Not run at inspection time, because there was no project |

The installed beta SDK was older than Flutter Scene, which needs Flutter 3.47 stable or newer. The foundation step upgraded this machine to current stable before `flutter create`.

## Foundation result

Completed on 29 September 2026.

| Check | Result |
| --- | --- |
| Flutter | 3.47.5, stable channel, revision 6a19cca564 (17 September 2026) |
| Dart | 3.13.4 |
| DevTools | 2.60.0 |
| App | `asmitra_game`, organization `com.asmitra`, platforms Android and iOS |
| Dependencies | Flutter SDK, `cupertino_icons` (template default). No game packages. |
| Git | Repository initialized. No commit created. |
| `flutter analyze` | No issues found |
| `flutter test` | Default counter test passed |
| Android debug build | `flutter build apk --debug` succeeded. Output: `build/app/outputs/flutter-apk/app-debug.apk`. The first attempt failed on a temporary Maven hostname lookup; the retry succeeded. Gradle also installed Android SDK Build-Tools 36. |
| iOS build | Not run. This PC has no Xcode. |

`docs/PROJECT_PLAN.md` was already in the folder when `flutter create` ran, and it was left in place.

## A. Project goal

As Mitra Game is an original mobile-first 3D supermarket simulator. The player moves through a store in first person, stocks shelves, serves customers, and takes payment. Characters, models, textures, sounds, names, branding, and interface are created for this project. Nothing is copied from an existing game.

Firebase is planned for later cloud save, analytics, and crash reporting. The game must run with a local save before any Firebase package is added.

## B. Target platforms

- Android, developed and tested on this PC.
- iOS, a shipping target. Builds require a Mac with Xcode. The Flutter project includes the iOS runner so the same Dart code is ready for that machine.

Windows, Chrome, and Edge are available for tooling checks. They are not the game targets.

## C. Proposed game type

- 3D
- First person
- Mobile touch controls
- Supermarket simulation

## D. Major gameplay systems

These are the systems the game will eventually need. They are not implemented in the foundation step.

- 3D environment
- Player movement
- Camera and look controls
- Touch joystick
- Interaction and raycast system
- Supermarket shelves
- Products
- Product pickup and drop
- Inventory
- Stocking
- Customers
- Customer AI
- Checkout
- Barcode scanning
- Cash payment
- Card payment
- UPI-style payment
- Pricing
- Store economy
- Deliveries
- Store upgrades
- Progression
- Save system
- Firebase cloud save
- Analytics
- Crash reporting
- Audio
- Animations

## E. Development phases

1. **Foundation.** Upgrade Flutter to 3.47 stable or newer. Initialize Git. Create the Flutter app for Android and iOS only. Confirm the generated app builds. Add no game packages.
2. **Architecture shell.** Add the folders in section F and empty feature boundaries. No gameplay.
3. **3D vertical slice.** One original room, a first-person camera, a touch joystick, look drag, and floor collision. This is the first phase that may add `flutter_scene`.
4. **Store interaction.** One shelf, a few original products, raycast pickup, inventory, and stocking.
5. **Customers and checkout.** A simple customer path, one checkout lane, and cash, card, and UPI-style payment as game rules.
6. **Economy.** Prices, deliveries, upgrades, and progression.
7. **Persistence.** Local save first, then Firebase cloud save, analytics, and crash reporting.
8. **Presentation.** Audio, character animation, and polish on actions that already exist.

Each phase waits for review before the next one starts.

## F. Proposed Flutter project architecture

The Dart package name is `asmitra_game`. The app is created in `E:\ASmitra-game`.

Gameplay stays out of widgets. Widgets send input and draw the HUD. Feature code does not import the 3D view. The 3D layer does not import Firebase. Save, analytics, and crash reporting sit behind interfaces so the game runs without them.

```text
E:\ASmitra-game\
  pubspec.yaml
  lib\
    main.dart
    app\                  # MaterialApp, routes, theme
    game\
      scene\              # Scene view, level load, lights, cameras
      input\              # Touch look and virtual joystick state
      interaction\        # Raycast use, pickup, drop
      simulation\         # Tick loop for customers and economy
    features\
      store\              # Layout, shelves, stocking
      catalog\            # Products, pricing
      inventory\
      checkout\           # Cash, card, UPI-style payment
      customers\
      economy\            # Deliveries, upgrades, progression
      save\
    ui\                   # HUD, menus, joystick widget
  assets\                 # Original models, audio, images
  test\
  docs\
    PROJECT_PLAN.md
```

The foundation step creates the default Flutter app only. The folders above are added in phase 2, after review. The generated counter app stays until that phase replaces it.

## G. 3D rendering approach

### Comparison

| Approach | Android and iOS | Performance | glTF / GLB | Animation | Lighting | Cameras | Collision | Raycasting | Touch | Maintainability | Maturity |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **flutter_scene** | Both, through Impeller and Flutter GPU | Native GPU path, instancing and LODs | Runtime import and build-time `.fsceneb` | Skinned clips | PBR, image-based lighting, punctual lights and shadows | Perspective camera on `SceneView` | Separate package: Rapier or box3d | Pointer raycasting into the scene | Flutter widgets over the view | One Dart codebase beside normal Flutter UI | 0.23.0, pre-1.0, MIT. Actively developed by a former Flutter engine engineer. Minor versions can break APIs. |
| Thermion and other Filament wrappers | Both, native | Strong renderer | Yes | Yes | Yes | Yes | Custom | Picking, limited game tooling | Custom | A second renderer integration to keep current | Less active than Flutter Scene for a full game |
| three_js and WebView model viewers | Both, usually a web view or JS bridge | Weak once many shelf products are on screen | Yes | Partial | Partial | Yes | Custom | Three.js-style raycaster in some ports | Custom | Fine for a product preview, poor as the store | Mature for viewing, not for this game |
| Flame 3D | Uneven on Android devices | Not reliable enough for a first-person store | Limited | Limited | Limited | Limited | 2D Flame is separate | Limited | Flame gestures are 2D-first | 2D Flame is mature; its 3D path is not the base of this game | Unstable for this use |
| Unity or Godot embedded in Flutter | Both | Full game-engine performance | Yes | Yes | Yes | Yes | Built in | Built in | Split between engine and Flutter | Second toolchain, larger binary, split codebase | Mature engines, poor fit for a Flutter-owned project |

### Choice

Use **Flutter Scene (`flutter_scene`)** after Flutter is on 3.47 stable or newer.

It renders through Flutter GPU and Impeller, draws into a `SceneView` widget, and keeps gameplay in Dart. Android and iOS are both supported. Original store models should be authored as glTF/GLB and converted at build time to `.fsceneb`. Shelf props should be instanced.

Touch movement stays in Flutter: a joystick widget and a look-drag handler over the scene. Physics is not part of the first package add. When the vertical slice needs collision, add `flutter_scene_rapier` for a player capsule and static store colliders. `flutter_scene_box3d` is the alternate backend if Rapier is a poor fit. Interaction uses Scene pointer raycasts.

Flutter GPU must be enabled for Android and iOS when the package is added:

- Android: `io.flutter.embedding.android.EnableFlutterGPU` metadata in `AndroidManifest.xml`
- iOS: `FLTEnableFlutterGPU` in `Info.plist`
- During development: `flutter run --enable-flutter-gpu`

Do not add Flame, a model-viewer package, or an embedded game engine.

### Packages, added only in the phase that needs them

None in the foundation step.

| Phase | Package | Role |
| --- | --- | --- |
| 3D vertical slice | `flutter_scene` | Rendering, glTF, cameras, animation, raycasting. `vector_math` comes with it. |
| Player collision | `flutter_scene_rapier` | Character and shelf collision |
| Local save | A small local-storage package, chosen at that phase | Progress before Firebase |
| Audio | A published audio package | Scene’s SoLoud backend is not published on pub.dev yet |
| Firebase | `firebase_core`, Auth, a cloud database package, Analytics, Crashlytics | Cloud save, analytics, crash reporting |

## Next step after foundation

Review this plan against the generated app. The following implementation step is phase 2: the architecture shell, still with no 3D package. The 3D vertical slice waits for a separate approval.
