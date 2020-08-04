//
//  Difficulty.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 04/08/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import Foundation

enum Difficulty: Int {
    case easy
    case medium
    case hard
    case wizard
}

extension Difficulty {
    var minimumComplexity: Int {
        switch self {
        case .hard: return 3
        case .wizard: return 6
        default:
            return Int.min
        }
    }
    
    var maximumComplexity: Int {
        switch self {
        case .easy: return Int.max // Easy games have only 3 locks, therefor no maximum complexity is needed
        case .medium: return 3
        case .hard: return 6
        case .wizard: return Int.max
        }
    }
}
