//
//  PuzzleSolver.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 06/08/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import Foundation

protocol PuzzleSolver {
    /// Attempts to solve a given set of equations using only the possible values for the given difficulty.
    /// For example, for an easy game, numbers 1-3 will be used, and for all other difficulties 0-6 will be used.
    /// - Parameters:
    ///   - equations: A set of unique equations
    ///   - difficulty: Difficulty for which to solve the equations
    /// - Returns: The complexity of the solution, which is determined by the implementation of the solver algorithm. Returns `nil` if there are more than one valid solutions.
    static func solve(equations: Set<Equation>, difficulty: Difficulty) -> Int?
}

class PlainPuzzleSolver: PuzzleSolver {
    static func solve(equations: Set<Equation>, difficulty: Difficulty) -> Int? {
        let values = Utilities.possibleLockValues(for: difficulty)
        var possibleAnswers: [Lock: Set<Int>] = [:]
        
        for lock in Utilities.getLocks(for: difficulty) {
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
    
    
}
