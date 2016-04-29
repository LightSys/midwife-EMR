import React, {Component} from 'react'
import {IndexLink} from 'react-router'

import {removeClass} from '../utils/index'

class TopMenu extends Component {
  constructor(props) {
    super(props)
    this.render = this.render.bind(this)
  }

  render() {
    let onClickHandler = (e) => {
      // Collapse the menu after a selection. 'in' is a Bootstrap class.
      removeClass(this._navcol1, 'in')
    }
    const menuLeftItems = this.props.menuLeft.map((m, idx) => {
      if (m.useServer) {
        // Do not use client navigation at all for this link.
        return (
            <li key={idx} role='presentation'>
              <a href={m.url} >{m.label}</a>
            </li>
          )
      }
      return (
        <li key={idx} role='presentation'>
          <IndexLink to={m.url} onClick={onClickHandler}>{m.label}</IndexLink>
        </li>
      )
    })
    const menuRightItems = this.props.menuRight.map((m, idx) => {
      let onClick = onClickHandler
      if (m.useServer) {
        // Do not use client navigation at all for this link.
        return (
            <li key={idx} role='presentation'>
              <a href={m.url} >{m.label}</a>
            </li>
          )
      }

      // TODO: need to handle drop downs too.
      const innerNode = (
        <IndexLink to={m.url} onClick={onClick}>
          {m.label}
        </IndexLink>
      )
      return (
        <li key={idx} role='presentation'>
          {innerNode}
        </li>
      )
    })
    return (
      <nav className="navbar navbar-default">
        <div className="container-fluid">
          <div className="navbar-header">
            <IndexLink to='/' className="navbar-brand navbar-link" >{this.props.siteTitle}</IndexLink>
            <button
              className="navbar-toggle collapsed"
              data-toggle="collapse"
              data-target="#navcol-1">
              <span className="sr-only">Toggle navigation</span>
              <span className="icon-bar"></span>
              <span className="icon-bar"></span>
              <span className="icon-bar"></span>
            </button>
          </div>
          <div ref={(c) => this._navcol1 = c} className="collapse navbar-collapse" id="navcol-1">
            <ul className="nav navbar-nav">
              {menuLeftItems}
            </ul>
            <ul className="nav navbar-nav navbar-right">
              {menuRightItems}
            </ul>
          </div>
        </div>
      </nav>
    )
  }
}

export default TopMenu
