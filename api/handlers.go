package api

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"time"

	"sudoku-api/sudoku"
)

// ---------- request / response types ----------

type PuzzleResponse struct {
	ID         string       `json:"id"`
	Board      sudoku.Board `json:"board"`
	Solution   sudoku.Board `json:"solution"`
	Difficulty string       `json:"difficulty"`
	CreatedAt  time.Time    `json:"created_at"`
}

type ValidateRequest struct {
	Board sudoku.Board `json:"board"`
	Row   int          `json:"row"`
	Col   int          `json:"col"`
	Value int          `json:"value"`
}

type ValidateResponse struct {
	Valid      bool   `json:"valid"`
	Complete   bool   `json:"complete"`
	Message    string `json:"message,omitempty"`
}

type SolveRequest struct {
	Board sudoku.Board `json:"board"`
}

type SolveResponse struct {
	Solved bool         `json:"solved"`
	Board  sudoku.Board `json:"board,omitempty"`
}

type ErrorResponse struct {
	Error string `json:"error"`
}

// ---------- helpers ----------

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, ErrorResponse{Error: msg})
}

func newID() string {
	return fmt.Sprintf("%d-%d", time.Now().UnixNano(), rand.Intn(1_000_000))
}

// ---------- handlers ----------

// HealthHandler godoc
// GET /api/v1/health
func HealthHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{
		"status": "ok",
		"time":   time.Now().UTC().Format(time.RFC3339),
	})
}

// PuzzleHandler godoc
// GET /api/v1/puzzle?difficulty=easy|medium|hard
func PuzzleHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	difficulty := r.URL.Query().Get("difficulty")
	switch difficulty {
	case "easy", "medium", "hard":
	case "":
		difficulty = "medium"
	default:
		writeError(w, http.StatusBadRequest, "difficulty must be easy, medium, or hard")
		return
	}

	puzzle, solution := sudoku.Generate(difficulty)

	writeJSON(w, http.StatusOK, PuzzleResponse{
		ID:         newID(),
		Board:      puzzle,
		Solution:   solution,
		Difficulty: difficulty,
		CreatedAt:  time.Now().UTC(),
	})
}

// ValidateHandler godoc
// POST /api/v1/validate
// Body: { "board": [[...]], "row": 0, "col": 0, "value": 5 }
func ValidateHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	var req ValidateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid JSON body")
		return
	}

	if !sudoku.IsValidBoard(&req.Board) {
		writeJSON(w, http.StatusOK, ValidateResponse{
			Valid:    false,
			Complete: false,
			Message:  "board already contains conflicts",
		})
		return
	}

	valid := sudoku.IsValidMove(&req.Board, req.Row, req.Col, req.Value)
	if !valid {
		writeJSON(w, http.StatusOK, ValidateResponse{
			Valid:    false,
			Complete: false,
			Message:  "move conflicts with row, column, or box",
		})
		return
	}

	// Apply the move to check for completion.
	req.Board[req.Row][req.Col] = req.Value
	complete := sudoku.IsComplete(&req.Board)

	writeJSON(w, http.StatusOK, ValidateResponse{
		Valid:    true,
		Complete: complete,
	})
}

// SolveHandler godoc
// POST /api/v1/solve
// Body: { "board": [[...]] }
func SolveHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		return
	}

	var req SolveRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid JSON body")
		return
	}

	if !sudoku.IsValidBoard(&req.Board) {
		writeError(w, http.StatusBadRequest, "board contains conflicts and cannot be solved")
		return
	}

	board := req.Board
	solved := sudoku.Solve(&board)

	writeJSON(w, http.StatusOK, SolveResponse{
		Solved: solved,
		Board:  board,
	})
}
