import React, {Component, PropTypes} from 'react'
import {connect} from 'react-redux'
import {keys, map} from 'underscore'

import PatientHeader from '../common/PatientHeader'
import {checkInOut, selectPregnancy} from '../actions/Pregnancy'

const NEW_IN_OR_ANY_OUT = 'NEW_IN_OR_ANY_OUT'
const CHECK_OUT = 'CHECK_OUT'
const CHECK_IN = 'CHECK_IN'

import {
  renderText,
  onlyNumbers,
  getErrors,
  getValueFromEvent
} from '../utils/formHelper'

const fldObjects = {
  'barcode': {
    func: renderText,
    lbl: 'Scan or type priority barcode',
    type: 'text',
    validate: onlyNumbers
  }
}

class CheckinCheckout extends Component {
  constructor(props) {
    super(props)

    this.renderCheckInOutDetail = this.renderCheckInOutDetail.bind(this)
    this.handleChange = this.handleChange.bind(this)
    this.done = this.done.bind(this)

    this.state = {
      barcode: '',
      errors: {}
    }
  }

  componentDidMount() {
    if (this.state._barcode) this.state._barcode.focus()
  }

  handleChange(name) {
    return (evt) => {
      const value = getValueFromEvent(evt)
      this.setState({[name]: value})
    }
  }

  done() {
    // The check in/out operation has been submitted, so there is no
    // reason to stay on this page. We go back to the calling page.
    this.context.router.goBack()
  }

  render() {
    let title = ''
    let pregnancy
    let patient
    const colWidth = 6
    const columnClass = `col-xs-${colWidth}`
    const flds = map(fldObjects, (fld, fldName) => {
      let options
      const val = this.state[fldName]
      const onChange = this.handleChange(fldName)
      if (fld.hasOwnProperty('additionalProps')) options = this.props[fld.additionalProps]
      const cfg = Object.assign({}, fld, {colWidth, fldName, val, onChange, options})
      // Pass in component state so that the helper can render error messages.
      cfg.state = this.state
      return cfg.func(cfg)
    })

    if (this.props.checkInOutStatus === NEW_IN_OR_ANY_OUT) title = 'New Client Check In or Any Client Check Out'
    if (this.props.checkInOutStatus === CHECK_OUT) title = 'Client Check Out'
    if (this.props.checkInOutStatus === CHECK_IN) title = 'Client Check In'
    if (this.props.pregnancy) pregnancy = this.props.pregnancy
    if (this.props.patient) patient = this.props.patient
    return (
      <div>
        <PatientHeader pregnancy={pregnancy} patient={patient} selectPregnancy={this.props.selectPregnancy}/>
        <h3>{title}</h3>
        <div className='row'>
          {this.renderCheckInOutDetail(flds, pregnancy, patient)}
        </div>
      </div>
    )
  }

  renderCheckInOutDetail(flds, pregnancy, patient) {
    return (
      <div className='col-xs-6'>
        <form onSubmit={(evt) => {
          evt.preventDefault()

          // Check if there are any validation errors.
          const errors = getErrors(fldObjects, this.state)

          if (keys(errors).length > 0) {
            // Populate the state with the error messages and deny the save.
            this.setState({errors: errors})
          } else {
            this.setState({errors: {}})
            const barcode = this.state._barcode.value
            const pregId = this.props.pregnancy ? this.props.pregnancy.id: void 0
            this.props.checkInOut(barcode, pregId)
            this.done()
          }
        }}>
          <div className='row'>
            <div className='col-xs-12'>
              {flds[0]}
            </div>
          </div>
        </form>
      </div>
    )
  }

}

CheckinCheckout.contextTypes = {
  router: PropTypes.object.isRequired
}

const mapStateToProps = (state) => {
  const selectedPregnancy = state.selected.pregnancy
  let prenatalPriority = false
  let pregnancy = void 0
  let patient = void 0
  if (selectedPregnancy !== -1 && state.entities.pregnancy[selectedPregnancy]) {
    prenatalPriority = state.entities.pregnancy[selectedPregnancy].prenatalCheckinPriority !== 0
    pregnancy = state.entities.pregnancy[selectedPregnancy]
    patient = state.entities.patient[pregnancy.patient_id]
  }

  // --------------------------------------------------------
  // If there is a selected pregnancy, pregnancy prop will be
  // populated. If there is a selected pregnancy and it already
  // has a priority number assigned, prenatalPriority
  // will be true.
  //
  // pregnancy === void 0     --> server will do new client
  //                              check in or check out of
  //                              any client
  //
  // pregnancy !== void 0 &&
  // prenatalPriority         --> server will do check out
  //
  // pregnancy !== void 0 &&
  // ! prenatalPriority       --> server will do check in
  // --------------------------------------------------------
  let checkInOutStatus
  if (! pregnancy) {
    checkInOutStatus = NEW_IN_OR_ANY_OUT
  } else if (pregnancy && prenatalPriority) {
    checkInOutStatus = CHECK_OUT
  } else {
    checkInOutStatus = CHECK_IN
  }

  return {
    checkInOutStatus,
    prenatalPriority,
    patient,
    pregnancy
  }
}

export default CheckinCheckout = connect(mapStateToProps, {
  checkInOut,
  selectPregnancy
})(CheckinCheckout)

