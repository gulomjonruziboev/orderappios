import SwiftUI

struct CategoriesView: View {
    let deps: AppDependencies
    @Binding var path: NavigationPath

    @State private var categories: [CategoryDTO] = []
    @State private var loading = true

    private var lang: String { AppLocale.languageCode }

    var body: some View {
        List(categories, id: \.identity) { cat in
            Button {
                path.append(.categoryFoods(cat.resolvedId()))
            } label: {
                HStack {
                    Text(cat.name.pick(languageCode: lang))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Categories")
        .overlay {
            if loading { ProgressView() }
        }
        .task {
            await load()
        }
    }

    private func load() async {
        loading = true
        do {
            categories = try await deps.catalogRepository.categories()
        } catch {
            categories = []
        }
        loading = false
    }
}
