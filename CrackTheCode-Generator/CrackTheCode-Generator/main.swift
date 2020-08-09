//
//  main.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 05/05/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import Foundation

/// Generates a set of unique random equations that are true for the given sequence
/// Equations that are returned are guaranteed to not be easily guessable (see Equation.isEasilyGuessable)
/// - Parameters:
///   - sequence: The sequence for which to generate the equations
///   - difficulty: The difficulty for which to generate the equations
/// - Returns: A set of equations that are true for the given sequence and difficulty - one equation for every lock in the equation
func generateRandomEquations(for sequence: [Lock: Int], with difficulty: Difficulty) -> Set<Equation> {
    var generatedEquations = Set<Equation>()
    let possibleLocks: Set<Lock> = Set(difficulty.locks)
    
    while(generatedEquations.count < sequence.count) {
        let leftLock = possibleLocks.randomElement()!
        let rightLock = possibleLocks.filter({ $0 != leftLock }).randomElement()!
        
        let leftValue = sequence[leftLock]!
        let rightValue = sequence[rightLock]!
        
        guard let type = ALL_EQUATION_TYPES.randomElement() else { continue }
        
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

/// Generates a random sequence of lock values - for example A:1, B:1, C:3
/// - Parameter difficulty: The difficulty for which to generate a sequence
/// - Returns: A dictionary with the `Lock` as keys, and its corresponding number as the value
func generateRandomSequence(difficulty: Difficulty) -> [Lock: Int] {
    return difficulty.locks.reduce(into: [Lock: Int]()) {
        $0[$1] = difficulty.possibleLockValues.randomElement()!
    }
}

func run(amount: Int, difficulty: Difficulty) {
    var confirmedPuzzles: [String: Puzzle] = [:]
    
    while confirmedPuzzles.count < amount {
        let randomSequence = generateRandomSequence(difficulty: difficulty)
        
        let sortedSequence = randomSequence.sorted { (lhs, rhs) -> Bool in
            return lhs.key.rawValue < rhs.key.rawValue
        }.map({ $0.value }).map({ String($0) }).joined()
        
        guard confirmedPuzzles[sortedSequence] == nil else {
            continue
        }
        
        let randomEquations = Array(generateRandomEquations(for: randomSequence, with: difficulty))
        
        if let complexity = PlainPuzzleSolver.solve(equations: randomEquations, difficulty: difficulty) {
            guard complexity <= difficulty.maximumComplexity && complexity > difficulty.minimumComplexity else { continue }
            confirmedPuzzles[sortedSequence] = Puzzle(equations: Array(randomEquations), solution: sortedSequence)
        }
    }
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    let dtoHits = confirmedPuzzles.map({ $0.value.dataTransferObject })
    let data = try! encoder.encode(dtoHits)
    
    print(String(bytes: data, encoding: .utf8)!)
}

func printUsage(){
    print("""
Usage:
CrackTheCode-Generator [difficulty] [amount]
Make sure to pipe the output into a json file!
""")
}

let argumentsCount = CommandLine.argc
let arguments = CommandLine.arguments

guard argumentsCount > 2 else {
    printUsage()
    exit(1)
}

guard let difficulty = Difficulty(rawValue: arguments[1]) else {
    print("Please provide either 'easy', 'medium', 'hard', or 'wizard' as a difficulty.")
    exit(1)
}

guard let amount = Int(arguments[2]), amount <= difficulty.maximumPuzzleAmount else {
    print("Please provide a valid number")
    exit(1)
}

run(amount: amount, difficulty: difficulty)
