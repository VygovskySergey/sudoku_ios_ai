package sudoku

import "math/rand"

// Board is a 9x9 Sudoku grid. Zero means empty cell.
type Board [9][9]int

// isValid checks if placing num at (row, col) is legal.
func isValid(board *Board, row, col, num int) bool {
	for j := 0; j < 9; j++ {
		if board[row][j] == num {
			return false
		}
	}
	for i := 0; i < 9; i++ {
		if board[i][col] == num {
			return false
		}
	}
	startRow, startCol := (row/3)*3, (col/3)*3
	for i := 0; i < 3; i++ {
		for j := 0; j < 3; j++ {
			if board[startRow+i][startCol+j] == num {
				return false
			}
		}
	}
	return true
}

// Solve fills all empty cells using backtracking. Returns true if solved.
func Solve(board *Board) bool {
	for row := 0; row < 9; row++ {
		for col := 0; col < 9; col++ {
			if board[row][col] == 0 {
				for num := 1; num <= 9; num++ {
					if isValid(board, row, col, num) {
						board[row][col] = num
						if Solve(board) {
							return true
						}
						board[row][col] = 0
					}
				}
				return false
			}
		}
	}
	return true
}

// generateFull fills the board with a valid complete solution using random backtracking.
func generateFull(board *Board) bool {
	for row := 0; row < 9; row++ {
		for col := 0; col < 9; col++ {
			if board[row][col] == 0 {
				nums := rand.Perm(9)
				for _, n := range nums {
					num := n + 1
					if isValid(board, row, col, num) {
						board[row][col] = num
						if generateFull(board) {
							return true
						}
						board[row][col] = 0
					}
				}
				return false
			}
		}
	}
	return true
}

// cellsToRemove returns how many cells to blank out per difficulty.
func cellsToRemove(difficulty string) int {
	switch difficulty {
	case "easy":
		return 30
	case "hard":
		return 55
	default: // medium
		return 45
	}
}

// Generate creates a puzzle and its solution for the given difficulty.
func Generate(difficulty string) (puzzle Board, solution Board) {
	generateFull(&solution)
	puzzle = solution

	positions := rand.Perm(81)
	for i := 0; i < cellsToRemove(difficulty); i++ {
		row, col := positions[i]/9, positions[i]%9
		puzzle[row][col] = 0
	}
	return puzzle, solution
}

// IsValidMove checks if placing value at (row, col) is legal on the board.
func IsValidMove(board *Board, row, col, value int) bool {
	if row < 0 || row > 8 || col < 0 || col > 8 || value < 1 || value > 9 {
		return false
	}
	// Temporarily clear the cell so we don't conflict with its own current value.
	prev := board[row][col]
	board[row][col] = 0
	valid := isValid(board, row, col, value)
	board[row][col] = prev
	return valid
}

// IsValidBoard checks the board has no rule violations (ignores empty cells).
func IsValidBoard(board *Board) bool {
	for row := 0; row < 9; row++ {
		var seen [10]bool
		for col := 0; col < 9; col++ {
			v := board[row][col]
			if v == 0 {
				continue
			}
			if seen[v] {
				return false
			}
			seen[v] = true
		}
	}
	for col := 0; col < 9; col++ {
		var seen [10]bool
		for row := 0; row < 9; row++ {
			v := board[row][col]
			if v == 0 {
				continue
			}
			if seen[v] {
				return false
			}
			seen[v] = true
		}
	}
	for boxRow := 0; boxRow < 3; boxRow++ {
		for boxCol := 0; boxCol < 3; boxCol++ {
			var seen [10]bool
			for i := 0; i < 3; i++ {
				for j := 0; j < 3; j++ {
					v := board[boxRow*3+i][boxCol*3+j]
					if v == 0 {
						continue
					}
					if seen[v] {
						return false
					}
					seen[v] = true
				}
			}
		}
	}
	return true
}

// IsComplete returns true when every cell is filled and the board is valid.
func IsComplete(board *Board) bool {
	for row := 0; row < 9; row++ {
		for col := 0; col < 9; col++ {
			if board[row][col] == 0 {
				return false
			}
		}
	}
	return IsValidBoard(board)
}
