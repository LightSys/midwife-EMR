'use strict';

require('./css/fonts.css');
require('./css/main.css');
require('../../../node_modules/material-design-icons/iconfont/material-icons.css');
require('../vendor/mdl-themes/material.teal-lightgreen.min.css');

var comm = require('./js/comm');
var Elm = require('./elm/AdminMain.elm');
var app = Elm.AdminMain.embed(document.getElementById('app'));
comm.setApp(app);
