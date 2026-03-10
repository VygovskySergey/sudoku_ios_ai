import Foundation

/// Local sudoku engine — Swift port of sudoku/sudoku.go.
/// Used as an offline fallback when the Go server is unreachable.
enum SudokuEngine {

    // MARK: - Core constraint check

    /// Returns true if placing `num` at (row, col) doesn't violate any constraint.
    /// The cell at (row, col) must be 0 (empty) when calling this.
    static func isValid(board: [[Int]], row: Int, col: Int, num: Int) -> Bool {
        for j in 0..<9 where board[row][j] == num { return false }
        for i in 0..<9 where board[i][col] == num { return false }
        let startRow = (row / 3) * 3, startCol = (col / 3) * 3
        for i in 0..<3 {
            for j in 0..<3 {
                if board[startRow + i][startCol + j] == num { return false }
            }
        }
        return true
    }

    // MARK: - Solver (backtracking)

    /// Solves the board in-place. Returns the solved board or nil if unsolvable.
    static func solve(board: [[Int]]) -> [[Int]]? {
        var b = board
        return solveInPlace(&b) ? b : nil
    }

    private static func solveInPlace(_ board: inout [[Int]]) -> Bool {
        for row in 0..<9 {
            for col in 0..<9 where board[row][col] == 0 {
                for num in 1...9 {
                    if isValid(board: board, row: row, col: col, num: num) {
                        board[row][col] = num
                        if solveInPlace(&board) { return true }
                        board[row][col] = 0
                    }
                }
                return false
            }
        }
        return true
    }

    // MARK: - Generator

    static func generate(difficulty: String) -> (puzzle: [[Int]], solution: [[Int]]) {
        var solution = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        _ = generateFull(&solution)

        var puzzle = solution
        let remove = cellsToRemove(difficulty)
        var positions = Array(0..<81)
        positions.shuffle()
        for i in 0..<remove {
            let pos = positions[i]
            puzzle[pos / 9][pos % 9] = 0
        }
        return (puzzle, solution)
    }

    private static func generateFull(_ board: inout [[Int]]) -> Bool {
        for row in 0..<9 {
            for col in 0..<9 where board[row][col] == 0 {
                var nums = Array(1...9)
                nums.shuffle()
                for num in nums {
                    if isValid(board: board, row: row, col: col, num: num) {
                        board[row][col] = num
                        if generateFull(&board) { return true }
                        board[row][col] = 0
                    }
                }
                return false
            }
        }
        return true
    }

    private static func cellsToRemove(_ difficulty: String) -> Int {
        switch difficulty {
        case "easy": return 30
        case "hard": return 55
        default:     return 45
        }
    }

    // MARK: - Move validation

    /// Checks if placing `value` at (row, col) is legal, temporarily clearing the cell first.
    static func isValidMove(board: [[Int]], row: Int, col: Int, value: Int) -> Bool {
        guard (0...8).contains(row), (0...8).contains(col), (1...9).contains(value) else {
            return false
        }
        var b = board
        b[row][col] = 0
        return isValid(board: b, row: row, col: col, num: value)
    }

    // MARK: - Completeness check

    /// Returns true when every cell is filled and no constraints are violated.
    static func isComplete(board: [[Int]]) -> Bool {
        for row in 0..<9 {
            for col in 0..<9 {
                if board[row][col] == 0 { return false }
            }
        }
        // Check rows
        for row in 0..<9 {
            var seen = Set<Int>()
            for col in 0..<9 {
                if !seen.insert(board[row][col]).inserted { return false }
            }
        }
        // Check columns
        for col in 0..<9 {
            var seen = Set<Int>()
            for row in 0..<9 {
                if !seen.insert(board[row][col]).inserted { return false }
            }
        }
        // Check 3x3 boxes
        for boxRow in 0..<3 {
            for boxCol in 0..<3 {
                var seen = Set<Int>()
                for i in 0..<3 {
                    for j in 0..<3 {
                        if !seen.insert(board[boxRow * 3 + i][boxCol * 3 + j]).inserted { return false }
                    }
                }
            }
        }
        return true
    }
}
