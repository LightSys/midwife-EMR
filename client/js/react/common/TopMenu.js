import React, {Component} from 'react'
import {IndexLink} from 'react-router'

//<li className="active" role="presentation">
  //<a href="#"> <span className="glyphicon glyphicon-search"></span></a>
//</li>
//<li role="presentation"><a href="#">New </a></li>
//<li role="presentation"><a href="#">Checkout </a></li>
//<li role="presentation"><a href="#">Reports </a></li>
//<li role="presentation"><a href="#">Priority</a></li>

//<li role="presentation"><a href="#">version 0.72</a></li>
//<li className="dropdown"><a className="dropdown-toggle" data-toggle="dropdown" aria-expanded="false" href="#">Profile <span className="caret"></span></a>
  //<ul className="dropdown-menu" role="menu">
    //<li><a href="#">First Item</a></li>
    //<li><a href="#">Second Item</a></li>
    //<li><a href="#">Third Item</a></li>
  //</ul>
//</li>

class TopMenu extends Component {
  constructor(props) {
    super(props)
    this.render = this.render.bind(this)
  }

  render() {
    const menuLeftItems = this.props.menuLeft.map((m, idx) => {
      return <li key={idx} role='presentation'><IndexLink to={m.url}>{m.label}</IndexLink></li>
    })
    const menuRightItems = this.props.menuRight.map((m, idx) => {
      // TODO: need to handle drop downs too.
      // TODO: handle #version better than this.
      if (m.url === '#version') {
        return <li key={idx} role='presentation'><IndexLink onClick={(e) => e.preventDefault()} to='/'>{m.label}</IndexLink></li>
      } else {
        return <li key={idx} role='presentation'><IndexLink to={m.url}>{m.label}</IndexLink></li>
      }
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
          <div className="collapse navbar-collapse" id="navcol-1">
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
