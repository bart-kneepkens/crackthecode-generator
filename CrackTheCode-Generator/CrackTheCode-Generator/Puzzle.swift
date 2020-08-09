//
//  Puzzle.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 10/05/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

/*
 Represents a full puzzle; meaning a set of Equations, and a single combination.
 */
struct Puzzle {
    let equations: [Equation]
    let solution: String
}

extension Puzzle {
    init(_ dto: PuzzleDTO) {
        self.equations = dto.equations?.map({ Equation($0) }) ?? []
        self.solution = dto.solution ?? ""
    }
    
    var dataTransferObject: PuzzleDTO {
        return PuzzleDTO(equations: self.equations.map({ $0.description }), solution: self.solution)
    }
}

/**
 Used to transfer to and from  JSON
 All fields are optional -  this way there is no need to pollute the actual domain type with Codable initializers and CodingKeys.
 */
struct PuzzleDTO: Codable {
    let equations: [String]?
    let solution: String?
}
