//
//  main.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 05/05/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import Cocoa

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func solve(statements: Set<Statement>, possibilities: Int) -> Int?{
    let possibleValues = Set(0..<possibilities)
    var possibleAnswers: [Lock: Set<Int>] = [:]
    
    for lock in ALL_LOCKS.prefix(upTo: possibilities - 1) {
        possibleAnswers[lock] = possibleValues
    }
    
    var isDone = false
    
    var complexity = 0
    
    while !isDone {
        let initialPossible = possibleAnswers
        complexity += 1
        
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
    
    return complexity
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

var hits: [Puzzle] = []

while hits.count < 10 {
    let randomSequence = generateRandomSequence(withLength: 6)

    let randomStatements = generateRandomStatements(for: randomSequence)
    if let complexity = solve(statements: randomStatements, possibilities: 7) {

        guard complexity == 1 else { continue }
        let sortedSequence = Array(randomSequence).sorted { (lhs, rhs) -> Bool in
            return lhs.key.rawValue < rhs.key.rawValue
        }.map({ $0.value }).map({ String($0) }).joined()

//        print("\(randomStatements) solve sequence \(sortedSequence) with complexity \(complexity)")
        print("working..")
        hits.append(Puzzle(statements: Array(randomStatements), answer: sortedSequence))
    }
}

let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted

let dtoHits = hits.map({ $0.dataTransferObject() })
let data = try! encoder.encode(dtoHits)

print(String(data: data, encoding: .utf8)!)

let filename = getDocumentsDirectory().appendingPathComponent("ecco2k.json")

try! data.write(to: filename)
