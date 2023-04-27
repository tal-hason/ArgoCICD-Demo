var image = process.env.IMAGE
var tag = process.env.TAG
var host = process.env.HOSTNAME
var express = require('express');
app = express();

app.get('/', function (req, res) {

  var clientHostname = req.headers['x-forwarded-for'] || req.connection.remoteAddress;

  res.send(`Hello Red Hat!!,New Version, My Image is ${image}:${tag} , the Server is ${host} accessed from ${clientHostname} `);

  console.log(`Someone accessed me! --> from ${clientHostname}`)
});

app.get('/test1', function (req, res) {

  res.send(`This is Test1, All Good`);

  console.log(`Someone accessed Test1 Path!`)
});

app.get('/test2', function (req, res) {

  res.send(`This is Test2, All Good`);

  console.log(`Someone accessed Test2 Path!`)
});

app.listen(8080, function () {
  console.log('Example app listening on port 8080!');
});

