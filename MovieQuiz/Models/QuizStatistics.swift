//
//  QuizStatistics.swift
//  MovieQuiz
//
//  Created by Дмитрий Никишов on 22.12.2022.
//

import Foundation

struct QuizStatistics {
    var currentQuestionIndex: Int
    var correctAnswers: Int
    let totalQuestions: Int
    
    var questionNumberPrompt: String {
        "\(currentQuestionIndex + 1)/\(totalQuestions)"
    }
    
    var quizResultPrompt: String {
        "Ваш результат: \(correctAnswers) из 10"
    }
    
    var isQuizFinished: Bool {
        currentQuestionIndex == totalQuestions - 1
    }
}
