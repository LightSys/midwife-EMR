import React, {Component} from 'react'
import {connect} from 'react-redux'

import {selectUser, saveUser} from '../actions/UsersRoles'
import {loadAllUsersRoles} from '../actions/UsersRoles'
import {UserList as UL} from './UserList'
import {UserEdit as UE} from './UserEdit'


const mapStateToPropsUserList = (state) => {
  const {users, roles, saving} = state.entities
  return {
    users,
    roles,
    saving
  }
}

const mapStateToPropsUserEdit = (state) => {
  const user = state.entities.users[state.selected.user]
  const roles = state.entities.roles
  return {
    user,
    roles
  }
}

export const UserList = connect(mapStateToPropsUserList, {
  selectUser,
  loadAllUsersRoles,
})(UL)

export const UserEdit = connect(mapStateToPropsUserEdit, {
  saveUser
})(UE)

