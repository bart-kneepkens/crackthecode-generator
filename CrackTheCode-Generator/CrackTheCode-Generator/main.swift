//
//  main.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 05/05/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import Foundation

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

func solve(equations: Set<Equation>, difficulty: Difficulty) -> Int? {
    
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
        
        for equation in equations {
            var newRight: Set<Int> =  []
            var newLeft: Set<Int> = []
            
            let possibleLefts = possibleAnswers[equation.left]!
            let possibleRights = possibleAnswers[equation.right]!
            
            func findHits(in set: Set<Int>, with equation: Equation, from number: Int, left: Bool) -> Set<Int> {
                switch equation.type {
                case .add: return set.filter({ number + $0 == equation.result })
                case .subtract: return left ? set.filter({ $0 - number == equation.result }) : set.filter({ number - $0 == equation.result })
                case .multiply: return set.filter({ number * $0 == equation.result })
                }
            }
            
            for num in possibleLefts {
                let rightNums = findHits(in: possibleRights, with: equation, from: num, left: false )
                
                if rightNums.count > 0 {
                    rightNums.forEach({ newRight.insert($0) })
                }
            }
            
            for num in possibleRights {
                let leftNums = findHits(in: possibleLefts, with: equation, from: num, left: true)
                
                if leftNums.count > 0 {
                    leftNums.forEach({ newLeft.insert($0) })
                }
            }
            
            possibleAnswers[equation.right] = possibleRights.intersection(newRight)
            possibleAnswers[equation.left] = possibleLefts.intersection(newLeft)
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

func generateRandomEquations(for sequence: [Lock: Int], with difficulty: Difficulty) -> Set<Equation> {
    var generatedEquations = Set<Equation>()
    let possibleLocks: Set<Lock> = Set(getLocks(for: difficulty))
    
    while(generatedEquations.count < sequence.count) {
        let leftLock = possibleLocks.randomElement()!
        let rightLock = possibleLocks.filter({ $0 != leftLock }).randomElement()!
        
        let leftValue = sequence[leftLock]!
        let rightValue = sequence[rightLock]!
        
        let type = ALL_EQUATION_TYPES.randomElement()!
        
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
        
        let newEquation = Equation(left: leftLock, right: rightLock, result: result, type: type)
        
        guard !newEquation.isEasilyGuessable(with: difficulty) else { continue }
        
        guard !generatedEquations.contains(where: { $0 == newEquation }) else { continue }
        
        generatedEquations.insert(newEquation)
    }
    
    return generatedEquations
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

    while hits.count < amount {
        let randomSequence = generateRandomSequence(difficulty: difficulty)

        let randomEquations = generateRandomEquations(for: randomSequence, with: difficulty)

        let sortedSequence = Array(randomSequence).sorted { (lhs, rhs) -> Bool in
            return lhs.key.rawValue < rhs.key.rawValue
        }.map({ $0.value }).map({ String($0) }).joined()

        guard hits[sortedSequence] == nil else {
            continue
        }

        if let complexity = solve(equations: randomEquations, difficulty: difficulty) {
            guard complexity <= difficulty.maximumComplexity && complexity > difficulty.minimumComplexity else { continue }
            print("working.. \(hits.count) \(sortedSequence) \(complexity)")
            hits[sortedSequence] = Puzzle(equations: Array(randomEquations), answer: sortedSequence)
        }
    }

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    let dtoHits = hits.map({ $0.value.dataTransferObject })
    let data = try! encoder.encode(dtoHits)

    let filename = getDocumentsDirectory().appendingPathComponent("puzzles_\(difficulty.rawValue).json")

    try! data.write(to: filename)
}

run(amount: 26, difficulty: .easy)
//run(amount: 250, difficulty: .medium)
//run(amount: 250, difficulty: .hard)
//run(amount: 250, difficulty: .wizard)
