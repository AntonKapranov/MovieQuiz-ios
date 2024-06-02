import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private weak var viewController: MovieQuizViewControllerProtocol?
    var statisticService: StatisticServiceProtocol = StatisticServiceImplementation()
    var currentQuestion: QuizQuestion?
    var isAnswerProcessing = false
    let questionsAmount: Int = 10
    var text: String = "" // Текст для алерта
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?

    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        statisticService = StatisticServiceImplementation()
        viewController.showLoadingIndicator()
    }

    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
            + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func showAnswerResult(isCorrect: Bool) {
        isAnswerProcessing = true
        viewController?.lockButtons(false)

        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isAnswerProcessing = false
            self.viewController?.lockButtons(true)
            self.showNextQuestionOrResults()
        }
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
        viewController?.show(quiz: viewModel)
    }

    func didLoadDataFromServer() {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideLoadingIndicator()
            self?.questionFactory?.requestNextQuestion()
            self?.viewController?.borderReset()
        }
    }

    func didFailToLoadData(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showNetworkError(message: error.localizedDescription)
        }
    }

    func yesButtonClicked() {
        guard !isAnswerProcessing, let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    func noButtonClicked() {
        guard !isAnswerProcessing, let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func showNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: questionsAmount)

            let gamesCount = statisticService.gamesCount
            let totalAccuracy = statisticService.totalAccuracy
            let bestGame = statisticService.bestGame
            let bestGameTotal = bestGame.total
            let bestGameDate = bestGame.date.dateTimeString
            let extraInfo: String = """
            \n
            Ваш результат: \(correctAnswers) из \(questionsAmount)
            Количество сыграных квизов: \(gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGameTotal) (\(bestGameDate))
            Средняя точность: \(String(format: "%.2f", totalAccuracy))%
            """

            let text = "Этот раунд окончен!" + extraInfo

            let resultModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
//            showResult(quiz: resultModel)
            viewController?.show(quiz: resultModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
