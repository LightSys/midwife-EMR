/*
 * -------------------------------------------------------------------------------
 * NewbornExam.js
 *
 * The model for the newbornExam table.
 * -------------------------------------------------------------------------------
 */

var moment = require('moment')
  , Promise = require('bluebird')
    // Default settings used unless Bookshelf already initialized.
  , dbSettings = require('../config').database
  , Bookshelf = (require('bookshelf').DB || require('./DB').init(dbSettings))
  , NewbornExam = {}
  , NewbornExams
  ;

/*
CREATE TABLE `newbornExam` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `examDatetime` datetime NOT NULL,
  `examiners` varchar(50) NOT NULL,
  `rr` int(11) DEFAULT NULL,
  `hr` int(11) DEFAULT NULL,
  `temperature` decimal(4,1) DEFAULT NULL,
  `length` int(11) DEFAULT NULL,
  `headCir` int(11) DEFAULT NULL,
  `chestCir` int(11) DEFAULT NULL,
  `appearance` varchar(500) DEFAULT NULL,
  `color` varchar(500) DEFAULT NULL,
  `skin` varchar(500) DEFAULT NULL,
  `head` varchar(500) DEFAULT NULL,
  `eyes` varchar(500) DEFAULT NULL,
  `ears` varchar(500) DEFAULT NULL,
  `nose` varchar(500) DEFAULT NULL,
  `mouth` varchar(500) DEFAULT NULL,
  `neck` varchar(500) DEFAULT NULL,
  `chest` varchar(500) DEFAULT NULL,
  `lungs` varchar(500) DEFAULT NULL,
  `heart` varchar(500) DEFAULT NULL,
  `abdomen` varchar(500) DEFAULT NULL,
  `hips` varchar(500) DEFAULT NULL,
  `cord` varchar(500) DEFAULT NULL,
  `femoralPulses` varchar(500) DEFAULT NULL,
  `genitalia` varchar(500) DEFAULT NULL,
  `anus` varchar(500) DEFAULT NULL,
  `back` varchar(500) DEFAULT NULL,
  `extremities` varchar(500) DEFAULT NULL,
  `estGA` varchar(50) DEFAULT NULL,
  `moroReflex` tinyint(1) DEFAULT NULL,
  `moroReflexComment` varchar(50) DEFAULT NULL,
  `palmarReflex` tinyint(1) DEFAULT NULL,
  `palmarReflexComment` varchar(50) DEFAULT NULL,
  `steppingReflex` tinyint(1) DEFAULT NULL,
  `steppingReflexComment` varchar(50) DEFAULT NULL,
  `plantarReflex` tinyint(1) DEFAULT NULL,
  `plantarReflexComment` varchar(50) DEFAULT NULL,
  `babinskiReflex` tinyint(1) DEFAULT NULL,
  `babinskiReflexComment` varchar(50) DEFAULT NULL,
  `comments` varchar(300) DEFAULT NULL,
  `updatedBy` int(11) NOT NULL,
  `updatedAt` datetime NOT NULL,
  `supervisor` int(11) DEFAULT NULL,
  `baby_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `baby_id` (`baby_id`),
  KEY `updatedBy` (`updatedBy`),
  CONSTRAINT `newbornExam_ibfk_1` FOREIGN KEY (`baby_id`) REFERENCES `baby` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `newbornExam_ibfk_2` FOREIGN KEY (`updatedBy`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1
 */

NewbornExam = Bookshelf.Model.extend({
  tableName: 'newbornExam'

  , permittedAttributes: ['id', 'examDatetime', 'examiners', 'rr', 'hr',
    'temperature', 'length', 'headCir', 'chestCir', 'appearance', 'color',
    'skin', 'head', 'eyes', 'ears', 'nose', 'mouth', 'neck', 'chest', 'lungs',
    'heart', 'abdomen', 'hips', 'cord', 'femoralPulses', 'genitalia', 'anus',
    'back', 'extremities', 'estGA', 'moroReflex', 'moroReflexComment',
    'palmarReflex', 'palmarReflexComment', 'steppingReflex', 'steppingReflexComment',
    'plantarReflex', 'plantarReflexComment', 'babinskiReflex',
    'babinskiReflexComment', 'comments', 'updatedBy', 'updatedAt', 'supervisor',
    'baby_id']

  , initialize: function() {
    this.on('saving', this.saving, this);
    }

  , saving: function(model) {
      // Enforce permittedAttributes.
      Bookshelf.Model.prototype.saving.apply(this, model);
    }

  // --------------------------------------------------------
  // Relationships
  //
  // Note: avoid circular references by using require() inline.
  // https://github.com/tgriesser/bookshelf/issues/105
  // --------------------------------------------------------

  , baby: function() {
      return this.belongsTo(require('./Baby').Labor, 'baby_id');
    }

}, {
  // --------------------------------------------------------
  // Class Properties.
  // --------------------------------------------------------

});

NewbornExams = Bookshelf.Collection.extend({
  model: NewbornExam
});

module.exports = {
  NewbornExam: NewbornExam
  , NewbornExams: NewbornExams
};

