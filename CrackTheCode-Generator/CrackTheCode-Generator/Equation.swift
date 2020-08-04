//
//  Equation.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 10/05/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//
let ALL_EQUATION_TYPES: [EquationType] = [.add, .subtract, .multiply]

enum EquationType: String, Codable {
    case add = "+"
    case subtract = "-"
    case multiply = "x"
}

struct Equation: CustomStringConvertible, Hashable {
    let left: Lock
    let right: Lock
    let result: Int
    let type: EquationType
    
    
    /// A textual description of the equation in the format of `a+b=2`
    var description: String {
        return "\(left)\(type.rawValue)\(right)=\(result)"
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        /*
         Equations are considered equal when:
         - Its type is the same;
         - The left and right locks match;
         - The results are equal
         */
        return lhs.type == rhs.type && Set([lhs.left, lhs.right, rhs.left, rhs.right]).count == 2 && (lhs.result == rhs.result)
    }
}

extension Equation {
    /// Initializer using a string, typically from a serialized source
    /// - Parameter stringValue: a string in the format of `a+b=2`
    init(_ stringValue: String) {
        let result = String(stringValue[stringValue.index(after: stringValue.firstIndex(of: "=")!)..<stringValue.endIndex])
        let parts = String(stringValue[stringValue.startIndex..<stringValue.index(stringValue.startIndex, offsetBy: String.IndexDistance(3))])
        
        let type = EquationType(rawValue: "\(parts[parts.index(parts.startIndex, offsetBy: 1)])")!
        let lhs = Lock(rawValue: "\(parts[parts.index(parts.startIndex, offsetBy: 0)])".uppercased())!
        let rhs = Lock(rawValue: "\(parts[parts.index(parts.startIndex, offsetBy: 2)])".uppercased())!
        self.init(left: lhs, right: rhs, result: Int(result)!, type: type)
    }
}
