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
        let equations = [Equation(left: .A, type: .add, right: .B, result: 2),
                         Equation(left: .C, type: .multiply, right: .B, result: 6),
                         Equation(left: .B, type: .subtract, right: .A, result: 1)]
        let complexity = PlainPuzzleSolver.solve(equations: equations, difficulty: .easy)
        XCTAssert(complexity == 1)
    }
    
    func testUnsolvablePuzzle() {
        let equations = [Equation(left: .A, type: .add, right: .B, result: 3),
                         Equation(left: .B, type: .add, right: .C, result: 3),
                         Equation(left: .C, type: .add, right: .A, result: 3)]
        let complexity = PlainPuzzleSolver.solve(equations: equations, difficulty: .easy)
        XCTAssert(complexity == nil)
    }
}
