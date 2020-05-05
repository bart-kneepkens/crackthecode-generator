//
//  main.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 05/05/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import Cocoa

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

enum StatementType: String {
    case add = "+"
    case subtract = "-"
    case multiply = "x"
}

enum Lock: String {
    case A
    case B
    case C
    case D
    case E
    case F
}

let ALL_LOCKS: [Lock] = [.A, .B, .C, .D, .E, .F]
let ALL_STATEMENT_TYPES: [StatementType] = [.add, .subtract, .multiply]

func solve(statements: Set<Statement>, possibilities: Int) -> [Lock: Set<Int>]?{
    let possibleValues = Set(0..<possibilities)
    var possibleAnswers: [Lock: Set<Int>] = [:]
    
    for lock in ALL_LOCKS.prefix(upTo: possibilities - 1) {
        possibleAnswers[lock] = possibleValues
    }
    
    var isDone = false
    
    while !isDone {
        let initialPossible = possibleAnswers
        
        for statement in statements {
            //            print(statement)
            var newRight: Set<Int> =  []
            var newLeft: Set<Int> = []
            
            for num in possibleAnswers[statement.left]! {
                let rightNums = possibleAnswers[statement.right]!.filter({ num + $0 == statement.result })
                if rightNums.count > 0 {
                    rightNums.forEach({ newRight.insert($0) })
                }
            }
            
            for num in possibleAnswers[statement.right]! {
                let leftNums = possibleAnswers[statement.left]!.filter({ num + $0 == statement.result })
                if leftNums.count > 0 {
                    leftNums.forEach({ newLeft.insert($0) })
                }
            }
            
            possibleAnswers[statement.right]! = possibleAnswers[statement.right]!.intersection(newRight)
            possibleAnswers[statement.left]! = possibleAnswers[statement.left]!.intersection(newLeft)
        }
        
        // Nothing changed this time around, meaning there are multiple answers.
        if initialPossible == possibleAnswers {
            return nil
        }
        
        var kut = true
        for answer in possibleAnswers {
            if answer.value.count > 1 {
                kut = false
            }
        }
        
        
        isDone = kut
    }
    
    return possibleAnswers
}

func generateRandomStatements(for sequence: [Lock: Int]) -> Set<Statement> {
    var generatedStatements = Set<Statement>()
    let possibleLocks: Set<Lock> = Set(ALL_LOCKS.prefix(upTo: sequence.count))
    
    while(generatedStatements.count < sequence.count) {
        let leftLock = possibleLocks.randomElement()!
        let rightLock = possibleLocks.filter({ $0 != leftLock }).randomElement()!
        
        let leftValue = sequence[leftLock]!
        let rightValue = sequence[rightLock]!
        
        let type = [StatementType.add].randomElement()!
        
        var result = 0
        
        switch type {
        case .add: result = leftValue + rightValue
        default: result = -1
        }
        
        
        let newStatement = Statement(left: leftLock, right: rightLock, result: result, type: type)
        
        guard !generatedStatements.contains(where: { $0 == newStatement }) else { continue }
        
        generatedStatements.insert(newStatement)
    }
    
    return generatedStatements
}

func generateRandomSequence(withLength length: Int) -> [Lock: Int] {
    let locks: [Lock] = Array(ALL_LOCKS.prefix(upTo: length))
    let maxValue = length
    var sequence: [Lock: Int] = [:]
    
    for lock in locks {
        let randomValue = Array(0...maxValue).randomElement() ?? -1
        sequence[lock] = randomValue
    }
    
    return sequence
}

var hits = 0

while hits < 15 {
    let randomSequence = generateRandomSequence(withLength: 6)
    
    let randomStatements = generateRandomStatements(for: randomSequence)
    if let _ = solve(statements: randomStatements, possibilities: 7) {
        
        let sequenceValueStrings = randomSequence.map { key, value -> String in
            return "\(key.rawValue):\(value)"
        }
        
        print("statements \(randomStatements) solve sequence \(sequenceValueStrings)")
        hits += 1
    }
}
