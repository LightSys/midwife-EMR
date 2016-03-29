import React, {Component, PropTypes} from 'react'

class UserLine extends Component {
  constructor(props) {
    super(props)
    this.editUser = this.editUser.bind(this)
  }

  shouldComponentUpdate(nextProps, nextState) {
    return true
  }

  editUser() {
    this.props.selectUser(this.props.id)
    this.context.router.push(`/user/${this.props.id}`)
  }

  render() {
    const yesNo = (val) => {
      return val === 1 || val === true? 'Yes': 'No'
    }

    return (
      <tr key={this.props.key} onClick={this.editUser}>
        <td>{this.props.id}</td>
        <td>{this.props.lastname}</td>
        <td>{this.props.firstname}</td>
        <td>{this.props.shortName}</td>
        <td>{this.props.roleName}</td>
        <td>{yesNo(this.props.status)}</td>
        <td>{yesNo(this.props.isCurrentTeacher)}</td>
      </tr>
    )
  }
}

UserLine.contextTypes = {
  router: PropTypes.object.isRequired
}

export default UserLine
