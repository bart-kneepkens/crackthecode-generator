//
//  Generator.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 10/08/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import Foundation

class Generator {
    func generatePuzzles(amount: Int, difficulty: Difficulty) -> [Puzzle] {
        var confirmedPuzzles: [String: Puzzle] = [:] // Solution: Puzzle
        
        while confirmedPuzzles.count < amount {
            let randomSequence = generateRandomSequence(difficulty: difficulty)
            let solution = randomSequence.stringRepresentation
            
            guard confirmedPuzzles[solution] == nil else {
                continue
            }
            
            let randomEquations = generateRandomEquations(for: randomSequence, with: difficulty)
            
            if let complexity = PlainPuzzleSolver.solve(equations: randomEquations, difficulty: difficulty) {
                guard complexity <= difficulty.maximumComplexity && complexity > difficulty.minimumComplexity else { continue }
                confirmedPuzzles[solution] = Puzzle(equations: randomEquations, solution: solution)
            }
        }
        
        return Array(confirmedPuzzles.values)
    }
    
    /// Generates a set of unique random equations that are true for the given sequence
    /// Equations that are returned are guaranteed to not be easily guessable (see Equation.isEasilyGuessable)
    /// - Parameters:
    ///   - sequence: The sequence for which to generate the equations
    ///   - difficulty: The difficulty for which to generate the equations
    /// - Returns: An array of equations that are true for the given sequence and difficulty - one equation for every lock in the equation
    internal func generateRandomEquations(for sequence: Sequence, with difficulty: Difficulty) -> [Equation] {
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
            
            let newEquation = Equation(left: leftLock, type: type, right: rightLock, result: result)
            
            guard !newEquation.isEasilyGuessable(with: difficulty), !generatedEquations.contains(newEquation) else { continue }
            
            generatedEquations.insert(newEquation)
        }
        
        return Array(generatedEquations)
    }

    /// Generates a random sequence of lock values - for example A:1, B:1, C:3
    /// - Parameter difficulty: The difficulty for which to generate a sequence
    /// - Returns: A dictionary with the `Lock` as keys, and its corresponding number as the value
    internal func generateRandomSequence(difficulty: Difficulty) -> Sequence {
        return difficulty.locks.reduce(into: Sequence()) {
            $0[$1] = difficulty.possibleLockValues.randomElement()!
        }
    }

    
}
