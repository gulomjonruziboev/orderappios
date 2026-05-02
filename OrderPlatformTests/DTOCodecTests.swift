import XCTest
@testable import OrderPlatform

final class DTOCodecTests: XCTestCase {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    func testFoodCategoryAsString() throws {
        let json = """
        {"_id":"f1","name":{"en":"Pizza"},"category":"507f1f77bcf86cd799439011","price":9.99}
        """.data(using: .utf8)!
        let food = try decoder.decode(FoodDTO.self, from: json)
        XCTAssertEqual(food.category, "507f1f77bcf86cd799439011")
    }

    func testFoodCategoryAsObject() throws {
        let json = """
        {"_id":"f1","name":{"en":"Pizza"},"category":{"_id":"abc123","name":{"en":"X"}},"price":1}
        """.data(using: .utf8)!
        let food = try decoder.decode(FoodDTO.self, from: json)
        XCTAssertEqual(food.category, "abc123")
    }

    func testAuthAccessTokenOnly() throws {
        let json = """
        {"accessToken":"jwt-here","user":{"email":"a@b.c"}}
        """.data(using: .utf8)!
        let auth = try decoder.decode(AuthResponseDTO.self, from: json)
        XCTAssertEqual(auth.tokenValue(), "jwt-here")
    }

    func testOrderSummaryTotalVsTotalPrice() throws {
        let jsonTotal = """
        {"_id":"o1","total":10.5}
        """.data(using: .utf8)!
        let a = try decoder.decode(OrderSummaryDTO.self, from: jsonTotal)
        XCTAssertEqual(a.resolvedTotal(), 10.5)

        let jsonTotalPrice = """
        {"_id":"o2","totalPrice":20}
        """.data(using: .utf8)!
        let b = try decoder.decode(OrderSummaryDTO.self, from: jsonTotalPrice)
        XCTAssertEqual(b.resolvedTotal(), 20)

        let jsonBoth = """
        {"_id":"o3","total":1,"totalPrice":2}
        """.data(using: .utf8)!
        let c = try decoder.decode(OrderSummaryDTO.self, from: jsonBoth)
        XCTAssertEqual(c.resolvedTotal(), 2)
    }

    func testLocalizedTextPick() {
        let t = LocalizedText(uz: "u", ru: "r", en: "e")
        XCTAssertEqual(t.pick(languageCode: "ru"), "r")
        XCTAssertEqual(t.pick(languageCode: "uz"), "u")
        XCTAssertEqual(t.pick(languageCode: "en"), "e")
        XCTAssertEqual(t.pick(languageCode: "de"), "e")
    }
}
