import SwiftUI

struct AccountView: View {
    let deps: AppDependencies
    @Binding var path: NavigationPath

    var body: some View {
        List {
            if deps.authState.isLoggedIn {
                Section {
                    Button("Order history") {
                        path.append(.orders)
                    }
                    Button("Log out", role: .destructive) {
                        deps.authRepository.logout()
                        deps.refreshAuth()
                    }
                }
            } else {
                Section {
                    Button("Log in") {
                        path.append(.login)
                    }
                    Button("Register") {
                        path.append(.register)
                    }
                }
            }
        }
        .navigationTitle("Account")
        .onAppear { deps.refreshAuth() }
    }
}
