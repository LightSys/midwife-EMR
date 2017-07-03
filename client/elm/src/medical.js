'use strict';

require('./css/fonts.css');
require('./css/main.css');
//require('../vendor/mdl-themes/material.teal-lightgreen.min.css');

var comm = require('./js/comm');
var elm = require('./elm/Medical.elm');
var app = elm.Main.embed(document.getElementById('app'));
comm.setApp(app);
