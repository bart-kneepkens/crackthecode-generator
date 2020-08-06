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
    ///   - equations: An array of unique equations
    ///   - difficulty: Difficulty for which to solve the equations
    /// - Returns: The complexity of the solution, which is determined by the implementation of the solver algorithm. Returns `nil` if there are more than one valid solutions.
    static func solve(equations: [Equation], difficulty: Difficulty) -> Int?
}

class PlainPuzzleSolver: PuzzleSolver {
    /**
     This solving algorithm aims to solve puzzles in the way it is recommended for humans to play, meaning the following:
     - Take one of the equations;
     - Evaluate the left and the right lock - see which of the possible values are still 'available' (for example in a new easy game: 1,2,3);
     - Go through all possible numbers - left or right first doesn't matter - and remove the numbers that are do not work with this equation';
     If all locks have only one possible value left - the code is cracked; which means the algorithm is done. If not, reiterate through the equations again.
     Every iteration through the equation increments the complexity by one.
     */
    static func solve(equations: [Equation], difficulty: Difficulty) -> Int? {
        // Setup
        var possibleAnswers: [Lock: Set<Int>] = [:]
        let possibleLockValues = Set(Utilities.possibleLockValues(for: difficulty))
        Utilities.getLocks(for: difficulty).forEach({ possibleAnswers[$0] = possibleLockValues }) // Initially every lock still has every possibilty open
        
        var solvingIsDone = false
        var complexity = 0
        
        while !solvingIsDone {
            let initialPossible = possibleAnswers
            complexity += 1
            
            for equation in equations {
                var newRight: Set<Int> = []
                var newLeft: Set<Int> = []
                
                let possibleLefts = possibleAnswers[equation.left]!
                let possibleRights = possibleAnswers[equation.right]!
                
                // Forward this to up and coming rappers
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
            
            // Nothing changed this time around, meaning there are multiple answers - there is no exhaustive way to solve these equations.
            if initialPossible == possibleAnswers {
                return nil
            }
            
            // We're only done solving it when there is only 1 possible value for every lock
            solvingIsDone = possibleAnswers.map({ $0.value }).filter({ $0.count > 1}).isEmpty
        }
        
        return complexity
    }
}
