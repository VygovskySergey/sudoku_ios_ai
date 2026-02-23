import Foundation

@MainActor
class SudokuGame: ObservableObject {

    struct Cell {
        var value: Int       // 0 = empty
        var isGiven: Bool    // pre-filled by puzzle
        var isError: Bool    // user entered, validation failed
    }

    @Published var cells: [[Cell]] = []
    @Published var selectedRow: Int? = nil
    @Published var selectedCol: Int? = nil
    @Published var isComplete: Bool = false
    @Published var isLoading: Bool = false
    @Published var difficulty: String = "medium"

    init() { initEmpty() }

    // MARK: - Board setup

    func initEmpty() {
        cells = Array(
            repeating: Array(repeating: Cell(value: 0, isGiven: false, isError: false), count: 9),
            count: 9
        )
    }

    func loadPuzzle(board: [[Int]], solution: [[Int]]) {
        isComplete  = false
        selectedRow = nil
        selectedCol = nil
        cells = (0..<9).map { row in
            (0..<9).map { col in
                let v = board[row][col]
                return Cell(value: v, isGiven: v != 0, isError: false)
            }
        }
    }

    // MARK: - Game interaction

    func selectCell(row: Int, col: Int) {
        selectedRow = row
        selectedCol = col
    }

    /// Returns a snapshot of the board as a 9×9 Int array.
    var currentBoard: [[Int]] {
        cells.map { row in row.map { $0.value } }
    }

    func enterValue(_ value: Int) {
        guard let row = selectedRow, let col = selectedCol else { return }
        guard !cells[row][col].isGiven else { return }
        cells[row][col].value = value
        cells[row][col].isError = false
    }

    func clearCell() {
        guard let row = selectedRow, let col = selectedCol else { return }
        guard !cells[row][col].isGiven else { return }
        cells[row][col].value = 0
        cells[row][col].isError = false
    }

    func markCell(row: Int, col: Int, isError: Bool) {
        cells[row][col].isError = isError
    }

    func applyServerSolution(_ board: [[Int]]) {
        for row in 0..<9 {
            for col in 0..<9 where !cells[row][col].isGiven {
                cells[row][col].value = board[row][col]
                cells[row][col].isError = false
            }
        }
        isComplete = true
    }

    // MARK: - Highlight helpers

    func isHighlighted(row: Int, col: Int) -> Bool {
        guard let selRow = selectedRow, let selCol = selectedCol else { return false }
        return row == selRow
            || col == selCol
            || (row / 3 == selRow / 3 && col / 3 == selCol / 3)
    }

    func isSelected(row: Int, col: Int) -> Bool {
        selectedRow == row && selectedCol == col
    }
}
