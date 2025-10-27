import XCTest

class Image_FeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["authenticateButton"].tap()
        
        let webView = app.webViews["unsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.safeTypeText("email", app: app)
        
        closeKeyaboard(app: app)
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.safeTypeText("pass", app: app)
        
        closeKeyaboard(app: app)
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element
        
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        sleep(3)
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let cellImage = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        let likeOff = cellImage.buttons["likeOffButton"]
        XCTAssertTrue(likeOff.waitForExistence(timeout: 3))
        likeOff.tap()
        XCTAssertTrue(cellImage.buttons["likeOnButton"].waitForExistence(timeout: 3))
        
        let likeOn = cellImage.buttons["likeOnButton"]
        likeOn.tap()
        XCTAssertTrue(cellImage.buttons["likeOffButton"].waitForExistence(timeout: 3))
        
        cellImage.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["navBackButton"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["userNameLabel"].exists)
        XCTAssertTrue(app.staticTexts["userNickLabel"].exists)
        
        app.buttons["logoutButton"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
    
    private func closeKeyaboard(app: XCUIApplication) {
        let coordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        coordinate.tap()
    }
}

extension XCUIElement {
    // Из-за холодного старта после установки приложения клавиаутра может показываться с задержкой. Данный фикс позволяет дождаться ее появления и корректного ввода текста
    func safeTypeText(_ text: String, app: XCUIApplication, timeout: TimeInterval = 5) {
        let predicate = NSPredicate(format: "exists == true AND hittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        _ = XCTWaiter().wait(for: [expectation], timeout: timeout)
        
        self.tap()
        
        if !app.keyboards.element.waitForExistence(timeout: 2) {
            self.tap()
            _ = app.keyboards.element.waitForExistence(timeout: 2)
        }
        
        sleep(2)
        
        self.typeText(text)
    }
}
