//
//  Equation.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 10/05/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

enum StatementType: String, Codable {
    case add = "+"
    case subtract = "-"
    case multiply = "x"
}

struct Equation: CustomStringConvertible, Hashable {
    let left: Lock
    let right: Lock
    let result: Int
    let type: StatementType
    
    
    /// A textual description of the statement, in the format of `a+b=2`
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
        
        let type = StatementType(rawValue: "\(parts[parts.index(parts.startIndex, offsetBy: 1)])")!
        let lhs = Lock(rawValue: "\(parts[parts.index(parts.startIndex, offsetBy: 0)])".uppercased())!
        let rhs = Lock(rawValue: "\(parts[parts.index(parts.startIndex, offsetBy: 2)])".uppercased())!
        self.init(left: lhs, right: rhs, result: Int(result)!, type: type)
    }
}

extension Equation {
    init(_ dto: EquationDTO) {
        self.left = dto.left ?? .A
        self.right = dto.right ?? .A
        self.result = dto.result ?? -1
        self.type = dto.type ?? .add
    }
    
    func dataTransferObject() -> EquationDTO {
        return EquationDTO(left: self.left, right: self.right, result: self.result, type: self.type)
    }
}

/**
 Used to transfer to and from  JSON
 All fields are optional -  this way there is no need to pollute the actual domain type with Codable initializers and CodingKeys.
 */
struct EquationDTO: Codable {
    let left: Lock?
    let right: Lock?
    let result: Int?
    let type: StatementType?
}
