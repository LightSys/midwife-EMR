'use strict';

require('./css/fonts.css');
require('../vendor/blaze.min.css');
require('./css/main.css');

var elm = require('./elm/Medical.elm');
var node = document.getElementById('app');
var pregId = node.getAttribute('data-pregId');
var app = elm.Medical.embed(node, {pregId: pregId});
