'use strict';

require('./css/fonts.css');
require('./css/main.css');
require('../vendor/mdl-themes/material.teal-lightgreen.min.css');

var comm = require('./js/comm');
var elm = require('./elm/Administrator.elm');
var app = elm.Administrator.embed(document.getElementById('app'));
comm.setApp(app);
