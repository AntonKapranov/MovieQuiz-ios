import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    
    var presenter: MovieQuizPresenter!
    var statisticService: StatisticServiceProtocol = StatisticServiceImplementation()
    var alertPresenter: AlertPresenter?
    var text: String = "" // Текст для алерта
    
    // MARK: - UIViewController
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        imageView.layer.cornerRadius = 20
        statisticService = StatisticServiceImplementation()
        alertPresenter = AlertPresenter(delegate: self)
        showLoadingIndicator()
        DispatchQueue.main.async {
            self.borderReset()
        }
    }

    // MARK: - Private Methods
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    
    func showNetworkError(message: String) {
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            self.presenter.showNextQuestionOrResults()
        }
        
        alertPresenter?.presentAlert(alert: model)
    }
    
    func showQuestion(quiz step: QuizStepViewModel) {
        questionLabel.text = step.question
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        yesButton.isEnabled = true
        noButton.isEnabled = true
        yesButton.setTitleColor(.ypBlack, for: .normal)
        noButton.setTitleColor(.ypBlack, for: .normal)
        borderReset()
    }
    
    func showResult(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default) { _ in
                self.presenter.restartGame()
                self.presenter.showNextQuestionOrResults()
            }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        presenter.isAnswerProcessing = true
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        yesButton.setTitleColor(.ypGray, for: .disabled)
        noButton.setTitleColor(.ypGray, for: .disabled)
        
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.presenter.isAnswerProcessing = false
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    func borderReset() {
        imageView.layer.borderWidth = 0
    }
    
    // MARK: - IBAction
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
}
