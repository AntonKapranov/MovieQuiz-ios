import UIKit

final class MovieQuizPresenter {
    weak var viewController: MovieQuizViewController?
    var currentQuestion: QuizQuestion?
    var isAnswerProcessing = false
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        viewController?.showQuestion(quiz: viewModel)
    }
    
    func yesButtonClicked() {
        guard !isAnswerProcessing, let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
        guard !isAnswerProcessing, let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func showNextQuestionOrResults() {
        if isLastQuestion() {
            viewController?.statisticService.store(correct: viewController?.correctAnswers ?? 0, total: questionsAmount)
            
            // Load from UserDefaults
            let gamesCount = viewController?.statisticService.gamesCount ?? 0
            let totalAccuracy = viewController?.statisticService.totalAccuracy ?? 0.0
            let bestGame = viewController?.statisticService.bestGame
            let bestGameTotal = bestGame?.total ?? 0
            let bestGameDate = bestGame?.date.dateTimeString ?? ""
            let correctAnswers = viewController?.correctAnswers ?? 0
            let extraInfo: String = """
            \n
            Ваш результат: \(correctAnswers) из \(questionsAmount)
            Количество сыграных квизов: \(gamesCount)
            Рекорд: \(bestGame?.correct ?? 0)/\(bestGameTotal) (\(bestGameDate))
            Средняя точность: \(String(format: "%.2f", totalAccuracy))%
            """
            
            let text = "Этот раунд окончен!" + extraInfo
            
            let resultModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз"
            )
            viewController?.showResult(quiz: resultModel)
        } else {
            switchToNextQuestion()
            viewController?.questionFactory?.requestNextQuestion()
        }
    }
}
