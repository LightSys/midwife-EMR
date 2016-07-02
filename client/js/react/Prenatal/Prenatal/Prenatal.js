import React, {Component} from 'react'
import {connect} from 'react-redux'
import {keys, map, mapObject} from 'underscore'

import {SubmitCancel} from '../../common/SubmitCancel'
import PatientHeader from '../../common/PatientHeader'

import {
  BP_SMALL,
  BP_MEDIUM,
  BP_LARGE
} from '../../constants/index'

import {
  manageChange,
  renderText,
  renderDate,
  renderCB,
  renderSelect,
  setValid,
  notEmpty,
  hasSelection,
  getErrors,
  getValueFromEvent
} from '../../utils/formHelper'


const fldObjs = {
  'philHealthMCP': {
    func: renderCB,
    lbl: 'PHIC MCP'
  },
  'philHealthNCP': {
    func: renderCB,
    lbl: 'PHIC NCP'
  },
  'philHealthID': {
    func: renderText,
    lbl: 'PHIC #',
    ph: 'PHIC #',
    type: 'text'
  },
  'philHealthApproved': {
    func: renderCB,
    lbl: 'PHIC Approved'
  },
   'lmp': {
    func: renderDate,
    lbl: 'LMP',
    ph: 'LMP',
    type: 'date'
  },
  'sureLMP': {
    func: renderCB,
    lbl: 'Sure of LMP'
  },
   'edd': {
    func: renderDate,
    lbl: 'EDD',
    ph: 'EDD',
    type: 'date'
  },
   'alternateEdd': {
    func: renderDate,
    lbl: 'Alternate EDD',
    ph: 'Alternate EDD',
    type: 'date'
  },
  'useAlternateEdd': {
    func: renderCB,
    lbl: 'Use Alternate EDD'
  }
}

export class Prenatal extends Component {
  constructor(props) {
    super(props)

    this.renderSmall = this.renderSmall.bind(this)
    this.renderMedium = this.renderMedium.bind(this)
    this.renderLarge = this.renderLarge.bind(this)

    // TODO: how to handle changes for patient and other tables?
    this.handleChange = manageChange('pregnancy').bind(this)

    // Initialize with either the pregnancy we are editing or an empty pregnancy record.
    this.state = {
      pregnancy: this.props.pregnancy? this.props.pregnancy: mapObject(fldObjs, (val, key) => {
        return ''
      }),
      patient: this.props.patient? this.props.patient: mapObject(fldObjs, (val, key) => {
        return ''
      }),
      errors: {}
    }
  }

  renderSmall(flds) {
        //<div className='row'>{flds[9]}</div>
        //<div className='row'>{flds[10]} {flds[11]}</div>
    return (
      <div>
        <h5 className='form-section text-muted'>Phil Health</h5>
        <div className='row'>{flds[0]} {flds[1]}</div>
        <div className='row'>{flds[2]} {flds[3]}</div>
        <h5 className='form-section text-muted'>Estimated Due Dates</h5>
        <div className='row'>{flds[4]} {flds[5]}</div>
        <div className='row'>{flds[6]} {flds[7]}</div>
        <div className='row'>{flds[8]}</div>
      </div>
    )
  }

  renderMedium(flds) {
        //<div className='row'>{flds[9]} {flds[10]} {flds[11]}</div>
    return (
      <div>
        <h5 className='form-section text-muted'>Phil Health</h5>
        <div className='row'>{flds[0]} {flds[1]} {flds[2]}</div>
        <div className='row'>{flds[3]}</div>
        <h5 className='form-section text-muted'>Estimated Due Dates</h5>
        <div className='row'>{flds[4]} {flds[5]} {flds[6]}</div>
        <div className='row'>{flds[7]} {flds[8]}</div>
      </div>
    )
  }

  renderLarge(flds) {
        //<div className='row'>{flds[9]} {flds[10]} {flds[11]}</div>
    return (
      <div>
        <h5 className='form-section text-muted'>Phil Health</h5>
        <div className='row'>{flds[0]} {flds[1]} {flds[2]} {flds[3]}</div>
        <h5 className='form-section text-muted'>Estimated Due Dates</h5>
        <div className='row'>{flds[4]} {flds[5]} {flds[6]} {flds[7]}</div>
        <div className='row'>{flds[8]}</div>
      </div>
    )
  }

  render() {
    // Determine how many columns to render adaptively.
    let renderFunc
    let colWidth   // Using Bootstrap grid system.
    switch (this.props.breakpoint.bp) {
      case BP_SMALL:
        renderFunc = this.renderSmall
        colWidth = 6
        break
      case BP_MEDIUM:
        renderFunc = this.renderMedium
        colWidth = 4
        break
      default:
        renderFunc = this.renderLarge
        colWidth = 3
    }
    const columnClass = `col-xs-${colWidth}`

    // Populate the fields.
    const flds = map(fldObjs, (fld, fldName) => {
      let options
      const val = this.state.pregnancy[fldName]? this.state.pregnancy[fldName]: ''
      const onChange = this.handleChange(fldName)
      if (fld.hasOwnProperty('additionalProps')) options = this.props[fld.additionalProps]
      const cfg = Object.assign({}, fld, {colWidth, fldName, val, onChange, options})
      // Pass in component state so that the helper can render error messages.
      cfg.state = this.state
      return cfg.func(cfg)
    })

    return (
      <div>
        <form onSubmit={(evt) => {
          evt.preventDefault()

          // Check if there are any validation errors.
          const errors = getErrors(fldObjs, this.state.pregnancy)

          if (keys(errors).length > 0) {
            // Populate the state with the error messages and deny the save.
            this.setState({errors: errors})
          } else {
            // No validation errors so allow the save.
            this.props.savePrenatal(Object.assign({}, this.state.pregnancy))
          }
        }}>

          <PatientHeader
            pregnancy={this.state.pregnancy}
            patient={this.state.patient}
          />
          <h3>Prenatal</h3>
          {flds? renderFunc(flds): ''}

          <SubmitCancel
            columnClass={columnClass}
            keyName='id'
            keyValue={this.state.pregnancy.id}
            handleCancel={this.handleCancel}
          />
        </form>
      </div>
    )
  }
}


