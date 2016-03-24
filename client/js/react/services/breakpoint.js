import {windowResize} from '../actions/Breakpoint'
import {getViewportSize} from '../utils/index'
import {
  BP_SMALL,
  BP_MEDIUM,
  BP_LARGE
} from '../constants/index'

let theStore = null

const doResize = () => {
  const size = getViewportSize()
  theStore.dispatch(windowResize(size.w, size.h))
}

const init = (store) => {
  theStore = store

  // Initialize for the first time.
  doResize()

  // Listen for resize events.
  window.onresize = () => doResize()
}

export default init
