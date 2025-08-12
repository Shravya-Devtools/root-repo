const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello from Node.js app running in Docker container!');
});

app.listen(3000, () => {
  console.log('Server listening on port 3000');
});
