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
    
    private weak var viewController: MovieQuizViewController?
    
    private lazy var quizStatistics: QuizStatistics = {
        QuizStatistics(
            currentQuestionIndex: 0,
            correctAnswers: 0,
            totalQuestions: questionsAmount
        )
    }()
    
    private var questionFactory: QuestionFactoryProtocol?

    private let tapBuffer = TapBuffer(
        queue: .main,
        delay: tapBufferDelay
    )
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        viewController?.showAnswerResult(
            isCorrect: isYes == currentQuestion.correctAnswer
        )
    }
    
    private var currentQuestion: QuizQuestion?
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: quizStatistics.questionNumberPrompt
            )
    }
    
    private func isLastQuestion() -> Bool {
        quizStatistics.isQuizFinished
    }

    private func switchToNextQuestion() {
        quizStatistics.currentQuestionIndex += 1
    }
    
    init(viewController vc: MovieQuizViewController) {
        viewController = vc
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController?.showLoadingIndicator()
    }
    
    var correctAnswers: Int {
        quizStatistics.correctAnswers
    }
    
    var totalQuestions: Int {
        quizStatistics.totalQuestions
    }
    
    var quizResultPrompt: String {
        quizStatistics.quizResultPrompt
    }

    func resetQuestionIndex() {
        quizStatistics = QuizStatistics(
            currentQuestionIndex: 0,
            correctAnswers: 0,
            totalQuestions: questionsAmount
        )
    }
        
    func incrementCorrectStatIfAnswer(isCorrect: Bool) {
        quizStatistics.correctAnswers += isCorrect ? 1 : 0
    }
    
    func noButtonClicked() {
        tapBuffer.tap { [weak self] in
            self?.didAnswer(isYes: false)
        }
    }
    
    func yesButtonClicked() {
        tapBuffer.tap { [weak self] in
            self?.didAnswer(isYes: true)
        }
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
            
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        if isLastQuestion() {
            viewController?.showResultView()
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func restartGame() {
        resetQuestionIndex()
        questionFactory?.requestNextQuestion()
    }
}

extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
        
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }        
}
