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
    //Test cases
    
    //Проверка нажатия кнопкт "Да" и смену счётчика вопросов на 2/10.
    func testYesButton() {
        
        let targetalert = app.alerts["Этот раунд окончен!"]
        let indexLabel = app.staticTexts["Index"]
        
        sleep(4)
        
        app.buttons["Yes"].tap()
        sleep(4)
        
        
        
        XCTAssertFalse(targetalert.exists)  //Проверяю, что алерта на экране нет.
        XCTAssertEqual(indexLabel.label, "2/10") //Проверяю изменение счётчика.
    }
    
    //Проверка нажатия кнопкт "Нет" и смену счётчика вопросов на 2/10.
    func testNoButton() {
        let targetalert = app.alerts["Этот раунд окончен!"]
        let indexLabel = app.staticTexts["Index"]
        
        sleep(4)
        
        app.buttons["No"].tap()
        sleep(4)
        
        XCTAssertFalse(targetalert.exists) //Проверяю, что алерта на экране нет.
        XCTAssertEqual(indexLabel.label, "2/10") //Проверяю изменение счётчика.
    }
    
    //Проверка появления алерта с нужным заголовком и нужной кнопкой.
    func testAlertArrival() {
        let targetalert = app.alerts["Этот раунд окончен!"]
        let alertButton = "Сыграть ещё раз"
        
        for _ in 1...10 {
            sleep(2)
            app.buttons["No"].tap()
            sleep(2)
        }
        
        sleep(2)
        XCTAssertTrue(targetalert.exists) //Проверяю, что алерт есть на экране.
        XCTAssertTrue(targetalert.buttons.firstMatch.label == alertButton) //Проверяю, что кнопка алерта соответствует ТЗ.
    }
    
    //Проверка отрабатывания кнопки алерта, исчезновения алерта и сброса счётчика вопросов на 1/10.
    func testAlertDismiss() {
        let indexLabel = app.staticTexts["Index"]
        let targetalert = app.alerts["Этот раунд окончен!"]
        let alertButton = "Сыграть ещё раз"
        let targetValue = "1/10"
        
        for _ in 1...10 {
            sleep(2)
            app.buttons["No"].tap()
            sleep(2)
        }
        
        sleep(2)
        XCTAssertTrue(targetalert.exists) //Проверяю, что алерт есть на экране.
        sleep(1)
        app.buttons[alertButton].tap() //Отрабатываю нажатие кнопки на алерте.
        
        sleep(2)
        XCTAssertFalse(targetalert.exists) //Проверяю, что алерта на экране нет.
        sleep(4)
        XCTAssertEqual(indexLabel.label, targetValue) //Проверяю, что счётчик сбросился, и равен "1/10".
    }
}

