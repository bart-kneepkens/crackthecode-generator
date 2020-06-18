//
//  Puzzle.swift
//  CrackTheCode-Generator
//
//  Created by Bart Kneepkens on 10/05/2020.
//  Copyright © 2020 bart-kneepkens. All rights reserved.
//

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

struct PuzzleDTO: Codable {
    let statements: [String]?
    let answer: String?
}
