//
//  CssParser.swift
//  SwiftCssParser
//
//  Created by Mango on 2017/6/3.
//  Copyright © 2017年 Mango. All rights reserved.
//

import Foundation

public class CssParser {
    let lexer: CssLexer
    lazy var lookaheads: [Token?] = Array(repeating: nil, count: self.k)
    let k = 6 //LL(6)
    var index = 0 //circular index of next token position to fill
    typealias Token = CssLexer.Token
    
    public var outputDic = [String:[String:Any]]()
    
    public init(lexer: CssLexer) {
        self.lexer = lexer
        
        for _ in 1...k {
            consume()
        }
    }
    
    private var consumedToken = [Token]()
    func consume() {
        
        lookaheads[index] = lexer.nextToken()
        index = (index + 1) % k
        
        //for debug
        if let token =  lookaheads[index] {
            consumedToken.append(token)
        }
    }
    
    // form 1 to k
    func lookaheadToken(_ index: Int) -> Token? {
        let circularIndex = (self.index + index - 1) % k
        return lookaheads[circularIndex]
    }
    
    @discardableResult func match(token: Token) -> Token {
        
        guard let lookaheadToken = lookaheadToken(1) else {
            fatalError("lookahead token is nil")
        }
        guard lookaheadToken.type == token.type else {
            fatalError("expecting (\(token.type)) but found (\(lookaheadToken) consumedTokens: \(consumedToken))")
        }
        consume()
        return lookaheadToken
    }
    
}

//MARK: Rules
extension CssParser {
    
    func element(selector: String ) {
        
        guard var selectorDic = outputDic[selector] else {
            fatalError("\(selector) dic not found")
        }
        
        let key = match(token: .string(""))
        match(token: .colon)
        
        guard let currentToken = lookaheadToken(1) else {
            fatalError("lookahead token is nil")
        }
        
        switch currentToken {
        case let .double(value):
            
            guard let token2 = lookaheadToken(2) else {
                fatalError("token2 is nil")
            }
            switch token2 {
            case let .double(double):
                // key : double double;
                match(token: currentToken)
                match(token: token2)
                selectorDic[key.description] = ["double1":value,"double2":double]
            default:
                // normal double
                match(token: currentToken)
                selectorDic[key.description] = value
            }
        
        case let .string(value):
            //LL(2)
            guard let token2 = lookaheadToken(2) else {
                fatalError("token2 is nil")
            }
            
            switch token2 {
            case let .double(double):
                //key : name double
                match(token: currentToken)
                match(token: token2)
                selectorDic[key.description] = ["name":value,"size":double]
            default:
                //normal string
                match(token: currentToken)
                selectorDic[key.description] = value
            }
        case let .rgb(r,g,b,a):
            match(token: currentToken)
            selectorDic[key.description] = (r,g,b,a)
        default:
            break
        }
        
        outputDic[selector] = selectorDic
    }
    
    func elements(selector: String) {
        element(selector: selector)
        while let lookaheadToken = lookaheadToken(1), lookaheadToken.type ==
            Token.semicolon.type {
                match(token: .semicolon)
                
                //if current token is "}", it means elements rule is parsed.
                if let currentToken = self.lookaheadToken(1), currentToken.type == Token.rightBrace.type {
                    return
                }
                element(selector: selector)
        }
    }
    
    func selector() {
        let selector = match(token: .selector(""))
        let dic = [String:Int]()
        outputDic[selector.description] = dic
        
        match(token: .leftBrace)
        elements(selector: selector.description)
        match(token: .rightBrace)
    }
    
    func css() {
        
        while lookaheadToken(1) != nil {
            selector()
        }
    }
    
    public func parse() {
        css()
    }
    
}
