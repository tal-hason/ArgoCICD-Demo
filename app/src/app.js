var image = process.env.IMAGE
var tag = process.env.TAG
var express = require('express');
app = express();

app.get('/', function (req, res) {
  res.send(`Hello Everybody!, My Image is ${image}:${tag} `);
});

app.listen(8080, function () {
  console.log('Example app listening on port 8080!');
});

