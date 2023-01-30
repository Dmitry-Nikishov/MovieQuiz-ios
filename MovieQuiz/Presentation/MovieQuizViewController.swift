import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
        
    private lazy var alertPresenter: AlertPresenter = {
        let alertPresenter = AlertPresenter()
        alertPresenter.controller = self
        return alertPresenter
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
        let message = presenter.makeResultsMessage()
        
        let viewModel = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: message,
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

    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderWidth = AppUiConstants.imageViewBorderWidthWhenDisplayed
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
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
