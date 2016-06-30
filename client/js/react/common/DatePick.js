import React, {Component, PropTypes} from 'react'
import DatePicker from 'react-datepicker'
import moment from 'moment'
require('react-datepicker/dist/react-datepicker.css')

export class DatePick extends Component {
  constructor(props) {
    super(props)

    this.handleChange = this.handleChange.bind(this)

    let theDate = void 0
    if (this.props.val &&
        this.props.val._isAMomentObject &&
        this.props.val.isValid()) {
      theDate = this.props.val
    }
    this.state = {
      theDate: theDate
    }
  }

  handleChange(date) {
    this.setState({theDate: date})
    // Inform the caller of the change as well.
    this.props.onChange(date)
  }

  render() {
    return (
      <div>
        <DatePicker
          selected={this.state.theDate}
          onChange={this.handleChange}
          placeholderText='Click to select a date'
        />
      </div>
    )
  }
}

DatePick.PropTypes = {
  val: PropTypes.object,
  onChange: PropTypes.func.required
}


