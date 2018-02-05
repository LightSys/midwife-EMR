module Data.Patient
    exposing
        ( PatientRecord
        , patientRecord
        )

import Date exposing (Date)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP


{-| Patient record structure minus the updatedBy,
updatedAt, and supervisor fields.
-}
type alias PatientRecord =
    { id : Int
    , dohID : Maybe String
    , dob : Maybe Date
    , generalInfo : Maybe String
    , ageOfMenarche : Maybe Int
    }


{-| Decode the patient record from JSON.
-}
patientRecord : JD.Decoder PatientRecord
patientRecord =
    JDP.decode PatientRecord
        |> JDP.required "id" JD.int
        |> JDP.required "dohID" (JD.maybe JD.string)
        |> JDP.required "dob" (JD.maybe JDE.date)
        |> JDP.required "generalInfo" (JD.maybe JD.string)
        |> JDP.required "ageOfMenarche" (JD.maybe JD.int)
