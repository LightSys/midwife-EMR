import React, {Component} from 'react'
import {connect} from 'react-redux'

import {loadUsers, selectUser} from './UserActions'
import {UserList as UL} from './UserList'
import {UserEdit as UE} from './UserEdit'


const mapStateToPropsUserList = (state) => {
  const {users, roles} = state.entities
  return {
    users,
    roles
  }
}

const mapStateToPropsUserEdit = (state) => {
  const {selectedUser, entities: {users, roles}} = state
  return {
    users,
    roles,
    selectedUser
  }
}

export const UserList = connect(mapStateToPropsUserList, {
  loadUsers,
  selectUser
})(UL)

// --------------------------------------------------------
// mapStateToProps is handled by reduxForm in UserEdit.
// --------------------------------------------------------
export {UE as UserEdit}
