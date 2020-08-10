//
//  Sequence.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 10/08/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

import Foundation

typealias Sequence = [Lock: Int]

extension Sequence {
    var stringRepresentation: String {
        return self
            .sorted(by: { $0.key.rawValue < $1.key.rawValue })
            .map({ String($0.value) })
            .joined()
    }
}
