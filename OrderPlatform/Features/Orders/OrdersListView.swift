import SwiftUI

struct OrdersListView: View {
    let deps: AppDependencies

    @State private var orders: [OrderSummaryDTO] = []
    @State private var loading = true

    private var lang: String { AppLocale.languageCode }

    var body: some View {
        Group {
            if loading {
                ProgressView()
            } else if orders.isEmpty {
                ContentUnavailableView("No orders yet", systemImage: "list.clipboard")
            } else {
                List(orders, id: \.identity) { o in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(o.orderNumber ?? o.resolvedId())
                            .font(.headline)
                        if let date = o.createdAt {
                            Text(date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text(String(format: "Total: %.2f", o.resolvedTotal()))
                        if let s = o.status {
                            Text(s).font(.caption)
                        }
                    }
                }
            }
        }
        .navigationTitle("Orders")
        .task {
            await load()
        }
    }

    private func load() async {
        loading = true
        do {
            orders = try await deps.orderRepository.orders()
        } catch {
            orders = []
        }
        loading = false
    }
}
