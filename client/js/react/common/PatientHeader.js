import React, {Component, PropTypes} from 'react'

import {
  age,
  formatDate,
  getGA,
  formatDohID
} from '../utils/index'

// --------------------------------------------------------
// UnloadLink
//
// Displays an icon in the form of a link outside of the lower
// right hand corner of the container. Assumes that the
// containing DOM element has a relative position. Expects
// to be passed a param representing the onClick handler.
// --------------------------------------------------------
const UnloadLink = (handleUnload) => {
  const style = {position: 'absolute', right: '40px', bottom: '-30px'}
  return (
    <a
      href=''
      onClick={handleUnload}
      style={style}>
        <span className='fa fa-fw fa-sign-out'>Unload</span>
    </a>
  )
}

// --------------------------------------------------------
// CompressExpand
//
// Displays a compress or expand icon in the form of a link
// in the upper right hand corner of the container. Assumes
// that the containing DOM element has a relative position.
// --------------------------------------------------------
class CompressExpand extends Component {
  constructor(props) {
    super(props)
  }

  render() {
    let classes = 'fa fa-fw '
    // Show the alternative icon to the display type now.
    if (this.props.displayCompressed) {
      classes += 'fa-expand'
    } else {
      classes += 'fa-compress'
    }
    const style = {position: 'absolute', right: '10px'}

    return (
      <a href='' onClick={this.props.handleClick} style={style}><span className={classes}></span></a>
    )
  }
}
CompressExpand.PropTypes = {
  displayCompressed: PropTypes.bool,
  handleClick: PropTypes.func.required
}
CompressExpand.defaultProps = {
  displayCompressed: false
}


class PatientHeader extends Component {
  constructor(props) {
    super(props)

    this.renderNone = this.renderNone.bind(this)
    this.renderMin = this.renderMin.bind(this)
    this.renderMax = this.renderMax.bind(this)
    this.minimize = this.minimize.bind(this)
    this.maximize = this.maximize.bind(this)
    this.unload = this.unload.bind(this)

    this.state = {
      isMinimized: this.props.showMinimized
    }
  }

  minimize(evt) {
    evt.preventDefault()
    this.setState({isMinimized: true})
  }

  maximize(evt) {
    evt.preventDefault()
    this.setState({isMinimized: false})
  }

  unload(evt) {
    evt.preventDefault()
    if (this.props.selectPregnancy) {
      // Calling without a pregnancy unselects the pregnancy.
      this.props.selectPregnancy();
    }
  }

  render() {
    if (this.props.patient && this.props.pregnancy) {
      if (this.state.isMinimized) {
        return this.renderMin()
      } else {
        return this.renderMax()
      }
    } else {
      return this.renderNone()
    }
  }

  renderNone() {
    return (
      <div className='well well-sm'>
        <h4>No client selected</h4>
      </div>
    )
  }

  renderMax() {
    const {
      lastname, firstname, edd, lmp, nickname, prenatalDay, prenatalLocation,
      gravida, stillBirths, abortions, living, para, preterm
    } = this.props.pregnancy
    const {dob, dohID} = this.props.patient
    let prenatal = prenatalDay? prenatalDay: ''
    prenatal += prenatalLocation? prenatalDay? ' @ ' + prenatalLocation: prenatalLocation: ''
    const ga = edd? getGA(edd): ''

    let compressExpand = ''
    if (this.props.allowToggle) {
      compressExpand = <CompressExpand handleClick={this.minimize} />
    }

    return (
      <div style={{position: 'relative'}} className='panel panel-info'>
      {compressExpand}
      {this.props.selectPregnancy? UnloadLink(this.unload): ''}
        <table className='table table-condensed'>
          <tbody>
            <tr key={1}>
              <td>
                <span className='lead'><strong>{lastname}, {firstname}</strong></span>
              </td>
              <td><strong>Age:</strong> {age(dob)} ({formatDate(dob)})</td>
              <td><strong>Current GA:</strong> {ga}</td>
            </tr>
            <tr key={2}>
              <td><strong>Nickname:</strong> {nickname}</td>
              <td><strong>MMC:</strong> {formatDohID(dohID)}</td>
              <td><strong>Prenatal:</strong> {prenatal}</td>
            </tr>
            <tr key={3}>
              <td>
                <strong>G:</strong> {gravida} &nbsp;&nbsp;&nbsp;
                <strong>P:</strong> {para} &nbsp;&nbsp;&nbsp;
                <strong>A:</strong> {abortions} &nbsp;&nbsp;&nbsp;
                <strong>S:</strong> {stillBirths} &nbsp;&nbsp;&nbsp;
                <strong>L:</strong> {living} &nbsp;&nbsp;&nbsp;
              </td>
              <td><strong>LMP:</strong> {formatDate(lmp)}</td>
              <td><strong>EDD:</strong> {formatDate(edd)}</td>
            </tr>
          </tbody>
        </table>
      </div>
    )
  }

  renderMin() {
    const {
      lastname, firstname, edd, lmp, nickname, prenatalDay, prenatalLocation,
      gravida, stillBirths, abortions, living, para, preterm
    } = this.props.pregnancy
    const {dob, dohID} = this.props.patient
    let prenatal = prenatalDay? prenatalDay: ''
    prenatal += prenatalLocation? prenatalDay? ' @ ' + prenatalLocation: prenatalLocation: ''
    const ga = edd? getGA(edd): ''

    let compressExpand = ''
    if (this.props.allowToggle) {
      compressExpand = <CompressExpand displayCompressed={true} handleClick={this.maximize} />
    }

    return (
      <div style={{position: 'relative'}} className='panel panel-info'>
      {compressExpand}
      {this.props.selectPregnancy? UnloadLink(this.unload): ''}
        <table className='table table-condensed'>
          <tbody>
            <tr key={1}>
              <td>
                <span className='lead'><strong>{lastname}, {firstname}</strong></span>
              </td>
              <td><strong>Age:</strong> {age(dob)} ({formatDate(dob)})</td>
              <td><strong>Current GA:</strong> {ga}</td>
            </tr>
          </tbody>
        </table>
      </div>
    )
  }
}


PatientHeader.PropTypes = {
  patient: PropTypes.object,
  pregnancy: PropTypes.object,
  showMinimized: PropTypes.bool,
  allowToggle: PropTypes.bool,
  // If selectPregnancy is passed, allows user to unselect/unload the pregnancy.
  selectPregnancy: PropTypes.func
}

PatientHeader.defaultProps = {
  showMinimized: false,
  allowToggle: true
}

export default PatientHeader

