package main

import (
	"encoding/json"
		"math/rand"
			"net/http"
				"time"
			)

			type Question struct {
				Question string   `json:"question"`
					Options  []string `json:"options"`
						Answer   int      `json:"answer"` // Index of the correct answer
					}

					var questions = []Question{
						{"What is the capital of France?", []string{"Paris", "Berlin", "Madrid", "Rome"}, 0},
								{"What is 5 + 3?", []string{"5", "8", "12", "15"}, 1},
										{"Who wrote '1984'?", []string{"George Orwell", "Mark Twain", "J.K. Rowling", "Ernest Hemingway"}, 0},
										}

										func main() {
											rand.Seed(time.Now().UnixNano())

												http.HandleFunc("/api/questions", func(w http.ResponseWriter, r *http.Request) {
														w.Header().Set("Content-Type", "application/json")
																json.NewEncoder(w).Encode(questions)
																	})

																		http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
																				http.ServeFile(w, r, "./index.html")
																					})

																						http.ListenAndServe(":8080", nil)
																					}
																					EOF

																					# backend/index.html
																					cat << 'EOF' > $BASE_DIR/backend/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Trivia Quest</title>
  <style>
    body { font-family: Arial, sans-serif; text-align: center; padding: 20px; }
    button { padding: 10px 20px; margin: 10px; font-size: 18px; cursor: pointer; }
  </style>
</head>
<body>
  <h1>Welcome to Trivia Quest!</h1>
  <div id="app">
    <button onclick="startQuiz()">Start Quiz</button>
  </div>
  <script>
    let currentQuestion = 0;
    let score = 0;
    let questions = [];

    function startQuiz() {
      fetch('/api/questions')
        .then(res => res.json())
        .then(data => {
          questions = data;
          showQuestion();
        });
    }

    function showQuestion() {
      if (currentQuestion >= questions.length) {
        document.getElementById('app').innerHTML = `<h2>Your Score: ${score}/${questions.length}</h2>
          <button onclick="startQuiz()">Play Again</button>`;
        return;
      }

      const q = questions[currentQuestion];
      document.getElementById('app').innerHTML = `
        <h2>${q.question}</h2>
        ${q.options.map((opt, i) => `<button onclick="checkAnswer(${i})">${opt}</button>`).join('')}
      `;
    }

    function checkAnswer(selected) {
      if (questions[currentQuestion].answer === selected) score++;
      currentQuestion++;
      showQuestion();
    }
  </script>
</body>
</html>
