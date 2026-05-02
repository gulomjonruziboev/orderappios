import SwiftUI

struct FoodDetailView: View {
    let deps: AppDependencies
    let foodId: String

    @State private var food: FoodDTO?
    @State private var loading = true
    @State private var qty = 1

    private var lang: String { AppLocale.languageCode }

    var body: some View {
        Group {
            if let food {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        hero(food.primaryImagePath())
                        Text(food.name.pick(languageCode: lang))
                            .font(.title2.bold())
                        if let p = food.price {
                            Text(String(format: "%.2f", p))
                                .font(.title3)
                        }
                        if let d = food.description?.pick(languageCode: lang), !d.isEmpty {
                            Text(d)
                        }
                        if let ing = food.ingredients, !ing.isEmpty {
                            Text("Ingredients")
                                .font(.headline)
                            ForEach(ing, id: \.self) { i in
                                Text("• \(i)")
                            }
                        }
                        Stepper("Quantity: \(qty)", value: $qty, in: 1 ... 99)
                        Button("Add to cart") {
                            add(food)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            } else if loading {
                ProgressView()
            } else {
                ContentUnavailableView("Not found", systemImage: "questionmark")
            }
        }
        .navigationTitle("Food")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await load()
        }
    }

    private func hero(_ path: String?) -> some View {
        let url = ImageURLResolver.url(path: path)
        return Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(img):
                        img.resizable().scaledToFit()
                    default:
                        Color.gray.opacity(0.2)
                    }
                }
                .frame(maxHeight: 240)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
            }
        }
    }

    private func load() async {
        loading = true
        do {
            food = try await deps.catalogRepository.food(id: foodId)
        } catch {
            food = nil
        }
        loading = false
    }

    private func add(_ food: FoodDTO) {
        let line = CartLine(
            foodId: food.resolvedId(),
            nameSnapshot: food.name.pick(languageCode: lang),
            unitPrice: food.price ?? 0,
            quantity: qty,
            imagePath: food.primaryImagePath()
        )
        deps.orderRepository.addOrMergeLine(line)
    }
}
