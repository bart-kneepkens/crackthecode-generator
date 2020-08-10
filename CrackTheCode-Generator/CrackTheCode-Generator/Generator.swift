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
        var confirmedPuzzles: [String: Puzzle] = [:]
        
        while confirmedPuzzles.count < amount {
            let randomSequence = generateRandomSequence(difficulty: difficulty)
            
            let sequenceString = randomSequence.stringRepresentation
            
            guard confirmedPuzzles[sequenceString] == nil else {
                continue
            }
            
            let randomEquations = Array(generateRandomEquations(for: randomSequence, with: difficulty))
            
            if let complexity = PlainPuzzleSolver.solve(equations: randomEquations, difficulty: difficulty) {
                guard complexity <= difficulty.maximumComplexity && complexity > difficulty.minimumComplexity else { continue }
                confirmedPuzzles[sequenceString] = Puzzle(equations: Array(randomEquations), solution: sequenceString)
            }
        }
        
        return confirmedPuzzles.map({ $0.value })
    }
    
    /// Generates a set of unique random equations that are true for the given sequence
    /// Equations that are returned are guaranteed to not be easily guessable (see Equation.isEasilyGuessable)
    /// - Parameters:
    ///   - sequence: The sequence for which to generate the equations
    ///   - difficulty: The difficulty for which to generate the equations
    /// - Returns: A set of equations that are true for the given sequence and difficulty - one equation for every lock in the equation
    fileprivate func generateRandomEquations(for sequence: Sequence, with difficulty: Difficulty) -> Set<Equation> {
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
    fileprivate func generateRandomSequence(difficulty: Difficulty) -> Sequence {
        return difficulty.locks.reduce(into: Sequence()) {
            $0[$1] = difficulty.possibleLockValues.randomElement()!
        }
    }

    
}