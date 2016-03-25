import React, {Component} from 'react'

const renderHidden = (name, val) => {
  return (
    <div key={name}>
      <input type='hidden' name={name} value={val} />
    </div>
  )
}

export const SubmitCancel = ({keyName, keyValue, columnClass, handleCancel}) => {
  const hidden = renderHidden(keyName, keyValue)
  return (
    <div className='row'>
      <div className={columnClass}>
        {hidden}
        <button className='btn btn-primary' type='submit'>
          Save
        </button>
      </div>
      <div className={columnClass}>
        <button className='btn btn-default' type='button' onClick={handleCancel}>
          Cancel
        </button>
      </div>
    </div>
  )
}

