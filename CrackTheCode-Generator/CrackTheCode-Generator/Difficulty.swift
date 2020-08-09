//
//  Difficulty.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 04/08/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import Foundation

enum Difficulty: String {
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
        case .easy: return Int.max // Easy games have only 3 locks, so no maximum complexity is needed
        case .medium: return 3
        case .hard: return 6
        case .wizard: return Int.max
        }
    }
    
    var locks: [Lock] {
        if self == .easy {
            return [.A, .B, .C]
        }
        return ALL_LOCKS
    }
    
    var possibleLockValues: ClosedRange<Int> {
        if self == .easy {
            return 1...3
        }
        return 0...6
    }
    
    var maximumPuzzleAmount: Int {
        if self == .easy {
            // 3 * 3 * 3, except that it's impossible to find working equations for the combination '333', so that one excluded.
            return 26
        }
        // TODO: find out edge cases for other difficulties
        return Int.max
    }
}
