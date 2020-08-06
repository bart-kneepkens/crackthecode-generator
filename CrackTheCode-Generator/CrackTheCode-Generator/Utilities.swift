//
//  Utilities.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 06/08/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import Foundation

// Oh yes, the utility class, where -seemingly- unrelated snippets of code seek refuge.
class Utilities {
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    static func getLocks(for difficulty: Difficulty) -> [Lock] {
        if difficulty == .easy {
            return [.A, .B, .C]
        }
        return ALL_LOCKS
    }

    static func possibleLockValues(for difficulty: Difficulty) -> ClosedRange<Int> {
        if difficulty == .easy {
            return 1...3
        }
        return 0...6
    }

}
