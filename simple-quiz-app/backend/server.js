const express = require('express');
const app = express();

app.get('/quiz', (req, res) => {
  res.json({
    question: "What is the capital of Japan?",
    options: ["Tokyo", "Beijing", "Seoul", "Bangkok"]
  });
});

const port = 3000;
app.listen(port, () => {
  console.log(`Quiz backend is running on http://localhost:${port}`);
});
