import Foundation

// MARK: - Response types

struct PuzzleResponse: Codable {
    let id: String
    let board: [[Int]]
    let solution: [[Int]]
    let difficulty: String
}

struct ValidateResponse: Codable {
    let valid: Bool
    let complete: Bool
    let message: String?
}

struct SolveResponse: Codable {
    let solved: Bool
    let board: [[Int]]?
}

// MARK: - Request types

private struct ValidateRequest: Encodable {
    let board: [[Int]]
    let row: Int
    let col: Int
    let value: Int
}

private struct SolveRequest: Encodable {
    let board: [[Int]]
}

// MARK: - Errors

enum APIError: LocalizedError {
    case badURL
    case serverUnreachable

    var errorDescription: String? {
        switch self {
        case .badURL:             return "Invalid server URL."
        case .serverUnreachable:  return "Cannot reach the server. Make sure it is running on localhost:8080."
        }
    }
}

// MARK: - Service

final class APIService {
    static let shared = APIService()
    private init() {}

    private let base = "http://localhost:8080/api/v1"
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    func fetchPuzzle(difficulty: String) async throws -> PuzzleResponse {
        do {
            guard let url = URL(string: "\(base)/puzzle?difficulty=\(difficulty)") else {
                throw APIError.badURL
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            return try decoder.decode(PuzzleResponse.self, from: data)
        } catch is URLError {
            let (puzzle, solution) = SudokuEngine.generate(difficulty: difficulty)
            return PuzzleResponse(id: UUID().uuidString, board: puzzle, solution: solution, difficulty: difficulty)
        }
    }

    func validate(board: [[Int]], row: Int, col: Int, value: Int) async throws -> ValidateResponse {
        do {
            guard let url = URL(string: "\(base)/validate") else { throw APIError.badURL }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try encoder.encode(ValidateRequest(board: board, row: row, col: col, value: value))
            let (data, _) = try await URLSession.shared.data(for: req)
            return try decoder.decode(ValidateResponse.self, from: data)
        } catch is URLError {
            let valid = SudokuEngine.isValidMove(board: board, row: row, col: col, value: value)
            var checkBoard = board
            checkBoard[row][col] = value
            let complete = valid && SudokuEngine.isComplete(board: checkBoard)
            let message = valid ? (complete ? "Puzzle complete!" : "Valid move.") : "Invalid move."
            return ValidateResponse(valid: valid, complete: complete, message: message)
        }
    }

    func solve(board: [[Int]]) async throws -> SolveResponse {
        do {
            guard let url = URL(string: "\(base)/solve") else { throw APIError.badURL }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try encoder.encode(SolveRequest(board: board))
            let (data, _) = try await URLSession.shared.data(for: req)
            return try decoder.decode(SolveResponse.self, from: data)
        } catch is URLError {
            if let solved = SudokuEngine.solve(board: board) {
                return SolveResponse(solved: true, board: solved)
            }
            return SolveResponse(solved: false, board: nil)
        }
    }
}
