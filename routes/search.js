/* 
 * -------------------------------------------------------------------------------
 * search.js
 *
 * Functionality for searches.
 * ------------------------------------------------------------------------------- 
 */

var view = function(req, res) {
  res.render('search', {
    title: 'Search'
    , user: req.session.user
  });
};

var execute = function(req, res) {
  res.render('searchResults', {
    title: 'Search Results'
    , user: req.session.user
    , results: [
      'Jane Doe'
      , 'Christy Smith'
      , 'Laney Woo'
    ]
  });
};


module.exports = {
  view: view
  , execute: execute
};


