//
//  main.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 05/05/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import Foundation

func generateRandomEquations(for sequence: [Lock: Int], with difficulty: Difficulty) -> Set<Equation> {
    var generatedEquations = Set<Equation>()
    let possibleLocks: Set<Lock> = Set(Utilities.getLocks(for: difficulty))
    
    while(generatedEquations.count < sequence.count) {
        let leftLock = possibleLocks.randomElement()!
        let rightLock = possibleLocks.filter({ $0 != leftLock }).randomElement()!
        
        let leftValue = sequence[leftLock]!
        let rightValue = sequence[rightLock]!
        
        let type = ALL_EQUATION_TYPES.randomElement()!
        
        // Skip substraction equations where the right value is bigger than the left value
        // Because else the result is below zero
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
    let locks: [Lock] = Utilities.getLocks(for: difficulty)
    
    var sequence: [Lock: Int] = [:]
    
    for lock in locks {
        let randomValue = Array(Utilities.possibleLockValues(for: difficulty)).randomElement() ?? -1
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
        
        if let complexity = PlainPuzzleSolver.solve(equations: randomEquations, difficulty: difficulty) {
            guard complexity <= difficulty.maximumComplexity && complexity > difficulty.minimumComplexity else { continue }
            print("working.. \(hits.count) \(sortedSequence) \(complexity)")
            hits[sortedSequence] = Puzzle(equations: Array(randomEquations), answer: sortedSequence)
        }
    }
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    let dtoHits = hits.map({ $0.value.dataTransferObject })
    let data = try! encoder.encode(dtoHits)
    
    let filename = Utilities.getDocumentsDirectory().appendingPathComponent("puzzles_\(difficulty.rawValue).json")
    
    try! data.write(to: filename)
}

run(amount: 26, difficulty: .easy)
//run(amount: 250, difficulty: .medium)
//run(amount: 250, difficulty: .hard)
//run(amount: 250, difficulty: .wizard)
