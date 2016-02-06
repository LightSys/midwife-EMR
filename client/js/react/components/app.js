import React, {Component} from 'react'

import TopMenu from './top-menu'

class App extends Component {
  constructor(props) {
    super(props)
    this.render = this.render.bind(this)
  }

  render() {
    const siteTitle = this.props.cfg && this.props.cfg.siteTitle || 'A Site Title'
    return (
      <div>
        <TopMenu siteTitle={siteTitle} />
      </div>
    )
  }
}

export default App

