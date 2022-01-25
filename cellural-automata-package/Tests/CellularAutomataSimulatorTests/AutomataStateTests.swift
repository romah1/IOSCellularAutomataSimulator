import XCTest
@testable import CellularAutomataSimulator

final class AutomataStateTests: XCTestCase {
    func testSubscript() {
        let state = ElementaryCelluralAutomataState(code: 0b00011110)
        XCTAssertEqual(state[Point(x: 3, y: 0)], .active)
        XCTAssertEqual(state[Point(x: 3, y: 1)], .inactive)
        XCTAssertEqual(state[Rect(
                                origin: Point(x: 2, y: 0),
                                size: Size(width: 2, height: 1)
        )], ElementaryCelluralAutomataState(code: 0b01, length: 2, origin: Point(x: 2, y: 0)))
        XCTAssertEqual(state[Rect(
                                origin: Point(x: 2, y: 0),
                                size: Size(width: 8, height: 1)
        )], ElementaryCelluralAutomataState(code: 0b01111000, length: 8, origin: Point(x: 2, y: 0)))
        state[Point(x: 3, y: 0)] = .inactive
        XCTAssertEqual(state[Point(x: 3, y: 0)], .inactive)
        state[Point(x: 3, y: 1)] = .active
        XCTAssertEqual(state[Point(x: 3, y: 1)], BinaryCell.inactive)
        state[Rect(
                origin: Point(x: 0, y: 0),
                size: Size(width: 12, height: 10)
        )] = ElementaryCelluralAutomataState(code: 0b11111111)
        XCTAssertEqual(state, ElementaryCelluralAutomataState(code: 0b11111111))
    }
    func testViewport() {
        let state = ElementaryCelluralAutomataState(code: 0b0011, length: 4)
        XCTAssertEqual(state.viewport, Rect(origin: Point(x: 0, y: 0), size: Size(width: 4, height: 1)))
        state.viewport = Rect(origin: Point(x: 1, y: 0), size: Size(width: 2, height: 1))
        let trueState = ElementaryCelluralAutomataState(code: 0b01, length: 2, origin: Point(x: 1, y: 0))
        XCTAssertEqual(state, trueState)
    }
}
