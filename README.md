# OrderPlatform (iOS)

Native SwiftUI client for the same REST backend as the Android app in **orderandroid**. The API contract is defined by [`OrderApi.kt`](../../orderandroid/app/src/main/java/com/orderplatform/app/data/network/OrderApi.kt) in that repository (sibling of the `orderios` folder that contains this project).

## Requirements

- **macOS** with **Xcode 15+** (project format object version 56)
- **iOS 17.0** minimum deployment target
- Build and run on Simulator or device from the `OrderPlatform.xcodeproj` workspace

## Configure API base URL

URLs are **not** hardcoded for secrets; they come from build configuration via `.xcconfig`:

| Variable       | Purpose |
|----------------|---------|
| `API_BASE_URL` | REST prefix, e.g. `https://your-host.com/api/` |
| `API_ORIGIN`   | Origin for resolving relative image paths (e.g. `/uploads/...`) |

Files: [`Config/Debug.xcconfig`](Config/Debug.xcconfig), [`Config/Staging.xcconfig`](Config/Staging.xcconfig), [`Config/Release.xcconfig`](Config/Release.xcconfig).

The Xcode project links these at the **project** level for configurations **Debug**, **Staging**, and **Release**. Values are injected into the generated Info.plist as `APIBaseURL` and `APIOrigin`, read at runtime by [`APIConfig.swift`](OrderPlatform/Config/APIConfig.swift).

To point at another backend, edit the appropriate `.xcconfig` or duplicate a configuration in Xcode and set `API_BASE_URL` / `API_ORIGIN` there.

## Layout

- **`OrderPlatform/App`** — SwiftUI entry, shell navigation, composition root (`AppDependencies`)
- **`OrderPlatform/Core/API`** — `URLSession` client, DTOs, repositories
- **`OrderPlatform/Core/Storage`** — Keychain JWT, `UserDefaults` cart JSON, session / 401 signaling
- **`OrderPlatform/Features`** — screens (home, categories, cart, checkout, auth, orders)

## Tests

`OrderPlatformTests` includes Codable tests for category string vs object, `accessToken`-only auth JSON, and order total field resolution. Run **Cmd+U** in Xcode.

## Manual QA

- End-to-end: browse → cart → checkout → order success.
- With a valid token, force HTTP **401** from the API; the app should clear the JWT only, show login (full screen), and reset tab navigation after the unauthorized event.
# orderappios
