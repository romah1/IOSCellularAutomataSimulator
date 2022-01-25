import XCTest
@testable import CellularAutomataSimulator

final class TwoDimentionalAutomataTests: XCTestCase {
    func testSimulateFromEmpty() {
        let automata = TwoDimentionCelluralAutomata()
        let state = TwoDimentionCelluralAutomataState(field: [])
        let newState = try? automata.simulate(state, generations: 10)
        XCTAssertEqual(state, newState)
    }
    func testStateSimutaleFromNotEmpty() {
        let state = TwoDimentionCelluralAutomataState(field: [Array(repeating: .active, count: 3)])
        let automata = TwoDimentionCelluralAutomata()
        let newState = try? automata.simulate(state, generations: 1)
        XCTAssertEqual(newState, TwoDimentionCelluralAutomataState(
            field: Array(repeating: [.inactive, .active, .inactive], count: 3),
            origin: Point(x: 0, y: -1)
        ))
    }
}
