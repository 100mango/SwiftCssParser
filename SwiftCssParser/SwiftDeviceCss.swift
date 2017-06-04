//
//  SwiftDeviceCss.swift
//  SwiftCssParser
//
//  Created by Mango on 2017/6/4.
//  Copyright © 2017年 Mango. All rights reserved.
//

import UIKit


public let SwiftDeviceCss = SwiftCssStyleSheet.deviceCss()


class SwiftCssStyleSheet {
    
    private enum ScreenSize {
        
        
        case _320_480 //iPhone4 etc.
        case _320_568 //iPhone5 etc.
        case _375_667 //iPhone6 etc.
        case _414_736 //iPhone6 plus etc.
        case _768_1024 //iPad etc.
        case _1024_1366 //iPad Pro
        
    }
    
    static private let screenSize: ScreenSize = {
        
        let screen = UIScreen.main
        let size = UIScreen.main.fixedCoordinateSpace.bounds.size
        
        switch (size.width,size.height) {
            
        case (320,640):
            return ._320_480
        case (320,568):
            return ._320_568
        case (375,667):
            return ._375_667
        case (414,736):
            return ._414_736
        case (768,1024):
            return ._768_1024
        case (1024,1366):
            return ._1024_1366
            
        default:
            print("Warning: Can NOT detect screenModel! bounds: \(screen.bounds) nativeScale: \(screen.nativeScale)")
            return ._375_667 // Default
        }
    }()
    
    static func deviceCss() -> SwiftCSS {
        
        switch self.screenSize {
        case ._320_480:
            return SwiftCSS(CssFileURL: URL.CssURL(name: "iPhone4"))
        case ._320_568:
            return SwiftCSS(CssFileURL: URL.CssURL(name: "iPhone5"))
        case ._375_667:
            return SwiftCSS(CssFileURL: URL.CssURL(name: "iPhone6"))
        case ._414_736:
            return SwiftCSS(CssFileURL: URL.CssURL(name: "iPhone6P"))
        case ._768_1024:
            return SwiftCSS(CssFileURL: URL.CssURL(name: "iPad"))
        case ._1024_1366:
            return SwiftCSS(CssFileURL: URL.CssURL(name: "iPadPro"))
        }
    }
    
}

private extension URL {
    static func CssURL(name:String) -> URL {
        return Bundle.main.url(forResource: name, withExtension: "css")!
    }
}
