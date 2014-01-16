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
    , user: {
      id: req.session.userid
      // TODO: hardcode
      , username: 'kurt'
    }
  });
};

var execute = function(req, res) {
  res.render('searchResults', {
    title: 'Search Results'
    , user: {
      id: req.session.userid
      , username: 'kurt'
    }
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


