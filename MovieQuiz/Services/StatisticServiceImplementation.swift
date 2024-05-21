import UIKit

final class StatisticServiceImplementation{
    let storage = UserDefaults.standard
    
    // Ключи для UserDefaults
    private enum Keys: String {
        case correct // Количество правильных ответов
        case totalQuestions // Общее количество вопросов
        case date // Дата завершения раунда
        case bestGameCorrect // Количество правильных ответов в лучшей игре
        case bestGameTotal // Общее количество вопросов в лучшей игре
        case bestGameDate // Дата лучшей игры
        case totalCorrectAnswers // Общее количество правильных ответов
        case gamesCount // Количество сыгранных игр
    }
}

extension StatisticServiceImplementation:StatisticServiceProtocol{
    var totalAccuracy: Double {
        let totalCorrect = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        
        guard totalQuestions > 0 else {
            return 0.0
        }
        
        return Double(totalCorrect) / Double(totalQuestions) * 100.0
    }
    
    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        let totalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue) + count
        storage.set(totalCorrectAnswers, forKey: Keys.totalCorrectAnswers.rawValue)
        
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue) + amount
        storage.set(totalQuestions, forKey: Keys.totalQuestions.rawValue)
        
        let currentGameRecord = GameResult(correct: count, total: amount, date: Date())
        let bestGameRecord = bestGame
        
        if currentGameRecord.isBetterThan(bestGameRecord) {
            bestGame = currentGameRecord
        }
    }
}
