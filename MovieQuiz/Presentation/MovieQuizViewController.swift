import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IBOutlet
    
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenter?
    
    
    // MARK: - UIViewController
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        imageView.layer.cornerRadius = 20
        alertPresenter = AlertPresenter(delegate: self)
        showLoadingIndicator()
    }

    // MARK: - Private Methods
    
    func show(quiz step: QuizStepViewModel) {
        questionLabel.text = step.question
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        borderReset()
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default) { [weak self] _ in
                self?.presenter.restartGame()
            }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func hideLoadingIndicator() {
        //Это я выносил из view, но приходилось аутлет делать Итернал. Так можно делать?
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showLoadingIndicator() {
        //Это я выносил из view, но приходилось аутлет делать Итернал. Так можно делать?
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func showNetworkError(message: String) {
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            self?.presenter.restartGame()
        }
        
        alertPresenter?.presentAlert(alert: model)
    }
    
    func showQuestion(quiz step: QuizStepViewModel) {
        questionLabel.text = step.question
        imageView.image = step.image
        counterLabel.text = step.questionNumber
    }
    
    func borderReset() {
        imageView.layer.borderWidth = 0
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.imageView.layer.masksToBounds = true
            self?.imageView.layer.borderWidth = 8
            self?.imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        }
    }
    
    //Я пытался привязять её к isProcessing, но не смог разоьраться с багом повторного срабатывания фабрики. Получалост на старте новой игры счётчик 2/10
    func lockButtons(_ input: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.yesButton.isEnabled = input
            self?.noButton.isEnabled = input
            self?.yesButton.setTitleColor(.ypGray, for: .disabled)
            self?.noButton.setTitleColor(.ypGray, for: .disabled)
        }
    }
    
    // MARK: - IBAction
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
}
