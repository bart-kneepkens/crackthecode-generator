//
//  PuzzleSolverTests.swift
//  CrackTheCode-Generator-Tests
//
//  Created by Bart Kneepkens on 07/08/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import XCTest

class PlainPuzzleSolverTests: XCTestCase {
    func testEasyPuzzle() {
        // This is the first puzzle in Gridlock: Crack The Code, with difficulty .easy
        /*
         {
           "answer" : "123",
           "statements" : [
             "AxB=2",
             "CxB=6",
             "B-A=1"
           ]
         },
         */
        let equations = [Equation("AxB=2"),Equation("CxB=6"),Equation("B-A=1")]
        let complexity = PlainPuzzleSolver.solve(equations: equations, difficulty: .easy)
        XCTAssert(complexity == 1)
    }
    
    func testUnsolvablePuzzle() {
           let equations = [Equation("A+B=3"),Equation("B+C=3"),Equation("C+A=3")]
           let complexity = PlainPuzzleSolver.solve(equations: equations, difficulty: .easy)
           XCTAssert(complexity == nil)
       }
}
