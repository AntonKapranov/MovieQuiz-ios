import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBAction private func yesButtonClicked(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBAction private func noButtonClicked(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    //Изменение цвета статусбара на светлый
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private var currentQuestionIndex:Int = 0
    private var correctAnswers:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentQuestion = questions[currentQuestionIndex]
        let questionStep = convert(model: currentQuestion)
        show(quiz: questionStep)
    }
    
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
    
    //Конвертация View model
    private func convert(model:QuizQuestion)->QuizStepViewModel{
        let questionStep = QuizStepViewModel(
            image: UIImage(named:model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
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
            
            let question = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: question)
            self.show(quiz: viewModel)
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
        if currentQuestionIndex == questions.count - 1 {
            //Alert
            let text = "Ваш результат: \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel(
                title: "Игра окончена",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
            
        } else{
            currentQuestionIndex += 1
            
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            
            show(quiz: viewModel)
        }
    }

    private func borderReset(){
        //imageView.layer.masksToBounds = false\
        imageView.layer.borderWidth = 0
    }
}
