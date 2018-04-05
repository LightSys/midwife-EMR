/*
 * -------------------------------------------------------------------------------
 * index.js
 *
 * All routing modules are exported here.
 * -------------------------------------------------------------------------------
 */
module.exports = {
  home: require('./home')
  , error: require('./error')
  , search: require('./search')
  , users: require('./users')
  , roles: require('./roles')
  , pregnancy: require('./pregnancy')
  , referral: require('./referral')
  , pregnote: require('./pregnote')
  , labs: require('./labs')
  , pregnancyHistory: require('./pregnancyHistory')
  , prenatalExam: require('./prenatalExam')
  , vaccination: require('./vaccination')
  , medication: require('./medication')
  , checkInOut: require('./checkInOut')
  , report: require('./report')
  , dewormingRpt: require('./dewormingRpt')
  , priorityList: require('./priorityList')
  , summaryRpt: require('./summaryRpt')
  , dohMasterListRpt: require('./dohMasterListRpt')
  , philHealthDailyRpt: require('./philHealthDailyRpt')
  , teaching: require('./teaching')
  , inactiveRpt: require('./inactiveRpt')
  , invWork: require('./invWork')
  , generateBarcodes: require('./barcodes').generateBarcodes
  , vitaminARpt: require('./vitaminARpt')
  , birthCertificateRpt: require('./birthCertificateRpt')
  , bcgRpt: require('./bcgRpt')
  , hepbRpt: require('./hepbRpt')
};
