import React, {Component} from 'react'

require('./Notification.css')

class Notification extends Component {
  /* --------------------------------------------------------
   * render()
   *
   * Expects props.messages to be an array with objects, each
   * of which represent a message to display in order of the
   * array. Object elements are:
   * 
   *   msg        - string: the message
   *   msgType    - string: same as Bootstrap: success, info, warning, danger
   *   timeout    - number: number of milliseconds until dismissal
   *   closeable  - boolean: whether user can dismiss it
   * -------------------------------------------------------- */
  render () {
    const msgs = this.props.messages.map((m, idx) => {
      const classes = `Notification alert alert-${m.msgType}`
      return (
        <div key={idx} className={classes}>
          {m.msg}
        </div>
      )
    })
    return (
      <div>
        {msgs}
      </div>
    )
  }
}

export default Notification
