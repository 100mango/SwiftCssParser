import XCTest
import SwiftCssParser

final class CssParserCoreTests: XCTestCase {
    private func parse(_ input: String) -> [String: [String: Any]] {
        let parser = CssParser(lexer: CssLexer(input: input))
        parser.parse()
        return parser.outputDic
    }

    func testEmptyInput() {
        XCTAssertTrue(parse("").isEmpty)
        XCTAssertTrue(parse(" \n\t ").isEmpty)
    }

    func testNumericAndStringValues() {
        let values = parse("#View { \"width\": 118; \"offset\": -2.5; \"title\": \"Hello\"; }")["#View"]
        XCTAssertEqual(values?["width"] as? Double, 118)
        XCTAssertEqual(values?["offset"] as? Double, -2.5)
        XCTAssertEqual(values?["title"] as? String, "Hello")
    }

    func testMultipleSelectors() {
        let values = parse("#First { \"value\": 1; }\n#Second { \"value\": 2; }")
        XCTAssertEqual(values.count, 2)
        XCTAssertEqual(values["#First"]?["value"] as? Double, 1)
        XCTAssertEqual(values["#Second"]?["value"] as? Double, 2)
    }

    func testSizeAndFontValues() {
        let values = parse("#View { \"size\": 10 20; \"font\": \"Helvetica-Bold\" 18; }")["#View"]
        XCTAssertEqual(values?["size"] as? [String: Double], ["double1": 10, "double2": 20])
        let font = values?["font"] as? [String: Any]
        XCTAssertEqual(font?["name"] as? String, "Helvetica-Bold")
        XCTAssertEqual(font?["size"] as? Double, 18)
    }

    func testRGBAndAlphaValues() {
        let values = parse("#View { \"opaque\": RGB(10,20,30); \"alpha\": RGB(40,50,60,0.5); }")["#View"]
        let opaque = values?["opaque"] as? (Double, Double, Double, Double)
        XCTAssertEqual(opaque?.0, 10)
        XCTAssertEqual(opaque?.1, 20)
        XCTAssertEqual(opaque?.2, 30)
        XCTAssertEqual(opaque?.3, 1)
        let alpha = values?["alpha"] as? (Double, Double, Double, Double)
        XCTAssertEqual(alpha?.0, 40)
        XCTAssertEqual(alpha?.1, 50)
        XCTAssertEqual(alpha?.2, 60)
        XCTAssertEqual(alpha?.3, 0.5)
    }

    func testRemovingCharacters() {
        XCTAssertEqual("RGB(10,20,30)".removeCharacters(from: "RGB()"), "10,20,30")
    }

    func testEmptySelectorAndFollowingRule() {
        let values = parse("#Empty { } #View { \"width\": 1; }")
        XCTAssertNotNil(values["#Empty"])
        XCTAssertTrue(values["#Empty"]?.isEmpty == true)
        XCTAssertEqual(values["#View"]?["width"] as? Double, 1)
    }

    func testFinalSemicolonIsOptional() {
        let values = parse("#View { \"width\": 1 }")
        XCTAssertEqual(values["#View"]?["width"] as? Double, 1)
    }

    func testDuplicatePropertyUsesLastValue() {
        let values = parse("#View { \"width\": 1; \"width\": 2; }")
        XCTAssertEqual(values["#View"]?["width"] as? Double, 2)
    }

    func testEmptyAndUnicodeStrings() {
        let values = parse("#View { \"empty\": \"\"; \"title\": \"你好 😀\"; }")
        XCTAssertEqual(values["#View"]?["empty"] as? String, "")
        XCTAssertEqual(values["#View"]?["title"] as? String, "你好 😀")
    }
}
