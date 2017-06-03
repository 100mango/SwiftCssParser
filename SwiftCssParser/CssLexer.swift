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


public class CssLexer: Lexer {
    
    public enum Token: CustomStringConvertible {
        case string(String)
        case selector(String)
        case double(Double)
        case rgb(Double,Double,Double,Double)
        case font(String,Double)
        case leftBrace  //{
        case rightBrace  //}
        case colon  //:
        case semicolon //;
        
        public var description: String {
            switch self {
            case let .string(string):
                return string
            case let .selector(selector):
                return selector
            case let .double(double):
                return String(double)
            case let .rgb(r,g,b,a):
                return "RGB(\(r),\(g),\(b),\(a))"
            case let .font(name,size):
                return "Font:\(name) size:\(size)"
            case .leftBrace:
                return "{"
            case .rightBrace:
                return "}"
            case .colon:
                return ":"
            case .semicolon:
                return ";"
            }
        }
        
        var type: String {
            switch self {
            case .string(_):
                return "StringType"
            case .selector(_):
                return "SelectorType"
            case .double(_):
                return "DoubleType"
            case .rgb(_, _, _, _):
                return "RGBType"
            case .font(_, _):
                return "FontType"
            default:
                return description
            }
        }
    }
    
    enum inputWrong: Error, CustomStringConvertible {
        case InvaidCharacter(Character)
        
        var description: String {
            switch self {
            case let .InvaidCharacter(character):
                return "Invalid character " + String(character)
            }
        }
    }
}

func ~=(pattern: (Character) -> Bool , value: Character) -> Bool {
    return pattern(value)
}

//MARK: Generate Tokens
extension CssLexer {
    
    func nextToken() -> Token? {
        
        
        var consumedChars = [Character]()
        while let currentCharcter = self.currentCharcter {
            
            switch currentCharcter {
            case isSpace:
                self.consume()
            case isSelector:
                return combineSelector()
            case isLetter:
                return combineLetter()
            case isNumber:
                return combineNumber()
            case isRGB:
                return combineRGB()
            case ":":
                consume()
                return .colon
            case "{":
                consume()
                return .leftBrace
            case "}":
                consume()
                return .rightBrace
            case ";":
                consume()
                return .semicolon
            default:
                fatalError("\(inputWrong.InvaidCharacter(currentCharcter)) Consumued:\(consumedChars)")
            }
            consumedChars.append(currentCharcter)
        }
        
        return nil
    }




    func isSpace(char: Character) -> Bool {
        let string = String(char)
        let result = string.rangeOfCharacter(from: .whitespacesAndNewlines)
        return result != nil
    }
    
    func isLetter(char: Character) -> Bool {
        if char == "\"" {
            return true
        } else {
            return false
        }
    }
    
    func isAToZ(char: Character) -> Bool {
        if char >= "a" && char <= "z" || char >= "A" && char <= "Z" {
            return true
        }else{
            return false
        }
    }
    
    func combineLetter() -> Token {
        self.consume() //吃掉"
        var string = ""
        while let next = self.currentCharcter , next != "\"" {
            string += String(next)
            self.consume()
        }
        self.consume() //吃掉"
        return .string(string)
    }
    
    func isSelector(char: Character) -> Bool {
        return char == "#"
    }
    
    func combineSelector() -> Token {
        var string = String(self.currentCharcter!)
        self.consume()
        while let next = self.currentCharcter , isAToZ(char: next) {
            string += String(next)
            self.consume()
        }
        return .selector(string)
    }
    
    func isNumber(char: Character) -> Bool {
        if (char >= "0" && char <= "9") || char == "." || char == "-" {
            return true
        } else {
            return false
        }
    }
    
    func combineNumber() -> Token {
        var string = String(self.currentCharcter!)
        self.consume()
        while let next = self.currentCharcter , isNumber(char: next) {
            string += String(next)
            self.consume()
        }
        
        if let double = Double(string) {
            return .double(double)
        } else {
            fatalError("Generate Number wrong with \(string)")
        }
        
    }
    
    func isRGB(char: Character) -> Bool {
        if char == "R" {
            return true
        } else {
            return false
        }
    }
    
    func combineRGB() -> Token {
        var string = ""
        while let next = self.currentCharcter {
            string += String(next)
            self.consume()
            
            if next == ")" {
                break
            }
        }
        
        string = string.removeCharacters(from: "RGB()")
        let values = string.components(separatedBy: ",")
        if values.count == 3 {
            return Token.rgb(Double(values[0])!, Double(values[1])!, Double(values[2])!, 1)
        } else if values.count == 4 {
            return Token.rgb(Double(values[0])!, Double(values[1])!, Double(values[2])!, Double(values[3])!)
        } else {
            fatalError("Invalid RGB value with \(string)")
        }
        
    }
    
}


extension String {
    
    public func removeCharacters(from forbiddenChars: CharacterSet) -> String {
        let passed = self.unicodeScalars.filter { !forbiddenChars.contains($0) }
        return String(String.UnicodeScalarView(passed))
    }
    
    public func removeCharacters(from: String) -> String {
        return removeCharacters(from: CharacterSet(charactersIn: from))
    }
}
