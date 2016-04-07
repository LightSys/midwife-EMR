import {Schema, arrayOf, normalize} from 'normalizr'

// --------------------------------------------------------
// User schemas
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


// --------------------------------------------------------
// Pregnancy schemas
//
// Notes:
// 1. Priority is massaged on the server and appears on the
//    pregnancy record as prenatalCheckinPriority instead of
//    as a separate table.
// 2. Schedule is massaged on the server and appears on the
//    pregnancy record as prenatalLocation and prenatalDay
//    instead of as a separate table.
// --------------------------------------------------------
const pregnancySchema = new Schema('pregnancy', {
  idAttribute: 'id'
})

const patientSchema = new Schema('patient', {
  idAttribute: 'id'
})

const customFieldSchema = new Schema('customField', {
  idAttribute: 'id'
})

pregnancySchema.define({
  patient: patientSchema,
  customField: arrayOf(customFieldSchema)
})

const Schemas = {
  USER: userSchema,
  USER_ARRAY: arrayOf(userSchema),
  ROLE: roleSchema,
  ROLE_ARRAY: arrayOf(roleSchema),
  PREGNANCY: pregnancySchema,
  PREGNANCY_ARRAY: arrayOf(pregnancySchema),
  PATIENT: patientSchema,
  PATIENT_ARRAY: arrayOf(patientSchema),
  CUSTOM_FIELD_ARRAY: arrayOf(customFieldSchema)
}

export default Schemas

