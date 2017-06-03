//
//  SwiftCssParserTests.swift
//  SwiftCssParserTests
//
//  Created by Mango on 2017/6/3.
//  Copyright © 2017年 Mango. All rights reserved.
//

import XCTest
@testable import SwiftCssParser

class SwiftCssParserTests: XCTestCase {
    
    lazy var testSwiftCSS: SwiftCSS = {
        let testBundle = Bundle(for: SwiftCssParserTests.self)
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
}
