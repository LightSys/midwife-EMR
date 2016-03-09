import {Schema, arrayOf, normalize} from 'normalizr'

// --------------------------------------------------------
// Schemas.
// --------------------------------------------------------
const userSchema = new Schema('user', {
  idAttribute: 'id'
})

const roleSchema = new Schema('role', {
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

