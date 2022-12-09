import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!

    private let questions: [QuizQuestion] = [
            QuizQuestion(
                image: "The Godfather",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Dark Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Kill Bill",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Avengers",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Deadpool",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Green Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Old",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "The Ice Age Adventures of Buck Wild",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Tesla",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Vivarium",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false)
        ]

    private lazy var quizStatistics = QuizStatistics(
        currentQuestionIndex: 0,
        correctAnswers: 0,
        totalQuestions: self.questions.count
    )
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImageViewBorder()
        showFirstQuestion()
    }
    
    private func setupImageViewBorder() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 6
    }
    
    private func showFirstQuestion() {
        quizStatistics = QuizStatistics(
            currentQuestionIndex: 0,
            correctAnswers: 0,
            totalQuestions: self.questions.count
        )
        show(quiz: getCurrentStepViewModel())
    }
    
    private func getCurrentStepViewModel() -> QuizStepViewModel {
        convert(model: questions[quizStatistics.currentQuestionIndex])
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
      QuizStepViewModel(
        image: UIImage(named: model.image) ?? UIImage(),
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

    private func showAlertWith(
        title: String,
        text: String,
        buttonText: String
    ) {
        let alert = UIAlertController(
                title: title,
                message: text,
                preferredStyle: .alert)
            
        let action = UIAlertAction(
            title: buttonText,
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            
            self.showFirstQuestion()
        }
            
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        showAlertWith(
            title: result.title,
            text: result.text,
            buttonText: result.buttonText
        )
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        quizStatistics.correctAnswers += isCorrect ? 1 : 0

        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
        }
    }
    
    private func showResultView() {
        let viewModel = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: quizStatistics.quizResultPrompt,
            buttonText: "Сыграть ещё раз"
        )
        
        show(quiz: viewModel)
    }
    
    private func showNextQuestionOrResults() {
        if quizStatistics.isQuizFinished {
            showResultView()
        } else {
            quizStatistics.currentQuestionIndex += 1
            show(quiz: getCurrentStepViewModel())
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        showAnswerResult(
            isCorrect: false == questions[quizStatistics.currentQuestionIndex].correctAnswer
        )
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        showAnswerResult(
            isCorrect: true == questions[quizStatistics.currentQuestionIndex].correctAnswer
        )
    }
}


extension MovieQuizViewController {
    private struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    private struct QuizStepViewModel {
      let image: UIImage
      let question: String
      let questionNumber: String
    }

    private struct QuizResultsViewModel {
      let title: String
      let text: String
      let buttonText: String
    }
    
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
}
