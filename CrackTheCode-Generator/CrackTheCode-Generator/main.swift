//
//  main.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 05/05/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import Foundation

let argumentsCount = CommandLine.argc
let arguments = CommandLine.arguments

guard argumentsCount == 3 else {
    print("Please provide 2 arguments - CrackTheCodeGenerator [difficulty] [amount]")
    exit(1)
}

guard let difficulty = Difficulty(rawValue: arguments[1]) else {
    print("Please provide either 'easy', 'medium', 'hard', or 'wizard' as a difficulty.")
    exit(1)
}

guard let amount = Int(arguments[2]), amount <= difficulty.maximumPuzzleAmount else {
    print("Please provide a valid number")
    exit(1)
}

let puzzles = Generator().generatePuzzles(amount: amount, difficulty: difficulty)
let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted

let dtos = puzzles.map({ $0.dataTransferObject })
let data = try! encoder.encode(dtos)

print(String(bytes: data, encoding: .utf8)!)
