import {Schema, arrayOf, normalize} from 'normalizr'

// --------------------------------------------------------
// Schemas.
// --------------------------------------------------------
const userSchema = new Schema('users', {
  idAttribute: 'id'
})

const roleSchema = new Schema('roles', {
  idAttribute: 'id'
})

userSchema.define({
  role: roleSchema
})

const Schemas = {
  USER: userSchema,
  USER_ARRAY: arrayOf(userSchema),
  ROLE: roleSchema,
  ROLE_ARRAY: arrayOf(roleSchema)
}

export default Schemas

