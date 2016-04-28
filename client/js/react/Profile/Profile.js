import React, {Component, PropTypes} from 'react'
import {connect} from 'react-redux'
import {keys, map} from 'underscore'

import {SubmitCancel} from '../common/SubmitCancel'
import {
  loadUserProfile,
  saveProfile
} from '../actions/UsersRoles'
import Loading from '../common/Loading'

import {
  BP_SMALL,
  BP_MEDIUM,
  BP_LARGE
} from '../constants/index'

import {
  manageChange,
  renderText,
  renderROText,
  renderCB,
  renderSelect,
  setValid,
  notEmpty,
  getErrors,
  getValueFromEvent
} from '../utils/formHelper'

const fldObjs = {
  'username': {
    func: renderROText,
    lbl: 'Username',
    ph: 'Username',
    type: 'text'
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
  'id': {
    func: renderROText,
    lbl: 'ID',
    ph: 'ID',
    type: 'text'
  }
}

class Profile extends Component {
  constructor(props) {
    super(props)

    this.renderSmall = this.renderSmall.bind(this)
    this.renderMedium = this.renderMedium.bind(this)
    this.renderLarge = this.renderLarge.bind(this)
    this.handleChange = manageChange('profile').bind(this)

    // Initialize the form.
    this.state = {
      errors: {}
    }
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.profile) {
      this.setState({profile: nextProps.profile})
    }
  }

  componentWillMount() {
    // Load the user's profile from the server.
    this.props.loadUserProfile()
  }

  // Change route to password reset.
  handlePasswordReset() {
    this.context.router.push(`${window.location.pathname}/resetpassword`)
  }


  renderSmall(flds) {
    if (! flds) return
    return (
      <div>
        <div className='row'>{flds[0]} {flds[1]}</div>
        <div className='row'>{flds[2]} {flds[3]}</div>
        <div className='row'>{flds[4]} {flds[5]}</div>
        <div className='row'>{flds[6]} {flds[7]}</div>
      </div>
    )
  }

  renderMedium(flds) {
    if (! flds) return
    return (
      <div>
        <div className='row'>{flds[0]} {flds[1]} {flds[2]}</div>
        <div className='row'>{flds[3]} {flds[4]} {flds[5]}</div>
        <div className='row'>{flds[6]} {flds[7]}</div>
      </div>
    )
  }

  renderLarge(flds) {
    if (! flds) return
    return (
      <div>
        <div className='row'>{flds[0]} {flds[1]} {flds[2]} {flds[3]}</div>
        <div className='row'>{flds[4]} {flds[5]} {flds[6]} {flds[7]}</div>
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

    // Populate the fields if state is ready.
    const flds = this.state.profile? map(fldObjs, (fld, fldName) => {
      let options
      const val = this.state.profile[fldName]
      const onChange = this.handleChange(fldName)
      if (fld.hasOwnProperty('additionalProps')) options = this.props[fld.additionalProps]
      const cfg = Object.assign({}, fld, {colWidth, fldName, val, onChange, options})
      // Pass in component state so that the helper can render error messages.
      cfg.state = this.state
      return cfg.func(cfg)
    }) : void 0

    // If we have no data yet, show a blank screen.
    // (This seems to be less distracting than a loading component
    // when the wait is really short.)
    if (! flds) return <div></div>

    return (
      <div>
        <h1>Your User Profile</h1>

        <form onSubmit={(evt) => {
          evt.preventDefault()

          // Check if there are any validation errors.
          const errors = getErrors(fldObjs, this.state.profile)

          if (keys(errors).length > 0) {
            // Populate the state with the error messages and deny the save.
            this.setState({errors: errors})
          } else {
            // No validation errors so allow the save.
            this.props.saveProfile(Object.assign({}, this.state.profile))
          }
        }}>

          {renderFunc(flds)}

          <SubmitCancel
            columnClass={columnClass}
            keyName='id'
            keyValue={this.props.userId}
            handleCancel={this.handleCancel}
          />
        </form>
        <hr />
        <button className='btn btn-muted' onClick={() => this.handlePasswordReset(this.props.userId)}>
          Change your password
        </button>
      </div>
    )
  }

}

Profile.contextTypes = {
  router: PropTypes.object.isRequired
}

const mapStateToProps = (state) => {
  const breakpoint = state.breakpoint
  const userId = state.authentication.userId? state.authentication.userId: -1
  const profile = state.entities.user[userId]? state.entities.user[userId]: void 0

  return {
    breakpoint,
    profile,
    userId
  }
}

export default Profile = connect(mapStateToProps, {
  loadUserProfile,
  saveProfile
})(Profile)

