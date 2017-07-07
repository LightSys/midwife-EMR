'use strict';

require('./css/fonts.css');
require('./css/main.css');

var elm = require('./elm/Medical.elm');
var app = elm.Medical.embed(document.getElementById('app'));
