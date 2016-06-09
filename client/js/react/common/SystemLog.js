import React, {Component} from 'react'
import ReactDOM from 'react-dom'

const SystemLogLine = ({msg, idx}) => {
  // Remove the process id from the start of the line
  // because the user will not likely appreciate/understand this.
  const line = msg.data.SYSTEM_LOG.replace(/^\d\|/, "")

  // Assign classes according to even or odd rows.
  // Note that due to zero based index, the first row will be even.
  const classes = idx % 2 === 0?
    'system-log-line system-log-line-even': 'system-log-line system-log-line-odd'

  return <p className={classes}>{line}</p>
}

export class SystemLog extends Component {
  constructor(props) {
    super(props)

    this.scrollBottom = this.scrollBottom.bind(this)
  }

  scrollBottom() {
    // Adapted from: https://stackoverflow.com/a/37620695
    if (this._systemLog) {
      const node = ReactDOM.findDOMNode(this._systemLog)
      if (node) {
        // Scroll to the bottom.
        node.scrollTop = 99999;
      }
    }
  }

  componentDidMount() {
    this.scrollBottom()
  }

  componentDidUpdate() {
    this.scrollBottom()
  }

  render() {
    // Display the newer messages at the bottom, oldest at the top.
    const msgs = [...this.props.messages]
    msgs.reverse()

    // Only display the SYSTEM_LOG messages.
    const lines = msgs.filter((m) => {
      return !! (m.data && m.data.SYSTEM_LOG)
    }).map((m, idx) => {
      return <SystemLogLine key={'' + m.updatedAt + '/' + idx} idx={idx} msg={m}></SystemLogLine>
    })

    return (
      <div className='system-log-wrapper'>
        <h3>System Log <small>Most recent 100, Newest at the bottom</small></h3>
        <div className='system-log' ref={(c) => this._systemLog = c}>
          {lines}
        </div>
      </div>
    )
  }
}
