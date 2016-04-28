import React, {Component, PropTypes} from 'react'

import {SubmitCancel} from '../common/SubmitCancel'
import {
  BP_SMALL,
  BP_MEDIUM,
  BP_LARGE
} from '../constants/index'

class UserPasswordResetClass extends Component {
  constructor(props) {
    super(props)

    this.handleChange = this.handleChange.bind(this)
    this.handleCancel = this.handleCancel.bind(this)
    this.goBack = this.goBack.bind(this)

    // Initialize the form.
    this.state = {
      password1: '',
      password2: '',
      errors: {
        password1: [],
        password2: []
      }
    }
  }

  componentDidMount() {
    this._password1.focus()
  }

  handleCancel(evt) {
    evt.preventDefault()
    this.goBack()
  }

  goBack() {
    const path = window.location.pathname.replace(/\/resetpassword/, '')
    this.context.router.push(path)    // go back to caller
  }

  handleChange(name) {
    return (evt) => {
      this.setState({[name]: evt.target.value})
    }
  }

  render() {
    let first, last, uname
    let reference
    if (this.props.user) {
      reference = 'user'
    } else if (this.props.profile) {
      reference = 'profile'
    }
    if (! reference) {
      // TODO: handle this error.
      return <div></div>
    }
    first = this.props[reference].firstname
    last = this.props[reference].lastname
    uname = this.props[reference].username

    let columnWidth
    switch (this.props.breakpoint.bp) {
      case BP_SMALL:
        columnWidth = 6
        break
      case BP_MEDIUM:
        columnWidth = 4
        break
      default:
        columnWidth = 3
    }
    const classes = `form-group col-xs-${columnWidth}`
    let errorClasses = 'text-warning hidden'    // Not shown by default.

    let preMessage = ''
    if (this.props.user) {
      preMessage = () => {
        return (
          <p>You are about to reset the password of <strong>{first} {last}</strong>&nbsp;
          with username <strong>{uname}</strong>.</p>
        )
      }
    } else if (this.props.profile) {
      preMessage = () => {
        return (
          <p>You are about to reset your own password.</p>
        )
      }
    }

    return (
      <div>
        <h3>Password Reset</h3>
        {preMessage()}
        <p><strong>Please type a new password in both password fields.</strong></p>

        <form onSubmit={(evt) => {
          evt.preventDefault()
          console.log('calling resetUserPassword', this.props[reference].id, this.state.password1)
          if (reference === 'user') {
            this.props.resetUserPassword(this.props[reference].id, this.state.password1)
          } else if (reference === 'profile') {
            this.props.resetProfilePassword(this.props[reference].id, this.state.password1)
          }
          this.goBack()
        }}>
          <div className='row'>
            <div className={classes}>
              <label>New Password</label>
              <input
                type='password'
                className='form-control'
                placeholder='Enter a new password'
                name='password1'
                value={this.state.password1}
                onChange={this.handleChange('password1')}
                ref={(c) => this._password1 = c}
              />
            </div>
          </div>
          <div className='row'>
            <div className={classes}>
              <label>Repeat Password</label>
              <input
                type='password'
                className='form-control'
                placeholder='type it again'
                name='password2'
                value={this.state.password2}
                onChange={this.handleChange('password2')}
              />
            </div>
          </div>

          <div className='row'>
            <SubmitCancel
              columnClass={classes}
              keyName='id'
              keyValue={this.props[reference].id}
              handleCancel={this.handleCancel}
            />
          </div>

        </form>
      </div>
    )
  }
}

UserPasswordResetClass.contextTypes = {
  router: PropTypes.object.isRequired
}

export {UserPasswordResetClass as UserPasswordReset}
