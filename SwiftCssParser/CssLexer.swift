//
//  CssLexer.swift
//  SwiftCssParser
//
//  Created by Mango on 2017/5/30.
//  Copyright © 2017年 Mango. All rights reserved.
//

import Foundation

public class Lexer {
    let input: String
    var currentIndex: String.Index
    var currentCharcter : Character?
    
    public init(input: String) {
        self.input = input
        currentIndex = input.startIndex
        currentCharcter = input.characters.first
    }
    
    public func consume() {
        
        guard currentIndex != input.endIndex else {
            return
        }
        
        currentIndex = input.index(after: currentIndex)
        if currentIndex == self.input.endIndex {
            currentCharcter = nil
        }else{
            currentCharcter = self.input[currentIndex]
        }
    }
}

