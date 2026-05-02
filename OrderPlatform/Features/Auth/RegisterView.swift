import SwiftUI

struct RegisterView: View {
    let deps: AppDependencies
    var onSuccess: () -> Void
    var onLogin: () -> Void

    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var busy = false
    @State private var errorText: String?

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
                SecureField("Password", text: $password)
            }
            if let errorText {
                Section {
                    Text(errorText).foregroundStyle(.red)
                }
            }
            Section {
                Button(busy ? "Creating…" : "Register") {
                    Task { await register() }
                }
                .disabled(busy || name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty)
                Button("Already have an account? Log in") {
                    onLogin()
                }
            }
        }
        .navigationTitle("Register")
    }

    private func register() async {
        busy = true
        errorText = nil
        do {
            try await deps.authRepository.register(
                name: name,
                email: email,
                phone: phone,
                password: password
            )
            deps.refreshAuth()
            onSuccess()
        } catch {
            errorText = String(describing: error)
        }
        busy = false
    }
}
