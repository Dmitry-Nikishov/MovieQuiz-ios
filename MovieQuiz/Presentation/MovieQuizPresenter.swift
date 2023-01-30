//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Дмитрий Никишов on 30.01.2023.
//

import UIKit

final class MovieQuizPresenter {
    private let questionsAmount: Int = 10
    private static let tapBufferDelay: Double = 0.4
    
    private lazy var quizStatistics: QuizStatistics = {
        QuizStatistics(
            currentQuestionIndex: 0,
            correctAnswers: 0,
            totalQuestions: questionsAmount
        )
    }()
    
    private let tapBuffer = TapBuffer(
        queue: .main,
        delay: tapBufferDelay
    )
    
    private func noClickHandler() {
        guard let currentQuestion = currentQuestion else {
            return
        }

        viewController?.showAnswerResult(
            isCorrect: !currentQuestion.correctAnswer
        )
    }
    
    private func yesClickHandler() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        viewController?.showAnswerResult(
            isCorrect: currentQuestion.correctAnswer
        )
    }

    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    var correctAnswers: Int {
        quizStatistics.correctAnswers
    }
    
    var totalQuestions: Int {
        quizStatistics.totalQuestions
    }
    
    var quizResultPrompt: String {
        quizStatistics.quizResultPrompt
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: quizStatistics.questionNumberPrompt
            )
    }
    
    func isLastQuestion() -> Bool {
        quizStatistics.isQuizFinished
    }
    
    func resetQuestionIndex() {
        quizStatistics = QuizStatistics(
            currentQuestionIndex: 0,
            correctAnswers: 0,
            totalQuestions: questionsAmount
        )
    }
    
    func switchToNextQuestion() {
        quizStatistics.currentQuestionIndex += 1
    }
    
    func incrementCorrectStatIfAnswer(isCorrect: Bool) {
        quizStatistics.correctAnswers += isCorrect ? 1 : 0
    }
    
    func noButtonClicked() {
        tapBuffer.tap { [weak self] in
            self?.noClickHandler()
        }
    }
    
    func yesButtonClicked() {
        tapBuffer.tap { [weak self] in
            self?.yesClickHandler()
        }
    }
}
