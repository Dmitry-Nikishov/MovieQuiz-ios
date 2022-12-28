//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Дмитрий Никишов on 26.12.2022.
//

import Foundation

struct GameRecord: Codable, Comparable {
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct < rhs.correct
    }
    
    let correct: Int
    let total: Int
    let date: Date
}