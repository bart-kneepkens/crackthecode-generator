//
//  main.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 05/05/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import Foundation

func main() throws {
    let argumentsCount = CommandLine.argc
    let arguments = CommandLine.arguments

    guard argumentsCount == 3 else {
        throw GeneratorError.notEnoughArguments
    }

    guard let difficulty = Difficulty(rawValue: arguments[1]) else {
        throw GeneratorError.invalidDifficulty
    }

    guard let amount = Int(arguments[2]), amount <= difficulty.maximumPuzzleAmount else {
        throw GeneratorError.invalidAmount
    }
    
    let puzzles = Generator().generatePuzzles(amount: amount, difficulty: difficulty)
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    let dtos = puzzles.map({ $0.dataTransferObject })
    
    guard let data = try? encoder.encode(dtos), let stringRepresentation = String(bytes: data, encoding: .utf8) else {
        throw GeneratorError.serializingFailed
    }
    
    print(stringRepresentation)
}

do {
    try main()
} catch let error as GeneratorError {
    print(error.message)
    exit(1)
}
