//
//  EquationTests.swift
//  CrackTheCode-Generator-Tests
//
//  Created by Bart Kneepkens on 06/08/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import XCTest

class EquationStringInitializerTests: XCTestCase {
    func testProperFormat() {
        [EquationType.add, EquationType.multiply, EquationType.subtract].forEach { type in
            let equation = Equation("a\(type.rawValue)b=3")
            XCTAssertNotNil(equation)
            XCTAssert(equation?.left == .A)
            XCTAssert(equation?.type == type)
            XCTAssert(equation?.right == .B)
            XCTAssert(equation?.result == 3)
        }
    }
    
    func testMangledFormats() {
        XCTAssertNil(Equation("a+b=r"))
        XCTAssertNil(Equation("a+b=="))
        XCTAssertNil(Equation("a+b1="))
        XCTAssertNil(Equation("a+"))
        XCTAssertNil(Equation("b+z=2")) // nonexistent Lock
    }
}

class IsEasilyGuessableTests: XCTestCase {
    func testAddEquationUpperBoundsEasy() {
        let equation = Equation(left: .A, type: .add, right: .B, result: 6)
        
        XCTAssert(equation.isEasilyGuessable(with: .easy))
        XCTAssert(!equation.isEasilyGuessable(with: .medium))
        XCTAssert(!equation.isEasilyGuessable(with: .hard))
        XCTAssert(!equation.isEasilyGuessable(with: .wizard))
    }
    
    func testAddEquationUpperBounds() {
        let equation = Equation(left: .A, type: .add, right: .B, result: 5)
        
        XCTAssert(!equation.isEasilyGuessable(with: .easy))
        XCTAssert(!equation.isEasilyGuessable(with: .medium))
        XCTAssert(!equation.isEasilyGuessable(with: .hard))
        XCTAssert(!equation.isEasilyGuessable(with: .wizard))
    }
    
    func testAddEquationUpperBoundsMediumAndAbove() {
        let equation = Equation(left: .A, type: .add, right: .B, result: 12)
        XCTAssert(!equation.isEasilyGuessable(with: .easy))
        XCTAssert(equation.isEasilyGuessable(with: .medium))
        XCTAssert(equation.isEasilyGuessable(with: .hard))
        XCTAssert(equation.isEasilyGuessable(with: .wizard))
    }
    
    func testMultiplyEquations() {
        // Top secret: the method doesn't use the 'difficulty' parameter here.
        
        let possibleSquares = [1, 9, 16, 25, 36]
        possibleSquares.forEach { square in
            let equation = Equation(left: .A, type: .multiply, right: .B, result: square)
            XCTAssert(equation.isEasilyGuessable(with: .easy))
        }
    }
}
