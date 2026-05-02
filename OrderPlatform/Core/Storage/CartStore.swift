import Foundation
import Observation

/// Observable cart with UserDefaults persistence (mirrors CartStorage Flow usage).
@Observable
final class CartStore {
    private let storage = CartStorage()
    private(set) var lines: [CartLine] = []

    init() {
        lines = storage.loadLines()
    }

    func setLines(_ lines: [CartLine]) {
        self.lines = lines
        storage.saveLines(lines)
    }

    func clear() {
        lines = []
        storage.clear()
    }
}
