//
//  Error.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 11/08/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import Foundation

enum GeneratorError: Error {
    case notEnoughArguments
    case invalidDifficulty
    case invalidAmount
    case serializingFailed
    
    var message: String {
        switch self {
        case .notEnoughArguments: return "Please provide 2 arguments - CrackTheCodeGenerator [difficulty] [amount]"
        case .invalidDifficulty: return "Please provide either 'easy', 'medium', 'hard', or 'wizard' as a difficulty."
        case .invalidAmount: return "Please provide a valid number"
        case .serializingFailed: return "sorry lol"
        }
    }
}
