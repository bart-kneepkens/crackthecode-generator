//
//  main.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 05/05/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import Cocoa

enum Difficulty: Int {
    case easy
    case medium
    case hard
}

extension Difficulty {
    var maximumComplexity: Int {
        switch self {
        case .easy: return Int.max
        case .medium: return 3
        case .hard: return Int.max
        }
    }
}

func isEasilyGuessable(_ statement: Statement, with difficulty: Difficulty) -> Bool {
    
    if statement.type == .add {
        let range = possibleValues(for: difficulty)
        return statement.result == (range.upperBound * 2)
    }
    
    if statement.type == .multiply {
        let number = statement.result
        let squareRoot = sqrt(Double(number))
        return [1.0, 5.0, 3.0, 4.0, 5.0, 6.0].contains(squareRoot)
    }
    
    return false
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func getLocks(for difficulty: Difficulty) -> [Lock] {
    if difficulty == .easy {
        return [.A, .B, .C]
    }
    return ALL_LOCKS
}

func possibleValues(for difficulty: Difficulty) -> ClosedRange<Int> {
    if difficulty == .easy {
        return 1...3
    }
    return 0...6
}

func solve(statements: Set<Statement>, difficulty: Difficulty) -> Int? {
    
    let values = possibleValues(for: difficulty)
    var possibleAnswers: [Lock: Set<Int>] = [:]
    
    for lock in getLocks(for: difficulty) {
        possibleAnswers[lock] = Set(values)
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

func generateRandomStatements(for sequence: [Lock: Int], with difficulty: Difficulty) -> Set<Statement> {
    var generatedStatements = Set<Statement>()
    let possibleLocks: Set<Lock> = Set(getLocks(for: difficulty))
    
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
        
        guard !isEasilyGuessable(newStatement, with: difficulty) else { continue }
        
        guard !generatedStatements.contains(where: { $0 == newStatement }) else { continue }
        
        generatedStatements.insert(newStatement)
    }
    
    return generatedStatements
}

func generateRandomSequence(difficulty: Difficulty) -> [Lock: Int] {
    let locks: [Lock] = getLocks(for: difficulty)
    
    var sequence: [Lock: Int] = [:]

    for lock in locks {
        let randomValue = Array(possibleValues(for: difficulty)).randomElement() ?? -1
        sequence[lock] = randomValue
    }
    
    return sequence
}

func run(amount: Int, difficulty: Difficulty) {
    var hits: [String: Puzzle] = [:]
    
//    let magicNumber = difficulty == .easy ? 3 : 6

    while hits.count < amount {

        let randomSequence = generateRandomSequence(difficulty: difficulty)

        let randomStatements = generateRandomStatements(for: randomSequence, with: difficulty)

        let sortedSequence = Array(randomSequence).sorted { (lhs, rhs) -> Bool in
            return lhs.key.rawValue < rhs.key.rawValue
        }.map({ $0.value }).map({ String($0) }).joined()

        guard hits[sortedSequence] == nil else {
            continue
        }

        if let complexity = solve(statements: randomStatements, difficulty: difficulty) {

            guard complexity <= difficulty.maximumComplexity else { continue }

            print("working.. \(hits.count) \(sortedSequence) \(complexity)")
            hits[sortedSequence] = Puzzle(statements: Array(randomStatements), answer: sortedSequence)
        }
    }

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    let dtoHits = hits.map({ $0.value.dataTransferObject() })
    let data = try! encoder.encode(dtoHits)

    print(String(data: data, encoding: .utf8)!)

    let filename = getDocumentsDirectory().appendingPathComponent("puzzles_88.json")

    try! data.write(to: filename)
}

run(amount: 5000, difficulty: .medium)
