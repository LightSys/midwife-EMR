import React from 'react'


export const renderText = (cols=3, lbl='Field label', ph='placeholder', type='text', fld) => {
  const classes = `form-group col-xs-${cols}`
  return (
    <div key={fld.name} className={classes}>
      <label>{lbl}</label>
      <input type={type} className='form-control' placeholder={ph} {...fld} />
    </div>
  )
}

export const renderCB = (cols=3, lbl='Field label', ph='placeholder', type='text', fld) => {
  const classes = `form-group col-xs-${cols} checkbox`
  return (
    <div key={fld.name} className={classes}>
      <label className='checkbox'>
        <input type='checkbox' {...fld} checked={fld.value} /><strong> {lbl}</strong>
      </label>
    </div>
  )
}

export const renderHidden = (cols=3, lbl='Field label', ph='placeholder', type='hidden', fld) => {
  console.log(fld)
  return (
    <div key={fld.name}>
      <input type='hidden' {...fld} />
    </div>
  )
}

