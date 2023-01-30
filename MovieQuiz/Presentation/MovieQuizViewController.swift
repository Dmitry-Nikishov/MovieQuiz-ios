import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
        
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
        
        presenter = MovieQuizPresenter(viewController: self)
        setupImageViewBorder()
        showLoadingIndicator()
    }
                
    private func setupImageViewBorder() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = AppUiConstants.imageViewCornerRadius
    }
                
    private func show(quiz result: QuizResultsViewModel) {
        let alertInfo = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.presenter.restartGame()
            }
        )
        
        alertPresenter.show(model: alertInfo)
    }

    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self = self else { return }
                
            self.presenter.restartGame()
        }
            
        alertPresenter.show(model: model)
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
        
    func showResultView() {
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
        
    func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = step.image
        
        imageView.layer.borderWidth = 0
    }

    func showAnswerResult(isCorrect: Bool) {
       presenter.incrementCorrectStatIfAnswer(isCorrect: isCorrect)

       imageView.layer.borderWidth = AppUiConstants.imageViewBorderWidthWhenDisplayed
       imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
       
       DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
           self?.presenter.showNextQuestionOrResults()
       }
   }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
}

extension MovieQuizViewController {    
    enum AppUiConstants {
        static let imageViewBorderWidthWhenDisplayed: CGFloat = 8
        static let imageViewCornerRadius: CGFloat = 20
    }
}
