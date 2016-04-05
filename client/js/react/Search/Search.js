import React, {Component} from 'react'
import {connect} from 'react-redux'
import {keys, map} from 'underscore'

import {SubmitCancel} from '../common/SubmitCancel'
import {searchPatient} from '../actions/Search'
import {
  formatDate,
  formatDohID
} from '../utils/index'

import {
  BP_SMALL,
  BP_MEDIUM,
  BP_LARGE
} from '../constants/index'

import {
  renderText,
  renderCB,
  renderSelect,
  setValid,
  notEmpty,
  getErrors,
  getValueFromEvent
} from '../utils/formHelper'

const fldObjects = {
  'searchPhrase': {
    func: renderText,
    lbl: 'Search by First name, Last name, or MMC # (no dashes or spaces)',
    ph: 'type at least 3 characters',
    type: 'text',
    validate: notEmpty
  }
}

class Search extends Component {
  constructor(props) {
    super(props)

    // Initialize the form.
    this.state = {
      searchPhrase: '',
      errors: {}
    }

  }

  componentDidMount() {
    if (this.state._searchPhrase) this.state._searchPhrase.focus()
  }

  handleChange(name) {
    return (evt) => {
      const value = getValueFromEvent(evt)
      this.setState({[name]: value})
    }
  }

  render() {
    const colWidth = 12
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

    const results = this.props.results.map(r => {
      return (
        <tr key={r.id}>
          <td>{r.priority? r.priority: ''}</td>
          <td>{r.lastname}</td>
          <td>{r.firstname}</td>
          <td>{formatDate(r.dob)}</td>
          <td>{r.address1}</td>
          <td>{r.address3}</td>
          <td>{formatDohID(r.dohID)}</td>
          <td>{r.id}</td>
        </tr>
      )
    })

    return (
      <div>
        <h3>Simple Search</h3>
        <div>
          <form onSubmit={(evt) => {
            evt.preventDefault()

            // Check if there are any validation errors.
            const errors = getErrors(fldObjects, this.state)

            if (keys(errors).length > 0) {
              // Populate the state with the error messages and deny the save.
              this.setState({errors: errors})
            } else {
              const searchCriteria = {
                searchPhrase: this.state._searchPhrase.value
              }
              this.props.searchPatient(searchCriteria)
            }
          }}>
            <div>
              {flds[0]}
            </div>
          </form>
          <div className='search-results'>
            <table className='table table-striped table-bordered table-hover responsive'>
              <thead>
                <tr>
                  <th>Pri</th>
                  <th>Lastname</th>
                  <th>Firstname</th>
                  <th>DOB</th>
                  <th>Address</th>
                  <th>Barangay</th>
                  <th>MMC #</th>
                  <th>ID</th>
                </tr>
              </thead>
              <tbody>
                {results}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  const searchCriteria = state.search.searchCriteria
  const results = state.search.results
  return {
    searchCriteria,
    results
  }
}

export default Search = connect(mapStateToProps, {
  searchPatient
})(Search)

