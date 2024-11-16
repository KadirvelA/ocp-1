const express = require('express');
const app = express();
const port = 8080; // Default port for backend

// Dummy questions for the Trivia App
const questions = [
  { question: 'What is the capital of France?', options: ['Paris', 'Berlin', 'Madrid'], answer: 'Paris' },
  { question: 'What is 2 + 2?', options: ['3', '4', '5'], answer: '4' },
  { question: 'Who wrote "Hamlet"?', options: ['Shakespeare', 'Hemingway', 'Tolkien'], answer: 'Shakespeare' },
];

// Route to serve trivia questions
app.get('/api/questions', (req, res) => {
  res.json(questions);
});

// Default route
app.get('/', (req, res) => {
  res.send('Welcome to the Trivia App Backend');
});

// Start the server
app.listen(port, () => {
  console.log(`Backend running on http://localhost:${port}`);
});
