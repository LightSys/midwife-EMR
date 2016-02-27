import React from 'react'


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

