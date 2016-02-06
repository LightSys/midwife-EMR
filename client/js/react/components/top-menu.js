import React, {Component} from 'react'

class TopMenu extends Component {
  constructor(props) {
    super(props)

    this.render = this.render.bind(this)
  }

  render() {
    // --------------------------------------------------------
    // TODO: turn this into a dynamic menu.
    // --------------------------------------------------------
    return (
      <nav className="navbar navbar-default">
        <div className="container-fluid">
          <div className="navbar-header">
            <a className="navbar-brand navbar-link" href="#">{this.props.siteTitle} </a>
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
              <li className="active" role="presentation">
                <a href="#"> <span className="glyphicon glyphicon-search"></span></a>
              </li>
              <li role="presentation"><a href="#">New </a></li>
              <li role="presentation"><a href="#">Checkout </a></li>
              <li role="presentation"><a href="#">Reports </a></li>
              <li role="presentation"><a href="#">Priority</a></li>
            </ul>
            <ul className="nav navbar-nav navbar-right">
              <li role="presentation"><a href="#">version 0.72</a></li>
              <li className="dropdown"><a className="dropdown-toggle" data-toggle="dropdown" aria-expanded="false" href="#">Profile <span className="caret"></span></a>
                <ul className="dropdown-menu" role="menu">
                  <li><a href="#">First Item</a></li>
                  <li><a href="#">Second Item</a></li>
                  <li><a href="#">Third Item</a></li>
                </ul>
              </li>
            </ul>
          </div>
        </div>
      </nav>
    )
  }
}

export default TopMenu
