var image = process.env.IMAGE
var tag = process.env.TAG
var express = require('express');
app = express();

app.get('/', function (req, res) {
  res.send(`Hello Navy!, My Image is ${image}:${tag} `);
  console.log('Someone accessed me!')
});

app.listen(8080, function () {
  console.log('Example app listening on port 8080!');
});

