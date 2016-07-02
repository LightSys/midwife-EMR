import React, {Component} from 'react'
import {connect} from 'react-redux'

import {Prenatal as PN} from './Prenatal/Prenatal'
import {savePrenatal} from '../actions/Pregnancy'


const mapStateToPropsPrenatal = (state) => {
  let pregnancy, patient
  const isPregnancy = state.selected.pregnancy !== -1
  if (isPregnancy) {
    pregnancy = state.entities.pregnancy[state.selected.pregnancy]
    if (pregnancy) patient = state.entities.patient[pregnancy.patient_id]
  }
  const breakpoint = state.breakpoint
  const route = state.route
  return {
    breakpoint,
    patient,
    pregnancy,
    route
  }
}


export const Prenatal = connect(mapStateToPropsPrenatal, {
  savePrenatal
})(PN)


