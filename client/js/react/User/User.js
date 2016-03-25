import React, {Component} from 'react'
import {connect} from 'react-redux'

import {
  selectUser,
  saveUser,
  resetUserPassword
} from '../actions/UsersRoles'

import {
  addSuccessNotification,
  addWarningNotification,
  addInfoNotification,
  addDangerNotification,
  removeNotification
} from '../actions/Notifications'

import {loadAllUsersRoles} from '../actions/UsersRoles'
import {UserList as UL} from './UserList'
import {UserEdit as UE} from './UserEdit'
import {UserPasswordReset as UPR} from './UserPasswordReset'

// --------------------------------------------------------
// Map state to props.
// --------------------------------------------------------
const mapStateToPropsUserList = (state) => {
  const {user, role, saving} = state.entities
  return {
    user,
    role,
    saving
  }
}

const mapStateToPropsUserEdit = (state) => {
  const user = state.entities.user[state.selected.user]
  const role = state.entities.role
  const breakpoint = state.breakpoint
  return {
    breakpoint,
    user,
    role
  }
}

const mapStateToPropsUserPasswordReset = (state) => {
  const user = state.entities.user[state.selected.user]
  const breakpoint = state.breakpoint
  return {
    breakpoint,
    user
  }
}

// --------------------------------------------------------
// Export the wrapped classes.
// --------------------------------------------------------
export const UserList = connect(mapStateToPropsUserList, {
  selectUser,
  loadAllUsersRoles,
})(UL)

export const UserEdit = connect(mapStateToPropsUserEdit, {
  selectUser,
  saveUser,
  addSuccessNotification,
  addWarningNotification,
  addInfoNotification,
  addDangerNotification,
  removeNotification
})(UE)

export const UserPasswordReset = connect(mapStateToPropsUserPasswordReset, {
  resetUserPassword
})(UPR)
