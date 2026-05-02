import SwiftUI

struct FoodListView: View {
    let deps: AppDependencies
    let categoryId: String
    @Binding var path: NavigationPath

    @State private var foods: [FoodDTO] = []
    @State private var title = ""
    @State private var loading = true

    private var lang: String { AppLocale.languageCode }

    var body: some View {
        List(foods, id: \.identity) { food in
            Button {
                path.append(.food(food.resolvedId()))
            } label: {
                HStack {
                    thumb(food.primaryImagePath())
                    VStack(alignment: .leading) {
                        Text(food.name.pick(languageCode: lang))
                        if let p = food.price {
                            Text(String(format: "%.2f", p))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(title.isEmpty ? "Foods" : title)
        .overlay {
            if loading { ProgressView() }
        }
        .task {
            await load()
        }
    }

    private func thumb(_ path: String?) -> some View {
        let url = ImageURLResolver.url(path: path)
        return Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(img):
                        img.resizable().scaledToFill()
                    default:
                        Color.gray.opacity(0.2)
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 56, height: 56)
            }
        }
    }

    private func load() async {
        loading = true
        do {
            let cat = try await deps.catalogRepository.category(id: categoryId)
            title = cat.name.pick(languageCode: lang)
            foods = try await deps.catalogRepository.foods(categoryId: categoryId, limit: 100)
        } catch {
            foods = []
        }
        loading = false
    }
}
