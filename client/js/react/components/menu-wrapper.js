import React from 'react'

import TopMenu from './top-menu'
import SideMenu from './side-menu'

const MenuWrapper = () => {
  return (
    <nav className='navbar navbar-inverse navbar-fixed-top'>
      <TopMenu />
      <SideMenu />
    </nav>
  )
}

export default MenuWrapper
