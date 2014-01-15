/* 
 * -------------------------------------------------------------------------------
 * index.js
 *
 * Mercy - maternal care and patient management.
 * ------------------------------------------------------------------------------- 
 */

var express = require('express')
  , cons = require('consolidate')
  , app = express()
  , port = 3000
  , patient = require('./lib/index.js').patient
  ;

app.engine('jade', cons.jade);
app.set('view engine', 'jade');
app.set('views', __dirname + '/views');

app.use(express.static('bower_components'));

app.get('/', function(req, res) {
  res.render('content', {
    title: 'Testing'
  });
});

app.get('/first', function(req, res) {
  patient.getFirst(function(err, p) {
    if (err) console.log(err);
    var data = {
      title: 'First patient'
      , patient: p
    };
    res.render('content', data);
  });

});

app.listen(port);
console.log('Server listening on port ' + port);


