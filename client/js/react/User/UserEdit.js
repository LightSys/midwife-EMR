import React, {Component, PropTypes} from 'react'
import {reduxForm} from 'redux-form'
import _ from 'underscore'

import {saveUser} from './UserActions'

import {
  getBreakpoint,
  BP_SMALL,
  BP_MEDIUM,
  BP_LARGE,
  renderText,
  renderCB,
  renderHidden
} from '../utils'

// TODO: need to add the id as hidden so it gets passed on after submit?
const fldObjs = {
  'username': {
    func: renderText,
    lbl: 'Username',
    ph: 'username',
    type: 'text'
  },
  'firstname': {
    func: renderText,
    lbl: 'Firstname',
    ph: 'first name',
    type: 'text'
  },
  'lastname': {
    func: renderText,
    lbl: 'Lastname',
    ph: 'last name',
    type: 'text'
  },
  'email': {
    func: renderText,
    lbl: 'Email',
    ph: 'email',
    type: 'email'
  },
  'lang': {
    func: renderText,
    lbl: 'Language',
    ph: 'language',
    type: 'text'
  },
  'shortName': {
    func: renderText,
    lbl: 'Short name',
    ph: 'short name',
    type: 'text'
  },
  'displayName': {
    func: renderText,
    lbl: 'Display name',
    ph: 'display name',
    type: 'text'
  },
  'status': {
    func: renderCB,
    lbl: 'Active?'
  },
  'note': {
    func: renderText,
    lbl: 'Note',
    ph: 'note',
    type: 'text'
  },
  'isCurrentTeacher': {
    func: renderCB,
    lbl: 'Is teacher now?'
  },
  'id': {
    func: renderHidden
  }
}

class UserEdit extends Component {
  constructor(props) {
    super(props)

    this.renderSmall = this.renderSmall.bind(this)
    this.renderMedium = this.renderMedium.bind(this)
    this.renderLarge = this.renderLarge.bind(this)

    this.breakpoint = BP_LARGE    // Default.
  }

  componentWillMount() {
    this.breakpoint = getBreakpoint()
    console.log('breakpoint: ', this.breakpoint)
  }

  renderSmall() {
    const flds = _.map(fldObjs, (fld, fldName) => {
      return fld.func(6, fld.lbl, fld.ph, fld.type, this.props.fields[fldName])
    })
    const row1 = flds.slice(0, 2)
    const row2 = flds.slice(2, 4)
    const row3 = flds.slice(4, 6)
    const row4 = flds.slice(6, 8)
    const row5 = flds.slice(8, 10)
    const row6 = flds.slice(10, 12)
    return (
      <div>
        <h3>Edit User</h3>
        <form>
          <div className='row'>{row1}</div>
          <div className='row'>{row2}</div>
          <div className='row'>{row3}</div>
          <div className='row'>{row4}</div>
          <div className='row'>{row5}</div>
          <div className='row'>{row6}</div>
        </form>
      </div>
    )
  }

  renderMedium() {
    const flds = _.map(fldObjs, (fld, fldName) => {
      return fld.func(6, fld.lbl, fld.ph, fld.type, this.props.fields[fldName])
    })
    const row1 = flds.slice(0, 3)
    const row2 = flds.slice(3, 6)
    const row3 = flds.slice(6, 9)
    const row4 = flds.slice(9, 12)
    return (
      <div>
        <h3>Edit User</h3>
        <form>
          <div className='row'>{row1}</div>
          <div className='row'>{row2}</div>
          <div className='row'>{row3}</div>
          <div className='row'>{row4}</div>
        </form>
      </div>
    )
  }

  renderLarge() {
    const {handleSubmit, resetForm, submitting} = this.props
    const flds = _.map(fldObjs, (fld, fldName) => {
      return fld.func(3, fld.lbl, fld.ph, fld.type, this.props.fields[fldName])
    })
    const row1 = flds.slice(0, 4)
    const row2 = flds.slice(4, 8)
    const row3 = flds.slice(8, 12)
    const hidden = flds.slice(12)
    return (
      <div>
        <h3>Edit User</h3>
        <form onSubmit={handleSubmit((user) => {
          console.log('Submitting, I think ...')
          this.props.saveUser(user)
        })}>
          <div className='row'>{row1}</div>
          <div className='row'>{row2}</div>
          <div className='row'>{row3}</div>
          <div className='row'>
            <div className='col-xs-6'>
              {hidden}
              <button type='submit' disabled={submitting}>
                Save
              </button>
            </div>
          </div>
        </form>
      </div>
    )
  }

  render() {
    switch (this.breakpoint) {
      case BP_SMALL:    return this.renderSmall()
      case BP_MEDIUM:   return this.renderMedium()
      default:          return this.renderLarge()
    }
  }
}

UserEdit.propTypes = {
  fields: PropTypes.object.isRequired,
  handleSubmit: PropTypes.func.isRequired,
  resetForm: PropTypes.func.isRequired,
  submitting: PropTypes.bool.isRequired
}

UserEdit = reduxForm({
  form: 'UserEdit',
  fields: _.keys(fldObjs)
}, state => {
  const user = state.entities.users[state.selectedUser]
  const roles = state.entities.roles
  // Don't load roles into initialValues but make available on props.
  return {initialValues: user, roles: roles}
},
{saveUser}
)(UserEdit)

export {UserEdit}
