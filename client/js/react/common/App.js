import React, {Component, PropTypes} from 'react'
import {connect} from 'react-redux'
import {Link} from 'react-router'

import TopMenu from './TopMenu'
import Notification from './Notification'
import {routeChange} from '../actions/Route'
import {
  cookies,
  initAuthenticated,
  initUserId
} from '../services/authentication'
import {setServerInfo} from '../actions/ServerInfo'

// Holds configuration data passed from the outside on initial load.
let cfgData
let cfgToken

class App extends Component {
  constructor(props) {
    super(props)
    this.render = this.render.bind(this)

    // --------------------------------------------------------
    // Get configuration data passed in from the outside.
    // --------------------------------------------------------
    const root = document.getElementById('root')
    cfgData = JSON.parse(root.getAttribute('data-cfg'))

    // --------------------------------------------------------
    // Set the cookies in the store that are needed.
    // --------------------------------------------------------
    cookies(cfgData.cookies)

    // --------------------------------------------------------
    // Store whether the server considers the client authenticated.
    // --------------------------------------------------------
    initAuthenticated(cfgData.isAuthenticated)

    // --------------------------------------------------------
    // Set the current user id as set by the server.
    // --------------------------------------------------------
    initUserId(cfgData.userId)

    // --------------------------------------------------------
    // Store whatever else the server sent us.
    // --------------------------------------------------------
    this.props.setServerInfo(cfgData.serverInfo)
  }

  // --------------------------------------------------------
  // Handle route change which means that a new route was
  // requested somewhere else in the app via the Redux route
  // state, for example, maybe a Saga.
  // --------------------------------------------------------
  componentWillReceiveProps(nextProps) {
    if (nextProps.route && nextProps.route === this.props.route) {
      // --------------------------------------------------------
      // The new route is not empty but has already been dealt
      // with, so reset the route in Redux state to an empty string.
      // --------------------------------------------------------
      this.props.routeChange()
    }
  }

  render() {
    // --------------------------------------------------------
    // Set the remaining configuration into the props.
    // --------------------------------------------------------
    const siteTitle = cfgData.cfg && cfgData.cfg.siteTitle || 'A Site Title'
    const menuLeft = cfgData.menuLeft || []
    const menuRight = cfgData.menuRight || []
    return (
      <div>
        <TopMenu siteTitle={siteTitle} menuLeft={menuLeft} menuRight={menuRight} />
        <div className='container'>
          <div className='row'>
            <div className='col-xs-offset-6 col-xs-6'>
              <Notification messages={this.props.notifications} />
            </div>
          </div>
        </div>
        <div className='container'>
          {this.props.children}
        </div>
      </div>
    )
  }
}

App.contextTypes = {
  router: PropTypes.object.isRequired
}

const mapStateToProps = (state) => {
  return {
    notifications: state.notifications,
    route: state.route
  }
}

export default connect(mapStateToProps, {
  routeChange,
  setServerInfo
})(App)

