import React from 'react'
import {Route, IndexRoute} from 'react-router'

import App from './common/App'
import Home from './Home/Home'
import Search from './Search/Search'
import {
  UserList,
  UserEdit,
  UserPasswordReset
} from './User/User'
import NotAuthorized from './common/NotAuthorized'
import Login from './common/Login'

import {isAuthenticated} from './services/authentication'

// --------------------------------------------------------
// Check for proper authentication and authorization.
//
// Note: as of 2016-02-08 the history package has a bug that
// prevents using the onEnter API to go to '/'.
// https://github.com/rackt/react-router/issues/2960
// --------------------------------------------------------
const isApproved = (nextState, replace) => {
  // TEMP
  return true
  if (! isAuthenticated()) {
    replace(Object.assign({}, nextState.location, {'pathname': '/login'}))
  }

  // TODO: check authentication here.
}

export default (
  <Route path='/' component={App} >
    <IndexRoute component={Home} />
    <Route path='user/:id' component={UserEdit} />
    <Route path='user/:id/resetpassword' component={UserPasswordReset} />
    <Route path='users' component={UserList} />
    <Route path='logout' component={Home} />
    <Route path='search' component={Search} />
    <Route path='profile' component={UserEdit} onEnter={isApproved}/>
    <Route path='notauthorized' component={NotAuthorized} />
    <Route path='login' component={Login} />
  </Route>
)

