//
//  PuzzleSolverTests.swift
//  CrackTheCode-Generator-Tests
//
//  Created by Bart Kneepkens on 07/08/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import XCTest

class PlainPuzzleSolverTests: XCTestCase {
    func testSanity() {
        
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
}
