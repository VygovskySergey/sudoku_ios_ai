# Sudoku iOS

A SwiftUI Sudoku app with an optional Go REST API backend. Works fully offline — if the server is unreachable, the app falls back to a built-in Swift sudoku engine.

## Features

- 9x9 Sudoku board with tap-to-select cells and number pad input
- Three difficulty levels: Easy (30 removed), Medium (45), Hard (55)
- Cell highlighting for selected cell, same row/col/box, and matching values
- Move validation with error counter (3 errors = game over)
- Auto-solve button
- Offline fallback — puzzle generation, validation, and solving all work without the server

## Project Structure

```
SudokuApp/
├── SudokuApp.swift         # @main entry point
├── ContentView.swift       # Main screen: picker, board, numpad, buttons, alerts
├── SudokuGame.swift        # Game state model (ObservableObject)
├── BoardView.swift         # 9x9 grid with canvas overlay
├── NumberPadView.swift     # Adaptive 1-9 + erase buttons
├── APIService.swift        # HTTP client with offline fallback
├── SudokuEngine.swift      # Local sudoku logic (generate, solve, validate)
├── Info.plist
└── Assets.xcassets/

api/handlers.go             # REST handlers
sudoku/sudoku.go            # Go sudoku engine
main.go                     # Go server entry point (port 8080)
```

## Running

### iOS App Only (Offline Mode)

Open `SudokuApp.xcodeproj` in Xcode and run on a simulator or device. The app works fully offline using the built-in Swift engine.

### With Go Backend

```bash
go run main.go
```

The server starts on `localhost:8080`. The iOS app will use it when available, falling back to local logic on any network error.

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/health` | Health check |
| GET | `/api/v1/puzzle?difficulty=easy\|medium\|hard` | Generate a puzzle |
| POST | `/api/v1/validate` | Validate a move |
| POST | `/api/v1/solve` | Solve a board |
