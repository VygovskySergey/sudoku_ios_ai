package main

import (
	"log"
	"net/http"
	"os"

	"sudoku-api/api"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/api/v1/health", api.HealthHandler)
	mux.HandleFunc("/api/v1/puzzle", api.PuzzleHandler)
	mux.HandleFunc("/api/v1/validate", api.ValidateHandler)
	mux.HandleFunc("/api/v1/solve", api.SolveHandler)

	log.Printf("Sudoku API listening on :%s", port)
	if err := http.ListenAndServe(":"+port, cors(mux)); err != nil {
		log.Fatal(err)
	}
}

// cors adds permissive CORS headers required by mobile/web clients.
func cors(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}
