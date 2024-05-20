import UIKit

final class StatisticServiceImplementation{
    let storage = UserDefaults.standard
    
    private enum Keys: String {
        case correct //количество правильных ответов
        case totalQuestions //количество вопросов квиза
        case date //дату завершения раунда.
        case bestGame //Знчение самого большого счёта игры
        case totalCorrectAnswers //сколько всего было дано правильных вопросов
        case gamesCount //число сыграных игр (или законченных?)
        case accuracy //точность игрока в %
    }
}

extension StatisticServiceImplementation:StatisticServiceProtocol{
    var totalAccuracy: Double {
        // отношение всех правильных ответов от общего числа вопросов
        let totalCorrect = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        
        guard totalQuestions > 0 else {
            return 0.0
        }
        
        return Double(totalCorrect) / Double(totalQuestions) * 100.0
        // отношение всех правильных ответов от общего числа вопросов
//        var total = storage.integer(forKey: Keys.total.rawValue)
//        var games = storage.integer(forKey: Keys.gamesCount.rawValue)
//        
//        if games == 0{
//            return 0.0
//        } else{
//            var accuracy = total/games * 100
//            return accuracy
//        }
    }
    
    var gamesCount: Int {
        get {
            // Добавьте чтение значения из UserDefaults
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            // Добавьте запись значения newValue из UserDefaults
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            // Добавьте чтение значений полей GameResult(correct, total и date) из UserDefaults,
            // затем создайте GameResult от полученных значений
            var correct = storage.integer(forKey: Keys.correct.rawValue)
            var total = storage.integer(forKey: Keys.gamesCount.rawValue)
            var date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            // Добавьте запись значений каждого поля из newValue из UserDefaults
            storage.set(newValue, forKey: Keys.bestGame.rawValue)
        }
    }
    func store(correct count: Int, total amount: Int) {
        var playedGames = gamesCount
        playedGames += 1
        
        storage.set(playedGames, forKey: Keys.gamesCount.rawValue)
        
        let totalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue) + count
        storage.set(totalCorrectAnswers, forKey: Keys.totalCorrectAnswers.rawValue)
        
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue) + amount
        storage.set(totalQuestions, forKey: Keys.totalQuestions.rawValue)
        
        let currentGameRecord = GameResult(correct: count, total: amount, date: Date())
        let bestGameRecord = bestGame
        
        if currentGameRecord.isBetterThan(bestGameRecord){
            bestGame = currentGameRecord
        }
    }
}
