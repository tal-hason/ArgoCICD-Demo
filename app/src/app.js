var image = process.env.IMAGE
var tag = process.env.TAG
var host = process.env.HOSTNAME
var port = process.env.PORT || 8080;
var express = require('express');
const Prometheus = require('prom-client');
const register = new Prometheus.Registry();

app = express();

register.setDefaultLabels({
  app: 'hello-world Nodejs application'
})
Prometheus.collectDefaultMetrics({register})


const http_request_counter = new Prometheus.Counter({
  name: 'myapp_http_request_count',
  help: 'Count of HTTP requests made to my app',
  labelNames: ['method', 'route', 'statusCode'],
});
register.registerMetric(http_request_counter);


   
   
// Health Probe - Application Liveliness
app.get('/health/liveliness',function(req,res){
  console.log(`I am Alive`)
  res.status(200)
  res.send('Healty')
});
    
// Health Probe - Application Readiness
app.get('/health/readiness',function(req,res){
  console.log(`I am Ready`)
  res.status(200);
  res.send('Ready');
  });  

app.get('/', function (req, res) {

  var clientHostname = req.headers['x-forwarded-for'] || req.connection.remoteAddress;

  res.send(`Hello Openshift Commons!!,New Version, My Image is ${image}:${tag} , the Server is ${host} accessed from ${clientHostname} `);

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

app.get('/metrics', function(req, res)
{
    res.setHeader('Content-Type',register.contentType)

    register.metrics().then(data => res.status(200).send(data))
});

app.use(function(req, res, next)
{
    // Increment the HTTP request counter
    http_request_counter.labels({method: req.method, route: req.originalUrl, statusCode: res.statusCode}).inc();

    next();
});

app.listen(port, function () {
  console.log(`Example app listening on port ${port}!`);
});

