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

const pregnancySchema = new Schema('pregnancy', {
  idAttribute: 'id'
})

const patientSchema = new Schema('patient', {
  idAttribute: 'id'
})

pregnancySchema.define({
  patient: patientSchema
})


const Schemas = {
  USER: userSchema,
  USER_ARRAY: arrayOf(userSchema),
  ROLE: roleSchema,
  ROLE_ARRAY: arrayOf(roleSchema),
  PREGNANCY: pregnancySchema,
  PREGNANCY_ARRAY: arrayOf(pregnancySchema),
  PATIENT: patientSchema,
  PATIENT_ARRAY: arrayOf(patientSchema)
}

export default Schemas

