//
//  Equation.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 10/05/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import Foundation

let ALL_EQUATION_TYPES: [EquationType] = [.add, .subtract, .multiply]

enum EquationType: String, Codable {
    case add = "+"
    case subtract = "-"
    case multiply = "x"
}

struct Equation: CustomStringConvertible, Hashable {
    let left: Lock
    let type: EquationType
    let right: Lock
    let result: Int
    
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
    init?(_ stringValue: String){
        guard stringValue.count >= 5 else { return nil }
        
        if let expression = try? NSRegularExpression(pattern: "^(?<left>.)(?<operator>\\+|-|x)(?<right>.)=(?<result>.*)") {
            guard let match = expression.firstMatch(in: stringValue, range: NSRange(location: 0, length: stringValue.count)), match.numberOfRanges == 5 else { return nil }
            let characters = Array(stringValue) // To circumvent Swift's string indexing - because you can be sure it's utf8
            
            guard
                let left = Lock(rawValue: String(characters[match.range(withName: "left").location]).uppercased()),
            let equationType = EquationType(rawValue: String(characters[match.range(withName: "operator").location])),
            let right = Lock(rawValue: String(characters[match.range(withName: "right").location]).uppercased()),
            let result = Int(String(characters[match.range(withName: "result").location]))
                else { return nil }
            
            self.init(left: left, type: equationType, right: right, result: result)
            return
        }

        return nil
    }
}

extension Equation {
    /// Returns true if the equation is obviously easy to solve.
    /// An equation is easy to solve if there is only one combination of numbers that fulfill it.
    /// For example, the equation `a+b=6` with possibilites of numbers 1 to 3; the only solution being when both `a` and `b` have value 3.
    /// For example, the equation `a*b=9` with possibilites of numbers 0 to 9; the only possible solution being when both `a` and `b` are have value 3.
    /// The aim is of this method is not to be absolute - there may still be cases that are easy to solve - but mostly in the `easy` difficulty due to the lack of zeroes.
    /// - Parameter difficulty: The difficulty that is associated with this equation
    /// - Returns: `true` if this equation is obviously easy to solve
    func isEasilyGuessable(with difficulty: Difficulty) -> Bool {
        if self.type == .add {
            let range = difficulty.possibleLockValues
              return self.result == (range.upperBound * 2)
          }
          
        // Possible equations that are `multiply` and easy to guess are the ones that are composed of a square, where the square is the only solution (1x1, 3x3 etc) with a grid of numbers 0...6
        // Note that 2x2 isn't part of the gang because 1x4 or 4x1 also works
          if self.type == .multiply {
              let number = self.result
              let squareRoot = sqrt(Double(number))
              return [1.0, 3.0, 4.0, 5.0, 6.0].contains(squareRoot)
          }
          
          return false
    }
}
