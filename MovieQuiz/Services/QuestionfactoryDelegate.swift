import UIKit

protocol QuestionfactoryDelegate: AnyObject{
    func didReceiveNextQuestion(question:QuizQuestion?)
}
