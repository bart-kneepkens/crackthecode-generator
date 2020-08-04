//
//  Puzzle.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 10/05/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

/*
 Represents a full puzzle; meaning a set of Statements, and a single combination.
 */
struct Puzzle {
    let statements: [Statement]
    let answer: String
}

extension Puzzle {
    init(_ dto: PuzzleDTO) {
        self.statements = dto.statements?.map({ Statement($0) }) ?? []
        self.answer = dto.answer ?? ""
    }
    
    func dataTransferObject() -> PuzzleDTO {
        return PuzzleDTO(statements: self.statements.map({ $0.description }), answer: self.answer)
    }
}

/**
 Used to transfer to and from  JSON
 All fields are optional -  this way there is no need to pollute the actual domain type.
 */
struct PuzzleDTO: Codable {
    let statements: [String]?
    let answer: String?
}
