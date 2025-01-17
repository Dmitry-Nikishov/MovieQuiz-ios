//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Дмитрий Никишов on 26.12.2022.
//

import Foundation

protocol StatisticService {
    func store(correctAnswers count: Int, totalQuestions amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGameRecord: GameRecord { get }
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    func store(correctAnswers count: Int, totalQuestions amount: Int) {
        let currentRecord = GameRecord(
            correct: count,
            total: amount,
            date: Date()
        )
        
        if bestGameRecord < currentRecord {
            bestGameRecord = currentRecord
        }
        
        let storedCorrectAnswers = correctAnswers
        let currentCorrectAnswers = storedCorrectAnswers + count
        correctAnswers = currentCorrectAnswers
        
        let currentGamesCount = gamesCount + 1
        gamesCount = currentGamesCount
        
        totalAccuracy = 100*Double(currentCorrectAnswers)/Double(currentGamesCount*amount)
    }
    
    private var correctAnswers: Int {
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            userDefaults.double(forKey: Keys.total.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGameRecord: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
}

