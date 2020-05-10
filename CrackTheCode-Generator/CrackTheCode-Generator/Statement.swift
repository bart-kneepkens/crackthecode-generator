//
//  Statement.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 10/05/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

let ALL_STATEMENT_TYPES: [StatementType] = [.add, .subtract, .multiply]

enum StatementType: String, Codable {
    case add = "+"
    case subtract = "-"
    case multiply = "x"
}

struct Statement: CustomStringConvertible, Hashable, Equatable {
    let left: Lock
    let right: Lock
    let result: Int
    let type: StatementType
    
    var description: String {
        return "\(left)\(type.rawValue)\(right)=\(result)"
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.type == rhs.type && Set([lhs.left, lhs.right, rhs.left, rhs.right]).count == 2 && (lhs.result == rhs.result)
    }
}

extension Statement {
    init(_ stringValue: String) {
        let result = String(stringValue[stringValue.index(after: stringValue.firstIndex(of: "=")!)..<stringValue.endIndex])
        let parts = String(stringValue[stringValue.startIndex..<stringValue.index(stringValue.startIndex, offsetBy: String.IndexDistance(3))])
        
        let type = StatementType(rawValue: "\(parts[parts.index(parts.startIndex, offsetBy: 1)])")!
        let lhs = Lock(rawValue: "\(parts[parts.index(parts.startIndex, offsetBy: 0)])".uppercased())!
        let rhs = Lock(rawValue: "\(parts[parts.index(parts.startIndex, offsetBy: 2)])".uppercased())!
        self.init(left: lhs, right: rhs, result: Int(result)!, type: type)
    }
}

extension Statement {
    init(_ dto: StatementDTO) {
        self.left = dto.left ?? .A
        self.right = dto.right ?? .A
        self.result = dto.result ?? -1
        self.type = dto.type ?? .add
    }
    
    func dataTransferObject() -> StatementDTO {
        return StatementDTO(left: self.left, right: self.right, result: self.result, type: self.type)
    }
}

struct StatementDTO: Codable {
    let left: Lock?
    let right: Lock?
    let result: Int?
    let type: StatementType?
}
