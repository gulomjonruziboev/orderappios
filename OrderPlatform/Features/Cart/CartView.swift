import Observation
import SwiftUI

struct CartView: View {
    let deps: AppDependencies
    @Bindable var cartStore: CartStore
    @Binding var path: NavigationPath

    var body: some View {
        Group {
            if cartStore.lines.isEmpty {
                ContentUnavailableView("Cart is empty", systemImage: "cart")
            } else {
                List {
                    Section {
                        ForEach(cartStore.lines) { line in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(line.nameSnapshot)
                                    Text(String(format: "%.2f × %d", line.unitPrice, line.quantity))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Stepper(
                                    value: binding(for: line),
                                    in: 1 ... 99
                                )
                            }
                        }
                        .onDelete(perform: delete)
                    }
                    Section {
                        Button("Checkout") {
                            path.append(.checkout)
                        }
                    }
                }
            }
        }
        .navigationTitle("Cart")
    }

    private func binding(for line: CartLine) -> Binding<Int> {
        Binding(
            get: {
                cartStore.lines.first(where: { $0.foodId == line.foodId })?.quantity ?? 1
            },
            set: { newQty in
                var lines = cartStore.lines
                guard let i = lines.firstIndex(where: { $0.foodId == line.foodId }) else { return }
                lines[i] = CartLine(
                    foodId: lines[i].foodId,
                    nameSnapshot: lines[i].nameSnapshot,
                    unitPrice: lines[i].unitPrice,
                    quantity: newQty,
                    imagePath: lines[i].imagePath
                )
                deps.orderRepository.updateCart(lines: lines)
            }
        )
    }

    private func delete(at offsets: IndexSet) {
        var lines = cartStore.lines
        lines.remove(atOffsets: offsets)
        deps.orderRepository.updateCart(lines: lines)
    }
}
