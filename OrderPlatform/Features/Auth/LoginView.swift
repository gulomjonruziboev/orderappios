import SwiftUI

struct LoginView: View {
    let deps: AppDependencies
    var onSuccess: () -> Void
    var onRegister: () -> Void
    var onGuest: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var busy = false
    @State private var errorText: String?

    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $password)
            }
            if let errorText {
                Section {
                    Text(errorText).foregroundStyle(.red)
                }
            }
            Section {
                Button(busy ? "Signing in…" : "Sign in") {
                    Task { await login() }
                }
                .disabled(busy || email.isEmpty || password.isEmpty)
                Button("Create account") {
                    onRegister()
                }
                Button("Continue as guest", role: .cancel) {
                    onGuest()
                }
            }
        }
        .navigationTitle("Log in")
    }

    private func login() async {
        busy = true
        errorText = nil
        do {
            try await deps.authRepository.login(email: email, password: password)
            deps.refreshAuth()
            onSuccess()
        } catch {
            errorText = String(describing: error)
        }
        busy = false
    }
}
