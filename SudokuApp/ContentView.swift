import SwiftUI

struct ContentView: View {
    @StateObject private var game = SudokuGame()

    @State private var showingCompletion = false
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                difficultyPicker

                if game.isLoading {
                    Spacer()
                    ProgressView("Loading puzzle…")
                    Spacer()
                } else {
                    BoardView(game: game) { row, col in
                        game.selectCell(row: row, col: col)
                    }
                    .padding(.horizontal, 4)

                    NumberPadView(
                        onNumber: { enterValue($0) },
                        onErase:  { game.clearCell() }
                    )

                    actionButtons
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Sudoku")
            .navigationBarTitleDisplayMode(.large)
            .alert("Puzzle Complete!", isPresented: $showingCompletion) {
                Button("New Game") { newGame() }
                Button("OK", role: .cancel) {}
            } message: {
                Text("Congratulations! You solved the puzzle.")
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
        .task { await loadPuzzle() }
    }

    // MARK: - Subviews

    private var difficultyPicker: some View {
        Picker("Difficulty", selection: $game.difficulty) {
            Text("Easy").tag("easy")
            Text("Medium").tag("medium")
            Text("Hard").tag("hard")
        }
        .pickerStyle(.segmented)
        .onChange(of: game.difficulty) { _, _ in newGame() }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button { newGame() } label: {
                Label("New Game", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button { solveGame() } label: {
                Label("Solve", systemImage: "lightbulb")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.orange)
        }
    }

    // MARK: - Actions

    private func newGame() {
        Task { await loadPuzzle() }
    }

    private func loadPuzzle() async {
        game.isLoading = true
        defer { game.isLoading = false }
        do {
            let response = try await APIService.shared.fetchPuzzle(difficulty: game.difficulty)
            game.loadPuzzle(board: response.board, solution: response.solution)
        } catch {
            showError(error.localizedDescription)
        }
    }

    private func enterValue(_ value: Int) {
        guard let row = game.selectedRow, let col = game.selectedCol else { return }
        guard !game.cells[row][col].isGiven else { return }

        game.enterValue(value)
        let board = game.currentBoard

        Task {
            do {
                let result = try await APIService.shared.validate(
                    board: board, row: row, col: col, value: value
                )
                game.markCell(row: row, col: col, isError: !result.valid)
                if result.complete { showingCompletion = true }
            } catch {
                // Leave the value shown; validation is best-effort
            }
        }
    }

    private func solveGame() {
        Task {
            do {
                let result = try await APIService.shared.solve(board: game.currentBoard)
                if result.solved, let board = result.board {
                    game.applyServerSolution(board)
                    showingCompletion = true
                } else {
                    showError("Could not solve the current puzzle.")
                }
            } catch {
                showError(error.localizedDescription)
            }
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
