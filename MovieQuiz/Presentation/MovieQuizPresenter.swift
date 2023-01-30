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
    
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private lazy var statisticsService: StatisticService = {
        StatisticServiceImplementation()
    }()

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
        
        proceedWithAnswer(isCorrect: isYes == currentQuestion.correctAnswer)
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
    
    private func proceedWithAnswer(isCorrect: Bool) {
        incrementCorrectStatIfAnswer(isCorrect: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            viewController?.showResultView()
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }

    private func resetQuestionIndex() {
        quizStatistics = QuizStatistics(
            currentQuestionIndex: 0,
            correctAnswers: 0,
            totalQuestions: questionsAmount
        )
    }

    private func incrementCorrectStatIfAnswer(isCorrect: Bool) {
        quizStatistics.correctAnswers += isCorrect ? 1 : 0
    }
    
    init(viewController vc: MovieQuizViewControllerProtocol) {
        viewController = vc
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController?.showLoadingIndicator()
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
    
    func restartGame() {
        resetQuestionIndex()
        questionFactory?.requestNextQuestion()
    }
    
    func makeResultsMessage() -> String {
        statisticsService.store(
            correctAnswers: quizStatistics.correctAnswers,
            totalQuestions: quizStatistics.totalQuestions
        )
        
        let bestGameRecord = statisticsService.bestGameRecord
        let averageAccuracy = "\(String(format: "%.2f", statisticsService.totalAccuracy))%"
        
        let resultMessage = """
        \(quizStatistics.quizResultPrompt)
        Количество сыгранных квизов: \(statisticsService.gamesCount)
        Рекорд: \(bestGameRecord.correct)/\(bestGameRecord.total) (\(bestGameRecord.date.dateTimeString))
        Средняя точность: \(averageAccuracy)
        """

        return resultMessage
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
}
