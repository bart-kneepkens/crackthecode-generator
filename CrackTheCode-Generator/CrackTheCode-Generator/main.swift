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
            var newRight: Set<Int> =  []
            var newLeft: Set<Int> = []
            
            let possibleLefts = possibleAnswers[statement.left]!
            let possibleRights = possibleAnswers[statement.right]!
            
            func findHits(in set: Set<Int>, with statement: Statement, from number: Int, left: Bool) -> Set<Int> {
                switch statement.type {
                case .add: return set.filter({ number + $0 == statement.result })
                case .subtract: return left ? set.filter({ $0 - number == statement.result }) : set.filter({ number - $0 == statement.result })
                case .multiply: return set.filter({ number * $0 == statement.result })
                }
            }
            
            for num in possibleLefts {
                let rightNums = findHits(in: possibleRights, with: statement, from: num, left: false )
                
                if rightNums.count > 0 {
                    rightNums.forEach({ newRight.insert($0) })
                }
            }
            
            for num in possibleRights {
                let leftNums = findHits(in: possibleLefts, with: statement, from: num, left: true)
                
                if leftNums.count > 0 {
                    leftNums.forEach({ newLeft.insert($0) })
                }
            }
            
            possibleAnswers[statement.right] = possibleRights.intersection(newRight)
            possibleAnswers[statement.left] = possibleLefts.intersection(newLeft)
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
        
        let type = [StatementType.subtract, StatementType.add, StatementType.multiply].randomElement()!
        
        // skip
        if type == .subtract && rightValue > leftValue {
            continue
        }
        
        var result = 0
        
        switch type {
        case .add: result = leftValue + rightValue
        case .subtract: result = leftValue - rightValue
        case .multiply: result = leftValue * rightValue
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
        let sortedSequence = Array(randomSequence).sorted { (lhs, rhs) -> Bool in
            return lhs.key.rawValue < rhs.key.rawValue
        }.map({ $0.value }).map({ String($0) }).joined()
        
        print("\(randomStatements) solve sequence \(sortedSequence)")
        hits += 1
    }
}

//print(solve(statements: Set([
//    Statement(left: .B, right: .A, result: 6, type: .add),
//    Statement(left: .E, right: .B, result: 5, type: .add),
//    Statement(left: .C, right: .D, result: 2, type: .subtract),
//    Statement(left: .C, right: .F, result: 0, type: .subtract),
//    Statement(left: .E, right: .C, result: 8, type: .add),
//    Statement(left: .F, right: .B, result: 3, type: .subtract),
//]), possibilities: 7))
