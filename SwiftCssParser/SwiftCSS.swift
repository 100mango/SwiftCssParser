//
//  SwiftCSS.swift
//  SwiftCssParser
//
//  Created by Mango on 2017/6/3.
//  Copyright © 2017年 Mango. All rights reserved.
//

import UIKit

public class SwiftCSS {
    
    private let parsedCss: [String:[String:Any]]
    
    public init(CssFileURL: URL) {
        let content = try! String(contentsOf: CssFileURL, encoding: .utf8)
        let lexer = CssLexer(input: content)
        let parser = CssParser(lexer: lexer)
        parser.parse()
        parsedCss = parser.outputDic
    }
    
    
    public func int(selector: String, key: String) -> Int {
        
        return Int(double(selector: selector, key: key))
    }
    
    public func double(selector: String, key: String) -> Double {
        return value(selector: selector, key: key) ?? 0
    }
    
    public func string(selector: String, key: String) -> String {
        return value(selector: selector, key: key) ?? ""
    }
    
    public func size(selector: String, key: String) -> CGSize {
        
        guard let dic: [String:Double] = value(selector: selector, key: key),
            let double1 = dic["double1"], let double2 = dic["double2"] else {
            return CGSize(width: 0, height: 0)
        }
        
        return CGSize(width: double1, height: double2)
        
    }
    
    
    public func color(selector: String, key: String) -> UIColor {
        
        if let rgb:(Double,Double,Double,Double) = value(selector: selector, key: key) {
            return UIColor(red: CGFloat(rgb.0/255), green: CGFloat(rgb.1/255), blue: CGFloat(rgb.2/255), alpha: CGFloat(rgb.3))
        } else {
            return UIColor(string(selector: selector, key: key))
        }
        
    }
    
    public func font(selector: String, key: String, fontSize: CGFloat = 14) -> UIFont {
        
        if let name: String = value(selector: selector, key: key) {
            
            return UIFont(name: name, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
            
        } else if let dic: [String:Any] = value(selector: selector, key: key) {
            
            guard let name = dic["name"] as? String ,let size = dic["size"] as? Double else {
                return UIFont.systemFont(ofSize: fontSize)
            }
            return UIFont(name: name, size: CGFloat(size)) ?? UIFont.systemFont(ofSize: fontSize)
            
        } else {
            return UIFont.systemFont(ofSize: fontSize)
        }
    }
    
    private func value<T>(selector: String, key: String) -> T? {
        guard let dic = parsedCss[selector] else {
            return nil
        }
        guard let value = dic[key] as? T else {
            return nil
        }
        
        return value
    }
    
}
