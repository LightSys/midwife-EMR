import React, {Component, PropTypes} from 'react'
import {keys, map, mapObject} from 'underscore'

import {SubmitCancel} from '../common/SubmitCancel'

import {
  BP_SMALL,
  BP_MEDIUM,
  BP_LARGE
} from '../constants/index'

import {
  manageChange,
  renderText,
  renderCB,
  renderSelect,
  setValid,
  notEmpty,
  hasSelection,
  getErrors,
  getValueFromEvent
} from '../utils/formHelper'

const fldObjs = {
  'username': {
    func: renderText,
    lbl: 'Username',
    ph: 'username',
    type: 'text',
    validate: notEmpty
  },
  'firstname': {
    func: renderText,
    lbl: 'Firstname',
    ph: 'first name',
    type: 'text',
    validate: notEmpty
  },
  'lastname': {
    func: renderText,
    lbl: 'Lastname',
    ph: 'last name',
    type: 'text',
    validate: notEmpty
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
  'role_id': {
    func: renderSelect,
    lbl: 'Role',
    additionalProps: 'role',
    validate: hasSelection
  }
}

class UserEditClass extends Component {
  constructor(props) {
    super(props)

    this.renderSmall = this.renderSmall.bind(this)
    this.renderMedium = this.renderMedium.bind(this)
    this.renderLarge = this.renderLarge.bind(this)
    this.handleChange = manageChange('user').bind(this)
    this.handleCancel = this.handleCancel.bind(this)
    this.handlePasswordReset = this.handlePasswordReset.bind(this)

    // Determine if we are editing an existing record or a new user.
    this.isNew = /\/new$/.test(window.location.pathname)

    // Initialize with either the user we are editing or an empty user record.
    this.state = {
      user: this.props.user? this.props.user: mapObject(fldObjs, (val, key) => {
        return ''
      }),
      role: this.props.role,
      errors: {}
    }
  }

  handleCancel(evt) {
    evt.preventDefault()
    this.props.selectUser()               // unset the user
    this.context.router.push('/users')    // go back to userlist
  }

  // Change route to password reset.
  handlePasswordReset() {
    this.context.router.push(`${window.location.pathname}/resetpassword`)
  }

  componentDidMount() {
    if (this.state._username) this.state._username.focus()
  }

  componentWillReceiveProps(props) {
    // Detect when we change to an edit route after a successful add user and
    // force a reload of this new route. This will bring the component online
    // in edit mode for this user.
    if (this.isNew) {
      if (! /\/new$/.test(props.route)) {
        this.context.router.push({pathname: props.route})
      }
    }
  }

  renderSmall(flds) {
    return (
      <div>
        <div className='row'>{flds[0]} {flds[1]}</div>
        <div className='row'>{flds[2]} {flds[3]}</div>
        <div className='row'>{flds[4]} {flds[5]}</div>
        <div className='row'>{flds[6]} {flds[7]}</div>
        <div className='row'>{flds[8]} {flds[9]}</div>
        <div className='row'>{flds[10]} {flds[11]}</div>
      </div>
    )
  }

  renderMedium(flds) {
    return (
      <div>
        <div className='row'>{flds[0]} {flds[1]} {flds[2]}</div>
        <div className='row'>{flds[3]} {flds[4]} {flds[5]}</div>
        <div className='row'>{flds[6]} {flds[7]} {flds[8]}</div>
        <div className='row'>{flds[9]} {flds[10]} {flds[11]}</div>
      </div>
    )
  }

  renderLarge(flds) {
    return (
      <div>
        <div className='row'>{flds[0]} {flds[1]} {flds[2]} {flds[3]}</div>
        <div className='row'>{flds[4]} {flds[5]} {flds[6]} {flds[7]}</div>
        <div className='row'>{flds[8]} {flds[9]} {flds[10]} {flds[11]}</div>
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
      const val = this.state.user[fldName]
      const onChange = this.handleChange(fldName)
      if (fld.hasOwnProperty('additionalProps')) options = this.props[fld.additionalProps]
      const cfg = Object.assign({}, fld, {colWidth, fldName, val, onChange, options})
      // Pass in component state so that the helper can render error messages.
      cfg.state = this.state
      return cfg.func(cfg)
    })

    return (
      <div>
        <h3>{this.isNew? 'Add': 'Edit'} User</h3>
        <form onSubmit={(evt) => {
          evt.preventDefault()

          // Check if there are any validation errors.
          const errors = getErrors(fldObjs, this.state.user)

          if (keys(errors).length > 0) {
            // Populate the state with the error messages and deny the save.
            this.setState({errors: errors})
          } else {
            // No validation errors so allow the save.
            if (this.isNew) {
              this.props.addUser(Object.assign({}, this.state.user))
            } else {
              this.props.saveUser(Object.assign({}, this.state.user))
            }
          }
        }}>

          {renderFunc(flds)}

          <SubmitCancel
            columnClass={columnClass}
            keyName='id'
            keyValue={this.state.user.id}
            handleCancel={this.handleCancel}
          />
        </form>
        <hr />
        <button className='btn btn-muted' onClick={() => this.handlePasswordReset(this.state.user.id)}>
          Reset User's Password
        </button>
        <div className={this.isNew? 'text-info': 'hidden'}>
          Remember to set the new user's password after creating their account.
        </div>
      </div>
    )
  }
}

UserEditClass.contextTypes = {
  router: PropTypes.object.isRequired
}

export {UserEditClass as UserEdit}
