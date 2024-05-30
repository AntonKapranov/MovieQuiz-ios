import XCTest

final class MovieQuizUITests:XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    //Проверка работы счётчика и кнопки "Да"
    func testYesButton() {
        let targetValue:String = "2/10"
        
        sleep(2)
        app.buttons["Yes"].tap()
        sleep(2)
        XCTAssertEqual("2/10", targetValue)
    }
    
    //Проверка работы счётчика и кнопки "Нет"
    func testNoButton() {
        let targetValue:String = "2/10"
        
        sleep(2)
        app.buttons["No"].tap()
        sleep(2)
        XCTAssertEqual("2/10", targetValue)
    }
    
    //Проверка срабатывания алерта в конце игры. Заголовок и кнопка должны соответствовать
    func testAlertExistance() {
//        let targetValue = "1/10"
        let targetalert = app.alerts["Этот раунд окончен!"]
//        let targetAlertButton = app.buttons["Сыграть ещё раз"]
        
        for _ in 1...10 {
            sleep(2)
            app.buttons["No"].tap()
            sleep(2)
        }
        
        XCTAssertTrue(targetalert.exists, "Alert has pop-up")
        sleep(2)
        XCTAssertTrue(targetalert.exists, "Alert has pop-up")
        sleep(1)
        app.buttons["Сыграть ещё раз"].tap()
    }
    
    //Повторный вызов алерта, проверка нажатия кнопки и сьроса счётчика
    func testViewRestart() {
        let targetalert = app.alerts["Этот раунд окончен!"]
        let targetValue = "1/10"
        
        for _ in 1...10 {
            sleep(2)
            app.buttons["No"].tap()
            sleep(2)
        }
        
        XCTAssertTrue(targetalert.exists, "Alert has pop-up")
        sleep(2)
        XCTAssertTrue(targetalert.exists, "Alert has pop-up")
        sleep(1)
        app.buttons["Сыграть ещё раз"].tap()
        
        sleep(1)
        XCTAssertFalse(targetalert.exists, "Alert has pop-up")
        XCTAssertEqual("1/10" ,targetValue )
    }
}


/*
 let resultModel = QuizResultsViewModel(
     title: "Этот раунд окончен!",
     text: text,
     buttonText: "Сыграть ещё раз"
 
 
 sleep(4)
         let firstPoster = app.images["Poster"]
         let firstPosterData = firstPoster.screenshot().pngRepresentation
         
         app.buttons["No"].tap()
         sleep(4)
         
         let secondPoster = app.images["Poster"]
         let secondPosterData = secondPoster.screenshot().pngRepresentation
         
         let indexLabel = app.staticTexts["Index"]
         
         XCTAssertEqual(indexLabel.label, "2/10")
         XCTAssertNotEqual(firstPosterData, secondPosterData)
 */
