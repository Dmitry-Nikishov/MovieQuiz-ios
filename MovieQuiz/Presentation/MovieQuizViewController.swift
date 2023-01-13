import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    
    private lazy var questionFactory: QuestionFactoryProtocol = {
        QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self
        )
    }()
    
    private lazy var alertPresenter: AlertPresenter = {
        let presenter = AlertPresenter()
        presenter.controller = self
        return presenter
    }()

    private lazy var quizStatistics: QuizStatistics = {
        QuizStatistics(
            currentQuestionIndex: 0,
            correctAnswers: 0,
            totalQuestions: questionsAmount
        )
    }()
    
    private lazy var statisticsService: StatisticService = {
        StatisticServiceImplementation()
    }()

    private let tapBuffer = TapBuffer(
        queue: .main,
        delay: AppUiConstants.tapBufferDelay
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImageViewBorder()
        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self = self else { return }
                
            self.resetQuizStatistics()
            self.questionFactory.requestNextQuestion()
        }
            
        alertPresenter.show(model: model)
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func setupImageViewBorder() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = AppUiConstants.imageViewCornerRadius
    }
    
    private func resetQuizStatistics() {
        quizStatistics = QuizStatistics(
            currentQuestionIndex: 0,
            correctAnswers: 0,
            totalQuestions: questionsAmount
        )
    }
    
    private func showQuizQuestion() {
        questionFactory.requestNextQuestion()
    }
        
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: quizStatistics.questionNumberPrompt
            )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = step.image
        
        imageView.layer.borderWidth = 0
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alertInfo = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.resetQuizStatistics()
                self.showQuizQuestion()
            }
        )
        
        alertPresenter.show(model: alertInfo)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        quizStatistics.correctAnswers += isCorrect ? 1 : 0

        imageView.layer.borderWidth = AppUiConstants.imageViewBorderWidthWhenDisplayed
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
        }
    }
    
    private func showResultView() {
        statisticsService.store(
            correctAnswers: quizStatistics.correctAnswers,
            totalQuestions: quizStatistics.totalQuestions
        )
        
        let bestGameRecord = statisticsService.bestGameRecord
        let averageAccuracy = "\(String(format: "%.2f", statisticsService.totalAccuracy))%"
        
        let textToDisplay = """
        \(quizStatistics.quizResultPrompt)
        Количество сыгранных квизов: \(statisticsService.gamesCount)
        Рекорд: \(bestGameRecord.correct)/\(bestGameRecord.total) (\(bestGameRecord.date.dateTimeString))
        Средняя точность: \(averageAccuracy)
        """
        
        let viewModel = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: textToDisplay,
            buttonText: "Сыграть ещё раз"
        )
        
        show(quiz: viewModel)
    }
    
    private func showNextQuestionOrResults() {
        if quizStatistics.isQuizFinished {
            showResultView()
        } else {
            quizStatistics.currentQuestionIndex += 1
            showQuizQuestion()
        }
    }
    
    private func noClickHandler() {
        guard let currentQuestion = currentQuestion else {
            return
        }

        showAnswerResult(
            isCorrect: !currentQuestion.correctAnswer
        )
    }
    
    private func yesClickHandler() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(
            isCorrect: currentQuestion.correctAnswer
        )
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        tapBuffer.tap { [weak self] in
            self?.noClickHandler()
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        tapBuffer.tap { [weak self] in
            self?.yesClickHandler()
        }
    }
}


extension MovieQuizViewController {    
    enum AppUiConstants {
        static let imageViewBorderWidthWhenDisplayed: CGFloat = 8
        static let imageViewCornerRadius: CGFloat = 20
        static let tapBufferDelay: Double = 0.4
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate {
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
            
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
}
