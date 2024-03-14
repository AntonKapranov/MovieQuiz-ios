import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else{return}
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else{return}
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    //Изменение цвета статусбара на светлый
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private var currentQuestionIndex:Int = 0
    private var correctAnswers:Int = 0
    private let questionsAmount:Int = 10
    private var questionFactory:QuestionFactory = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    private var text:String = "" //Текст для Алерта
    //private let currentQuestion = questions[currentQuestionIndex]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            let viewModel = convert(model: firstQuestion)
            show(quiz: viewModel)
        }
    }
    
    //Конвертация View model
    private func convert(model:QuizQuestion)->QuizStepViewModel{
        let questionStep = QuizStepViewModel(
            image: UIImage(named:model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    //Загрузка вью викторины с сбросом рамок
    private func show(quiz step: QuizStepViewModel) {
        //активация кнопок
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        borderReset()
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default)
        {_ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            if let firstQuestion = self.questionFactory.requestNextQuestion(){
                self.currentQuestion = firstQuestion
                let viewModel = self.convert(model: firstQuestion)
                
                self.show(quiz: viewModel)
            }
        }
        
        alert.addAction(action)
        self.present(alert,animated: true,completion: nil)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
       // метод красит рамку
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        
        //деактивация кнопок
        yesButton.isEnabled = false
        noButton.isEnabled = false
            //изменение цвета (так делают системные кнопки)
        yesButton.setTitleColor(.ypGray, for: .disabled)
        noButton.setTitleColor(.ypGray, for: .disabled)
        
        if isCorrect == true{
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else{
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        //задержка в 1.0 секунду
        DispatchQueue.main.asyncAfter(deadline:.now() + 1.0){
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults(){
        switch correctAnswers{
        case questionsAmount:
            text = "Поздравляем, вы ответили на 10 из 10!"
        default:
            text = "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
        }
        
        if currentQuestionIndex + 1 == questionsAmount{
            let viewModel = QuizResultsViewModel(
                title: "Игра окончена",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else{
            currentQuestionIndex += 1
            if let nextQuestion = questionFactory.requestNextQuestion() {
                currentQuestion = nextQuestion
                let viewModel = convert(model: nextQuestion)

                show(quiz: viewModel)
            }
        }
        
    }
    private func borderReset(){
        imageView.layer.borderWidth = 0
    }
}
