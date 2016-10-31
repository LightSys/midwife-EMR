'use strict';

require('./css/fonts.css');
require('../../../node_modules/material-design-icons/iconfont/material-icons.css');
require('../vendor/mdl-themes/material.teal-lightgreen.min.css');

var Elm = require('./elm/AdminMain.elm');
Elm.AdminMain.embed(document.getElementById('app'));
