//
//  Lock.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 10/05/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

let ALL_LOCKS: [Lock] = [.A, .B, .C, .D, .E, .F]

enum Lock: String, Codable {
    case A
    case B
    case C
    case D
    case E
    case F
}
