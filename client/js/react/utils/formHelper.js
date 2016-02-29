import React from 'react'
import {map} from 'underscore'


export const renderText = (cols=3, lbl='Field label', ph='placeholder', type='text', name, val, onChange) => {
  const classes = `form-group col-xs-${cols}`
  return (
    <div key={name} className={classes}>
      <label>{lbl}</label>
      <input type={type} className='form-control' placeholder={ph} value={val} onChange={onChange} />
    </div>
  )
}

export const renderCB = (cols=3, lbl='Field label', ph='placeholder', type='text', name, val, onChange) => {
  const classes = `form-group col-xs-${cols} checkbox`
  return (
    <div key={name} className={classes}>
      <label className='checkbox'>
        <input type='checkbox' checked={val} onChange={onChange} /><strong> {lbl}</strong>
      </label>
    </div>
  )
}

export const renderHidden = (cols=3, lbl='Field label', ph='placeholder', type='hidden', name, val) => {
  return (
    <div key={name}>
      <input type='hidden' value={val} />
    </div>
  )
}

// TODO: Fix: this still causes an unique key prop warning even though it works fine.
export const renderSelect = (cols=3, lbl='Field label', ph='placeholder', type='select', name, val, onChange, options) => {
  const classes = `form-group col-xs-${cols}`
  return (
    <div className={classes}>
      <label>{lbl}</label>
      <select
        className='form-control'
        value={val}
        name={name}
        onChange={onChange}
      >
      {
        map(options, (rec) => {
          return <option key={rec.id} value={rec.id}>{rec.name}</option>
        })
      }
      </select>
    </div>
  )
}

