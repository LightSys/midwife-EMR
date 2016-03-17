import React, {Component, PropTypes} from 'react'
import {map} from 'underscore'

import {
  BP_SMALL,
  BP_MEDIUM,
  BP_LARGE
} from '../constants/index'

import {getBreakpoint} from '../utils'

import {
  renderText,
  renderCB,
  renderHidden,
  renderSelect
} from '../utils/formHelper'

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
  'role_id': {
    func: renderSelect,
    lbl: 'Role',
    additionalProps: 'role'
  },
  'id': {
    func: renderHidden
  }
}

class UserEditClass extends Component {
  constructor(props) {
    super(props)

    this.renderSmall = this.renderSmall.bind(this)
    this.renderMedium = this.renderMedium.bind(this)
    this.renderLarge = this.renderLarge.bind(this)
    this.handleChange = this.handleChange.bind(this)
    this.handleCancel = this.handleCancel.bind(this)

    this.breakpoint = BP_LARGE    // Default.

    // Initialize the form.
    this.state = {
      user: this.props.user,
      role: this.props.role
    }
  }

  handleChange(name) {
    return (evt) => {
      let value
      switch (evt.target.type) {
        case 'checkbox':
          value = evt.target.checked
          break
        case 'select-one':
          value = parseInt(evt.target.value, 10)
          break
        default:
          value = evt.target.value
      }
      const newState = Object.assign({}, this.state.user, {[name]: value})
      this.setState({user: newState})   //, () => console.log(this.state.user))
    }
  }

  handleCancel(evt) {
    evt.preventDefault()
    this.props.selectUser()               // unset the user
    this.context.router.push('/users')    // go back to userlist
  }

  componentWillMount() {
    this.breakpoint = getBreakpoint()
    console.log('breakpoint: ', this.breakpoint)
  }

  renderSmall(flds) {
    return (
      <div>
        <div className='row'>
          {flds[0]}
          {flds[1]}
        </div>
        <div className='row'>
          {flds[2]}
          {flds[3]}
        </div>
        <div className='row'>
          {flds[4]}
          {flds[5]}
        </div>
        <div className='row'>
          {flds[6]}
          {flds[7]}
        </div>
        <div className='row'>
          {flds[8]}
          {flds[9]}
        </div>
        <div className='row'>
          {flds[10]}
          {flds[11]}
        </div>
      </div>
    )
  }

  renderMedium(flds) {
    return (
      <div>
        <div className='row'>
          {flds[0]}
          {flds[1]}
          {flds[2]}
        </div>
        <div className='row'>
          {flds[3]}
          {flds[4]}
          {flds[5]}
        </div>
        <div className='row'>
          {flds[6]}
          {flds[7]}
          {flds[8]}
        </div>
        <div className='row'>
          {flds[9]}
          {flds[10]}
          {flds[11]}
        </div>
      </div>
    )
  }

  renderLarge(flds) {
    return (
      <div>
        <div className='row'>
          {flds[0]}
          {flds[1]}
          {flds[2]}
          {flds[3]}
        </div>
        <div className='row'>
          {flds[4]}
          {flds[5]}
          {flds[6]}
          {flds[7]}
        </div>
        <div className='row'>
          {flds[8]}
          {flds[9]}
          {flds[10]}
          {flds[11]}
        </div>
      </div>
    )
  }

  render() {
    // Determine how many columns to render adaptively.
    let renderFunc
    let columnWidth   // Using Bootstrap grid system.
    switch (this.breakpoint) {
      case BP_SMALL:
        renderFunc = this.renderSmall
        columnWidth = 6
        break
      case BP_MEDIUM:
        renderFunc = this.renderMedium
        columnWidth = 4
        break
      default:
        renderFunc = this.renderLarge
        columnWidth = 3
    }
    const columnClass = `col-xs-${columnWidth}`

    // Populate the fields.
    const flds = map(fldObjs, (fld, fldName) => {
      let options
      if (fld.hasOwnProperty('additionalProps')) options = this.props[fld.additionalProps]
      return fld.func(columnWidth, fld.lbl, fld.ph, fld.type, fldName,
        this.state.user[fldName], this.handleChange(fldName), options)
    })
    const hidden = flds.slice(12)

    return (
      <div>
        <h3>Edit User</h3>
        <form onSubmit={(evt) => {
          evt.preventDefault()
          this.props.saveUser(Object.assign({}, this.state.user))
          this.props.selectUser()               // unset the user
          this.context.router.push('/users')    // go back to userlist
        }}>
          {renderFunc(flds)}
          <div className='row'>
            <div className={columnClass}>
              {hidden}
              <button className='btn btn-primary' type='submit'>
                Save
              </button>
            </div>
            <div className={columnClass}>
              <button className='btn btn-default' type='button' onClick={this.handleCancel}>
                Cancel
              </button>
            </div>
          </div>
        </form>
      </div>
    )
  }
}

UserEditClass.contextTypes = {
  router: PropTypes.object.isRequired
}

export {UserEditClass as UserEdit}
