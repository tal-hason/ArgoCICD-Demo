var image = process.env.IMAGE
var tag = process.env.TAG
var host = process.env.HOSTNAME
var express = require('express');
app = express();

app.get('/', function (req, res) {
  res.send(`Hello new image, My Image is ${image}:${tag} , the Server is ${host} accessed from ${clientHostname} `);
  var clientHostname = req.headers.host;
  console.log(`Someone accessed me! from ${clientHostname}`)
});



app.listen(8080, function () {
  console.log('Example app listening on port 8080!');
});

