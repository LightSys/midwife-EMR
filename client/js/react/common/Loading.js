import React, {Component} from 'react'

class Loading extends Component {
  constructor(props) {
    super(props)
  }

  render() {
    const msg = this.props.msg? this.props.msg: ''
    return (
      <div className='row'>
        <div className='col-xs-offset-4 col-xs-4'>
          <span className='fa fa-fw fa-3x fa-spin fa-refresh'></span>
          <span className='text-info lead'> {msg}</span>
        </div>
      </div>
    )
  }
}

export default Loading

