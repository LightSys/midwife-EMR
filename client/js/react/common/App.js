import React, {Component} from 'react'
import {connect} from 'react-redux'
import {Link} from 'react-router'

import TopMenu from './TopMenu'
import Notification from './Notification'
import {cookies} from '../services/authentication'

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
        <div className='row'>
          <div className='col-xs-offset-6 col-xs-6'>
            <Notification messages={this.props.notifications} />
          </div>
        </div>
        <div className='container'>
          {this.props.children}
        </div>
      </div>
    )
  }
}

const mapPropsToState = (state) => {
  return {
    notifications: state.notifications
  }
}

export default connect(mapPropsToState)(App)

