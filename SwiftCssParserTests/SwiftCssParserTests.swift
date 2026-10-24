//
//  SwiftCssParserTests.swift
//  SwiftCssParserTests
//
//  Created by Mango on 2017/6/3.
//  Copyright © 2017年 Mango. All rights reserved.
//

import XCTest
import UIKit
import SwiftCssParser

class SwiftCssParserTests: XCTestCase {
    
    lazy var testSwiftCSS: SwiftCSS = {
        #if SWIFT_PACKAGE
        let testBundle = Bundle.module
        #else
        let testBundle = Bundle(for: SwiftCssParserTests.self)
        #endif
        let cssPath = testBundle.url(forResource: "test", withExtension: "css")
        return SwiftCSS(CssFileURL: cssPath!)
    }()
    
    
    func testParseInt() {
        let width = testSwiftCSS.int(selector: "#View", key: "width")
        XCTAssertTrue(width == 118, "get width")
    }
    
    func testParseDouble() {
        let height = testSwiftCSS.double(selector: "#View", key: "height")
        XCTAssertTrue(height == 120.5, "get height")
    }
    
    func testParseColor() {
        let color1 = testSwiftCSS.color(selector: "#View", key: "color1")
        XCTAssertTrue(color1 == UIColor("#888888"), "get color")
        
        let color2 = testSwiftCSS.color(selector: "#View", key: "color2")
        XCTAssertTrue(color2 == UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1), "get color")
        
        let color3 = testSwiftCSS.color(selector: "#View", key: "color3")
        XCTAssertTrue(color3 == UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 0.5), "get color")
    }
    
    func testParseFont() {
        
        let font1  = testSwiftCSS.font(selector: "#View", key: "font1")
        let font1test = UIFont(name: "Helvetica-Bold", size: 18)
        XCTAssertTrue(font1 == font1test , "get font")
        
        let font2 = testSwiftCSS.font(selector: "#View", key: "font2", fontSize: 14)
        let font2test = UIFont(name: "Cochin", size: 14)
        XCTAssertTrue(font2 == font2test, "get font")
        
    }
    
    func testParseSize() {
        let size = testSwiftCSS.size(selector: "#View", key: "size")
        XCTAssertTrue(size == CGSize(width: 10, height: 10) )
    }
}


extension SwiftCssParserTests {
    private func withCSS(_ contents: String, check: (SwiftCSS) throws -> Void) throws {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString).appendingPathExtension("css")
        try contents.write(to: url, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }
        try check(SwiftCSS(CssFileURL: url))
    }

    func testFixtureIsIncludedInTestBundle() throws {
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle(for: SwiftCssParserTests.self)
        #endif
        let url = try XCTUnwrap(bundle.url(forResource: "test", withExtension: "css"))
        let contents = try String(contentsOf: url, encoding: .utf8)
        XCTAssertTrue(contents.contains("#View"))
        XCTAssertEqual(SwiftCSS(CssFileURL: url).int(selector: "#View", key: "width"), 118)
    }

    func testEmptyFileUsesPublicFallbacks() throws {
        try withCSS("") { css in
            XCTAssertEqual(css.int(selector: "#Missing", key: "width"), 0)
            XCTAssertEqual(css.double(selector: "#Missing", key: "height"), 0)
            XCTAssertEqual(css.string(selector: "#Missing", key: "title"), "")
            XCTAssertEqual(css.size(selector: "#Missing", key: "size"), .zero)
            XCTAssertEqual(css.color(selector: "#Missing", key: "color"), .clear)
            XCTAssertEqual(css.font(selector: "#Missing", key: "font", fontSize: 17), UIFont.systemFont(ofSize: 17))
        }
    }

    func testMissingKeyAndWrongTypeUseFallbacks() {
        XCTAssertEqual(testSwiftCSS.int(selector: "#View", key: "missing"), 0)
        XCTAssertEqual(testSwiftCSS.double(selector: "#View", key: "font2"), 0)
        XCTAssertEqual(testSwiftCSS.string(selector: "#View", key: "width"), "")
        XCTAssertEqual(testSwiftCSS.size(selector: "#View", key: "height"), .zero)
        XCTAssertEqual(testSwiftCSS.color(selector: "#View", key: "width"), .clear)
        XCTAssertEqual(testSwiftCSS.font(selector: "#View", key: "height"), UIFont.systemFont(ofSize: 14))
    }

    func testUnknownFontFallsBackAtRequestedSize() throws {
        try withCSS("#View { \"font\": \"NoSuchFont-353CCB90\"; }") { css in
            XCTAssertEqual(css.font(selector: "#View", key: "font", fontSize: 17), UIFont.systemFont(ofSize: 17))
        }
    }

    func testInvalidHexColorReportsErrorsAndDefault() {
        XCTAssertThrowsError(try UIColor(rgba_throws: "123456")) { error in
            guard case UIColorInputError.missingHashMarkAsPrefix = error else { return XCTFail("Unexpected error: \(error)") }
        }
        XCTAssertThrowsError(try UIColor(rgba_throws: "#GGG")) { error in
            guard case UIColorInputError.unableToScanHexValue = error else { return XCTFail("Unexpected error: \(error)") }
        }
        XCTAssertThrowsError(try UIColor(rgba_throws: "#12345")) { error in
            guard case UIColorInputError.mismatchedHexStringLength = error else { return XCTFail("Unexpected error: \(error)") }
        }
        XCTAssertEqual(UIColor("not-a-color", defaultColor: .red), .red)
    }
}
