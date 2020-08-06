//
//  EquationTests.swift
//  CrackTheCode-Generator-Tests
//
//  Created by Bart Kneepkens on 06/08/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import XCTest

class IsEasilyGuessableTests: XCTestCase {
    func testAddEquationUpperBoundsEasy() {
        let equation = Equation("a+b=6")
        XCTAssert(equation.isEasilyGuessable(with: .easy))
        XCTAssert(!equation.isEasilyGuessable(with: .medium))
        XCTAssert(!equation.isEasilyGuessable(with: .hard))
        XCTAssert(!equation.isEasilyGuessable(with: .wizard))
    }
    
    func testAddEquationUpperBounds() {
        let equation = Equation("a+b=5")
        XCTAssert(!equation.isEasilyGuessable(with: .easy))
        XCTAssert(!equation.isEasilyGuessable(with: .medium))
        XCTAssert(!equation.isEasilyGuessable(with: .hard))
        XCTAssert(!equation.isEasilyGuessable(with: .wizard))
    }
    
    func testAddEquationUpperBoundsMediumAndAbove() {
        let equation = Equation("a+b=12")
        XCTAssert(!equation.isEasilyGuessable(with: .easy))
        XCTAssert(equation.isEasilyGuessable(with: .medium))
        XCTAssert(equation.isEasilyGuessable(with: .hard))
        XCTAssert(equation.isEasilyGuessable(with: .wizard))
    }
    
    func testMultiplyEquations() {
        // Top secret: the method doesn't use the 'difficulty' parameter here.
        
        let possibleSquares = [1, 9, 16, 25, 36]
        possibleSquares.forEach { square in
            let equation = Equation("axb=\(square)")
            XCTAssert(equation.isEasilyGuessable(with: .easy))
        }
    }
}
