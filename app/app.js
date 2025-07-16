const express = require('express');
const app = express();
const port = 3000;
const os = require('os');

app.get('/', (req, res) => {
  console.log('Request received at root');
  res.send(`Hello from the Private Backend Server! My Private IP is: ${os.networkInterfaces()['eth0'][0].address}`);
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});