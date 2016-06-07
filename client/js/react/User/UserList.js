import React, {Component, PropTypes} from 'react'
import {isEmpty, map, debounce} from 'underscore'

import UserLine from './UserLine'

const DEBOUNCE_MS = 200

class UserList extends Component {
  constructor(props) {
    super(props)
    this.render = this.render.bind(this)
    this.saveSearch = this.saveSearch.bind(this)
    this.doSearch = debounce(this.doSearch.bind(this), DEBOUNCE_MS)
    this.searchAll = this.searchAll.bind(this)
    this.addUser = this.addUser.bind(this)

    this.state = {
      pending: '',  // The search criteria before the debounce.
      term: '',     // The search criteria to search with (after debounce).
    }
  }

  // Save the search term to state and call doSearch().
  saveSearch(val) {
    this.setState({pending: val})
    this.doSearch()
  }

  // Debounced function: sets term to force rerender.
  doSearch() {
    this.setState({term: this.state.pending})
  }

  // Instant search for everything.
  searchAll() {
    this.setState({term: '.'})      // A regular expression for any character.
    this.setState({pending: ''})    // Clear the input field.
  }

  componentWillMount() {
    this.props.getLookupTable('role') // Needs to be populated for dropdown to work.
    this.props.loadAllUsersRoles()
  }

  componentDidMount() {
    this._searchInput.focus()
  }

  addUser() {
    this.props.selectUser()
    this.context.router.push(`/user/new`)
  }

  render() {
    const term = new RegExp(`^${this.state.term}`, 'i')
    const userLines = map(this.props.user, (u) => {
      if (this.state.term) {
        if (term.test(u.firstname) ||
            term.test(u.lastname) ||
            term.test(u.shortName)) {
          const roleName = u && u.hasOwnProperty('role_id') && this.props.role? this.props.role[u.role_id].name: ''
          return <UserLine key={u.id} id={u.id} roleName={roleName} {...u} selectUser={this.props.selectUser} />
        }
      }
    })
    return (
      <div>
        <h3>Search</h3>
        <form className='form-horizontal' onSubmit={(e) => e.preventDefault()}>
          <div className='form-group row'>
            <div className='col-xs-12 col-sm-8 col-md-6 col-lg-6'>
              <input
                ref={(c) => this._searchInput = c}
                type='text'
                placeholder='last, first, or short name'
                value={this.state.pending}
                onChange={(evt) => this.saveSearch(evt.target.value)}
              />
              <span className='text-primary'><strong> or </strong></span>
              <button
                type='button'
                className='btn btn-info'
                onClick={this.searchAll}
              >Show All</button>
              <button
                type='button'
                className='btn btn-default pull-right'
                onClick={this.addUser}
              >Add User</button>
            </div>
          </div>
        </form>
        <h3>Search Results</h3>
        <table className='table table-striped table-bordered table-hover'>
          <thead>
            <tr>
              <td>ID</td>
              <td>Username</td>
              <td>Lastname</td>
              <td>Firstname</td>
              <td>shortName</td>
              <td>Role</td>
              <td>Is active</td>
              <td>Is teacher</td>
            </tr>
          </thead>
          <tbody>
            {userLines}
          </tbody>
        </table>
      </div>
   )
 }
}

UserList.contextTypes = {
  router: PropTypes.object.isRequired
}

export default UserList

