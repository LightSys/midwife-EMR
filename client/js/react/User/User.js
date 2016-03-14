import React, {Component} from 'react'
import {connect} from 'react-redux'

import {selectUser, saveUser} from '../actions/UsersRoles'

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
  return {
    user,
    role
  }
}

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

