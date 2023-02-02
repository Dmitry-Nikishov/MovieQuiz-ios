//
//  MovieQuizPresenterTests.swift
//  MovieQuizPresenterTests
//
//  Created by Дмитрий Никишов on 30.01.2023.
//

import XCTest
@testable import MovieQuiz

final class StatisticsServiceMock: StatisticService {
    func store(correctAnswers count: Int, totalQuestions amount: Int) {}
    var totalAccuracy: Double { 0 }
    var gamesCount: Int { 0 }
    var bestGameRecord: GameRecord { GameRecord.getDefault() }
}

final class MovieQuizViewControllerProtocolMock: MovieQuizViewControllerProtocol {
    var latestQuizStepViewModel: QuizStepViewModel?
    var latestQuizResultsViewModel: QuizResultsViewModel?
    
    private var expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    func show(quiz step: QuizStepViewModel) {
        latestQuizStepViewModel = step
        expectation.fulfill()
    }
    
    func show(quiz result: QuizResultsViewModel) {
        latestQuizResultsViewModel = result
        expectation.fulfill()
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
    
    }
    
    func showLoadingIndicator() {
    
    }
    
    func hideLoadingIndicator() {
    
    }
    
    func showNetworkError(message: String) {
    
    }
    
    func showResultView() {}
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let expectation = expectation(description: "Loading expectation")
        let viewControllerMock = MovieQuizViewControllerProtocolMock(expectation: expectation)
        let sut = MovieQuizPresenter(
            viewController: viewControllerMock,
            statisticsService: StatisticsServiceMock()
        )
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        
        sut.didReceiveNextQuestion(question: question)
        
        waitForExpectations(timeout: 1)
        
        XCTAssertNotNil(viewControllerMock.latestQuizStepViewModel)
        XCTAssertNotNil(viewControllerMock.latestQuizStepViewModel?.image)
        XCTAssertEqual(viewControllerMock.latestQuizStepViewModel?.question, "Question Text")
        XCTAssertEqual(viewControllerMock.latestQuizStepViewModel?.questionNumber, "1/10")
    }
}
