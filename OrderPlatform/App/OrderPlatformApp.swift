import SwiftUI

@main
struct OrderPlatformApp: App {
    @State private var deps = AppDependencies()

    var body: some Scene {
        WindowGroup {
            OrderAppShell(deps: deps)
        }
    }
}
