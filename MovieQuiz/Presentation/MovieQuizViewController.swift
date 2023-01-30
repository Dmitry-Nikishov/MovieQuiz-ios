import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestion: QuizQuestion?
    private let presenter = MovieQuizPresenter()
    
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
    
    private lazy var statisticsService: StatisticService = {
        StatisticServiceImplementation()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        setupImageViewBorder()
        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self = self else { return }
                
            self.presenter.resetQuestionIndex()
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
        
    private func showQuizQuestion() {
        questionFactory.requestNextQuestion()
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
                
                self.presenter.resetQuestionIndex()
                self.showQuizQuestion()
            }
        )
        
        alertPresenter.show(model: alertInfo)
    }
        
    private func showResultView() {
        statisticsService.store(
            correctAnswers: presenter.correctAnswers,
            totalQuestions: presenter.totalQuestions
        )
        
        let bestGameRecord = statisticsService.bestGameRecord
        let averageAccuracy = "\(String(format: "%.2f", statisticsService.totalAccuracy))%"
        
        let textToDisplay = """
        \(presenter.quizResultPrompt)
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
        if presenter.isLastQuestion() {
            showResultView()
        } else {
            presenter.switchToNextQuestion()
            showQuizQuestion()
        }
    }
    
    func showAnswerResult(isCorrect: Bool) {
       presenter.incrementCorrectStatIfAnswer(isCorrect: isCorrect)

       imageView.layer.borderWidth = AppUiConstants.imageViewBorderWidthWhenDisplayed
       imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
       
       DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
           self?.showNextQuestionOrResults()
       }
   }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
}


extension MovieQuizViewController {    
    enum AppUiConstants {
        static let imageViewBorderWidthWhenDisplayed: CGFloat = 8
        static let imageViewCornerRadius: CGFloat = 20
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate {
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
            
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
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
