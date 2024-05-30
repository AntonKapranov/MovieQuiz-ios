import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    // MARK: - IBOutlet
    
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    
    private let presenter = MovieQuizPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticServiceImplementation()
    private var correctAnswers: Int = 0
    private var isAnswerProcessing = false
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var text: String = "" // Текст для алерта
    
    // MARK: - UIViewController
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        alertPresenter = AlertPresenter(delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
        DispatchQueue.main.async {
            self.borderReset()
        }
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        isAnswerProcessing = false
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.showQuestion(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.isHidden = true
            self?.questionFactory?.requestNextQuestion()
            self?.borderReset()
        }
    }
    
    func didFailToLoadData(with error: any Error) {
        DispatchQueue.main.async { [weak self] in
            self?.showNetworkError(message: error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.presentAlert(alert: model)
    }
    
    
    private func showQuestion(quiz step: QuizStepViewModel) {
        questionLabel.text = step.question
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        yesButton.isEnabled = true
        noButton.isEnabled = true
        yesButton.setTitleColor(.ypBlack, for: .normal)
        noButton.setTitleColor(.ypBlack, for: .normal)
        borderReset()
    }
    
    private func showResult(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default) { _ in
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        isAnswerProcessing = true
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        yesButton.setTitleColor(.ypGray, for: .disabled)
        noButton.setTitleColor(.ypGray, for: .disabled)
        
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        DispatchQueue.main.async { [self] in
            if presenter.isLastQuestion() {
                statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
                
                // загружать из UserDefaults
                let gamesCount = self.statisticService.gamesCount
                let totalAccuracy = self.statisticService.totalAccuracy
                let bestGame = self.statisticService.bestGame
                let bestGameTotal = bestGame.total
                let bestGameDate = bestGame.date.dateTimeString
                let extraInfo:String = """
                \n
                Ваш результат: \(self.correctAnswers) из \(presenter.questionsAmount)
                Количество сыграных квизов: \(gamesCount)
                Рекорд: \(bestGame.correct)/\(bestGameTotal) (\(bestGameDate))
                Средняя точность: \(String(format: "%.2f", totalAccuracy))%
                """
                
                self.text = "Этот раунд окончен!"
                self.text += extraInfo
                
                let resultModel = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: self.text,
                    buttonText: "Сыграть еще раз"
                )
                self.showResult(quiz: resultModel)
            } else {
                self.presenter.switchToNextQuestion()
                self.questionFactory?.requestNextQuestion()
            }
        }
    }
    
    private func borderReset() {
        DispatchQueue.main.async {
            self.imageView.layer.borderWidth = 0
        }
    }
    
    // MARK: - IBAction
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard !isAnswerProcessing, let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard !isAnswerProcessing, let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
