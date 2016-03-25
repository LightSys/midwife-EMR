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
    this.gotoUserEdit = this.gotoUserEdit.bind(this)

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
    this.gotoUserEdit()
  }

  gotoUserEdit() {
    const path = window.location.pathname.replace(/\/resetpassword/, '')
    this.context.router.push(path)    // go back to user edit
  }

  handleChange(name) {
    return (evt) => {
      this.setState({[name]: evt.target.value})
    }
  }

  render() {
    const first = this.props.user.firstname
    const last = this.props.user.lastname
    const uname = this.props.user.username

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

    return (
      <div>
        <h3>Password Reset</h3>
        <p>You are about to reset the password of <strong>{first} {last}</strong>&nbsp;
        with username <strong>{uname}</strong>.</p>
        <p><strong>Please type a new password for the user in both password fields.</strong></p>

        <form onSubmit={(evt) => {
          evt.preventDefault()
          console.log('calling resetUserPassword', this.props.user.id, this.state.password1)
          this.props.resetUserPassword(this.props.user.id, this.state.password1)
          this.gotoUserEdit()
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
              keyValue={this.props.user.id}
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
