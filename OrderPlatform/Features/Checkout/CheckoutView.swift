import SwiftUI

struct CheckoutView: View {
    let deps: AppDependencies
    @Binding var path: NavigationPath

    @State private var phone = ""
    @State private var name = ""
    @State private var address = ""
    @State private var notes = ""
    @State private var busy = false
    @State private var errorText: String?

    var body: some View {
        Form {
            Section("Contact") {
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
                TextField("Name (optional)", text: $name)
            }
            Section("Delivery") {
                TextField("Address (optional)", text: $address, axis: .vertical)
                    .lineLimit(3 ... 6)
                TextField("Notes (optional)", text: $notes, axis: .vertical)
                    .lineLimit(2 ... 6)
            }
            if let errorText {
                Section {
                    Text(errorText).foregroundStyle(.red)
                }
            }
            Section {
                Button(busy ? "Placing…" : "Place order") {
                    Task { await place() }
                }
                .disabled(busy || phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("Checkout")
    }

    private func place() async {
        busy = true
        errorText = nil
        let p = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let a = address.trimmingCharacters(in: .whitespacesAndNewlines)
        let note = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            let id = try await deps.orderRepository.placeOrder(
                phone: p,
                customerName: n.isEmpty ? nil : n,
                address: a.isEmpty ? nil : a,
                notes: note.isEmpty ? nil : note
            )
            var next = path
            next.removeLast()
            next.append(.orderSuccess(id))
            path = next
        } catch {
            errorText = String(describing: error)
        }
        busy = false
    }
}
