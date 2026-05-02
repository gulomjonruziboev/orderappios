import SwiftUI

struct OrderSuccessView: View {
    let deps: AppDependencies
    let orderId: String
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            Text("Order placed")
                .font(.title2.bold())
            Text("Order #\(orderId)")
                .font(.body)
                .foregroundStyle(.secondary)
            Button("Continue") {
                onContinue()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Success")
        .navigationBarBackButtonHidden(true)
    }
}
