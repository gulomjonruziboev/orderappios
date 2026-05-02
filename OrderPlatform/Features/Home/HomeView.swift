import SwiftUI

struct HomeView: View {
    let deps: AppDependencies
    @Binding var path: NavigationPath

    @State private var categories: [CategoryDTO] = []
    @State private var popular: [FoodDTO] = []
    @State private var news: [NewsDTO] = []
    @State private var searchText = ""
    @State private var searchResults: [FoodDTO] = []
    @State private var loading = true
    @State private var errorText: String?

    private var lang: String { AppLocale.languageCode }

    var body: some View {
        List {
            if !searchResults.isEmpty {
                Section("Search") {
                    ForEach(searchResults, id: \.identity) { food in
                        foodRow(food)
                    }
                }
            }
            Section("Categories") {
                if categories.isEmpty, loading {
                    ProgressView()
                } else {
                    ForEach(categories, id: \.identity) { cat in
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
                }
            }
            Section("Popular") {
                ForEach(popular, id: \.identity) { food in
                    foodRow(food)
                }
            }
            Section("News") {
                ForEach(news, id: \.identity) { item in
                    newsRow(item)
                }
            }
        }
        .navigationTitle("Home")
        .searchable(text: $searchText, prompt: "Search foods")
        .onSubmit(of: .search) {
            Task { await runSearch() }
        }
        .task {
            await load()
        }
        .refreshable {
            await load()
        }
    }

    private func foodRow(_ food: FoodDTO) -> some View {
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

    private func newsRow(_ item: NewsDTO) -> some View {
        HStack(alignment: .top) {
            thumb(item.primaryImagePath())
            VStack(alignment: .leading) {
                Text(item.title.pick(languageCode: lang))
                    .font(.headline)
                Text(item.summary.pick(languageCode: lang))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
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
        errorText = nil
        do {
            categories = try await deps.catalogRepository.categories()
            popular = try await deps.catalogRepository.foods(popular: true, limit: 24)
            news = await deps.newsRepository.news()
        } catch {
            errorText = String(describing: error)
        }
        loading = false
    }

    private func runSearch() async {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty {
            searchResults = []
            return
        }
        do {
            searchResults = try await deps.catalogRepository.foods(search: q, limit: 40)
        } catch {
            searchResults = []
        }
    }
}
