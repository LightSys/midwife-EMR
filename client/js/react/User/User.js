import React, {Component} from 'react'
import {connect} from 'react-redux'

import {
  selectUser,
  saveUser,
  addUser,
  resetUserPassword,
  resetProfilePassword
} from '../actions/UsersRoles'

import {
  getLookupTable
} from '../actions/LookupTables'

import {
  addSuccessNotification,
  addWarningNotification,
  addInfoNotification,
  addDangerNotification,
  removeNotification
} from '../actions/Notifications'

import {loadAllUsersRoles} from '../actions/UsersRoles'
import UL from './UserList'
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
  const route = state.route
  return {
    breakpoint,
    user,
    role,
    route
  }
}

const mapStateToPropsUserPasswordReset = (state) => {
  const user = state.entities.user[state.selected.user]
  const profile = state.entities.user[state.authentication.userId]
  const breakpoint = state.breakpoint
  return {
    breakpoint,
    profile,
    user
  }
}

// --------------------------------------------------------
// Export the wrapped classes.
// --------------------------------------------------------
export const UserList = connect(mapStateToPropsUserList, {
  selectUser,
  loadAllUsersRoles,
  getLookupTable
})(UL)

export const UserEdit = connect(mapStateToPropsUserEdit, {
  selectUser,
  saveUser,
  addUser,
  addSuccessNotification,
  addWarningNotification,
  addInfoNotification,
  addDangerNotification,
  removeNotification
})(UE)

export const UserPasswordReset = connect(mapStateToPropsUserPasswordReset, {
  resetUserPassword,
  resetProfilePassword
})(UPR)
