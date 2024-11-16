const express = require('express');
const app = express();

app.get('/trivia', (req, res) => {
  res.json({ question: "What is the capital of France?", options: ["Paris", "London", "Berlin", "Madrid"] });
});

const port = 3000;
app.listen(port, () => {
  console.log(`Trivia app backend listening at http://localhost:${port}`);
});
