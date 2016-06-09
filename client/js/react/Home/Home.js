import React, {Component} from 'react'
import {connect} from 'react-redux'

import {SystemLog} from '../common/SystemLog'

const adminScreen = (sysMessages) => {
  return (
    <div>
      <SystemLog messages={sysMessages}></SystemLog>
    </div>
  )
}

const defaultScreen = () => {
  return (
    <div>
      <p>This page is intentionally blank.</p>
      <p><strong>What do you want to see here?</strong></p>
    </div>
  )
}

class Home extends Component {
  constructor(props) {
    super(props)
  }

  render() {
    let roleName = this.props.roleName? this.props.roleName: ''
    switch (roleName) {
      case 'administrator':
        this.screenByRole = adminScreen(this.props.sysMessages)
        break

      default:
        this.screenByRole = defaultScreen()
    }

    return (
      <div className='row'>
        <div className='col-md-12 col-xs-12 col-sm-12 col-lg-12'>
          <h1>Home</h1>
          {this.screenByRole}
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    sysMessages: state.systemMessage,
    roleName: state.authentication.roleName
  }
}

export default Home = connect(mapStateToProps)(Home)
