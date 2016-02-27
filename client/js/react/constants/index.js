import schemas from './Schemas'

export {schemas as Schemas}

// --------------------------------------------------------
// Breakpoints.
// --------------------------------------------------------
export const BP_SMALL = 'BP_SMALL'
export const BP_MEDIUM = 'BP_MEDIUM'
export const BP_LARGE = 'BP_LARGE'

// --------------------------------------------------------
// Data state.
// --------------------------------------------------------
export const NOT_LOADED = 'NOT_LOADED'  // Data not yet loaded from server.
export const LOADING = 'LOADING'    // Data being loaded from the server.
export const LOADED = 'LOADED'      // Data loaded from server.
export const SAVING = 'SAVING'      // Data being saved to the server.

// --------------------------------------------------------
// Server constants.
// --------------------------------------------------------
export const API_ROOT = '/api/data'    // All api calls use this as a base.

