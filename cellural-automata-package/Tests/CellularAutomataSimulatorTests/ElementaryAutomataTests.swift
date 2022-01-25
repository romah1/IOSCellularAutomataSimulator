import XCTest
@testable import CellularAutomataSimulator

final class ElementaryAutomataTests: XCTestCase {
    func testEmptySimulateFromEmpty() {
        let automata = ElementaryCelluralAutomata(ruleCode: 110)
        let state = ElementaryCelluralAutomataState()
        XCTAssertEqual(state, ElementaryCelluralAutomataState())
        let newState = try? automata.simulate(state, generations: 1)
        XCTAssertEqual(state, ElementaryCelluralAutomataState())
        XCTAssertEqual(newState, ElementaryCelluralAutomataState(code: 0b00, length: 2, origin: Point(x: -1, y: 0)))
    }
    func testSimulateNotEmpty() {
        let automata = ElementaryCelluralAutomata(ruleCode: 0b00000001)
        let state = ElementaryCelluralAutomataState(code: 0b0000, length: 4)
        let newState = try? automata.simulate(state, generations: 1)
        let trueNewState = ElementaryCelluralAutomataState(field: [
            Array(repeating: BinaryCell.inactive, count: 6),
            Array(repeating: BinaryCell.active, count: 6)
        ], origin: Point(x: -1, y: 0))
        XCTAssertEqual(newState, trueNewState)
    }
}
