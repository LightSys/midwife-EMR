module Data.BirthCertificate
    exposing
        ( BirthCertificateId(..)
        , BirthCertificateRecord
        , BirthCertificateRecordNew
        , birthCertificateRecord
        , birthCertificateRecordNewToBirthCertificateRecord
        , birthCertificateRecordNewToValue
        , birthCertificateRecordToValue
        )

import Data.Table exposing (Table(..), tableToString)
import Date exposing (Date)
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Json.Encode.Extra as JEE
import Util as U


type BirthCertificateId
    = BirthCertificateId Int


type alias BirthCertificateRecord =
    { id : Int
    , birthOrder : String
    , motherMaidenLastname : String
    , motherMiddlename : Maybe String
    , motherFirstname : String
    , motherCitizenship : String
    , motherNumChildrenBornAlive : Int
    , motherNumChildrenLiving : Int
    , motherNumChildrenBornAliveNowDead : Int
    , motherAddress : String
    , motherCity : String
    , motherProvince : String
    , motherCountry : String
    , fatherLastname : Maybe String
    , fatherMiddlename : Maybe String
    , fatherFirstname : Maybe String
    , fatherCitizenship : Maybe String
    , fatherReligion : Maybe String
    , fatherOccupation : Maybe String
    , fatherAgeAtBirth : Maybe Int
    , fatherAddress : Maybe String
    , fatherCity : Maybe String
    , fatherProvince : Maybe String
    , fatherCountry : Maybe String
    , dateOfMarriage : Maybe Date
    , cityOfMarriage : Maybe String
    , provinceOfMarriage : Maybe String
    , countryOfMarriage : Maybe String
    , attendantType : String
    , attendantOther : Maybe String
    , attendantFullname : String
    , attendantTitle : Maybe String
    , attendantAddr1 : Maybe String
    , attendantAddr2 : Maybe String
    , informantFullname : String
    , informantRelationToChild : String
    , informantAddress : String
    , preparedByFullname : String
    , preparedByTitle : String
    , commTaxNumber : Maybe String
    , commTaxDate : Maybe Date
    , commTaxPlace : Maybe String
    , comments : Maybe String
    , baby_id : Int
    }


type alias BirthCertificateRecordNew =
    { birthOrder : String
    , motherMaidenLastname : String
    , motherMiddlename : Maybe String
    , motherFirstname : String
    , motherCitizenship : String
    , motherNumChildrenBornAlive : Int
    , motherNumChildrenLiving : Int
    , motherNumChildrenBornAliveNowDead : Int
    , motherAddress : String
    , motherCity : String
    , motherProvince : String
    , motherCountry : String
    , fatherLastname : Maybe String
    , fatherMiddlename : Maybe String
    , fatherFirstname : Maybe String
    , fatherCitizenship : Maybe String
    , fatherReligion : Maybe String
    , fatherOccupation : Maybe String
    , fatherAgeAtBirth : Maybe Int
    , fatherAddress : Maybe String
    , fatherCity : Maybe String
    , fatherProvince : Maybe String
    , fatherCountry : Maybe String
    , dateOfMarriage : Maybe Date
    , cityOfMarriage : Maybe String
    , provinceOfMarriage : Maybe String
    , countryOfMarriage : Maybe String
    , attendantType : String
    , attendantOther : Maybe String
    , attendantFullname : String
    , attendantTitle : Maybe String
    , attendantAddr1 : Maybe String
    , attendantAddr2 : Maybe String
    , informantFullname : String
    , informantRelationToChild : String
    , informantAddress : String
    , preparedByFullname : String
    , preparedByTitle : String
    , commTaxNumber : Maybe String
    , commTaxDate : Maybe Date
    , commTaxPlace : Maybe String
    , comments : Maybe String
    , baby_id : Int
    }


birthCertificateRecord : JD.Decoder BirthCertificateRecord
birthCertificateRecord =
    JDP.decode BirthCertificateRecord
        |> JDP.required "id" JD.int
        |> JDP.required "birthOrder" JD.string
        |> JDP.required "motherMaidenLastname" JD.string
        |> JDP.required "motherMiddlename" (JD.maybe JD.string)
        |> JDP.required "motherFirstname" JD.string
        |> JDP.required "motherCitizenship" JD.string
        |> JDP.required "motherNumChildrenBornAlive" JD.int
        |> JDP.required "motherNumChildrenLiving" JD.int
        |> JDP.required "motherNumChildrenBornAliveNowDead" JD.int
        |> JDP.required "motherAddress" JD.string
        |> JDP.required "motherCity" JD.string
        |> JDP.required "motherProvince" JD.string
        |> JDP.required "motherCountry" JD.string
        |> JDP.required "fatherLastname" (JD.maybe JD.string)
        |> JDP.required "fatherMiddlename" (JD.maybe JD.string)
        |> JDP.required "fatherFirstname" (JD.maybe JD.string)
        |> JDP.required "fatherCitizenship" (JD.maybe JD.string)
        |> JDP.required "fatherReligion" (JD.maybe JD.string)
        |> JDP.required "fatherOccupation" (JD.maybe JD.string)
        |> JDP.required "fatherAgeAtBirth" (JD.maybe JD.int)
        |> JDP.required "fatherAddress" (JD.maybe JD.string)
        |> JDP.required "fatherCity" (JD.maybe JD.string)
        |> JDP.required "fatherProvince" (JD.maybe JD.string)
        |> JDP.required "fatherCountry" (JD.maybe JD.string)
        |> JDP.required "dateOfMarriage" (JD.maybe JDE.date)
        |> JDP.required "cityOfMarriage" (JD.maybe JD.string)
        |> JDP.required "provinceOfMarriage" (JD.maybe JD.string)
        |> JDP.required "countryOfMarriage" (JD.maybe JD.string)
        |> JDP.required "attendantType" JD.string
        |> JDP.required "attendantOther" (JD.maybe JD.string)
        |> JDP.required "attendantFullname" JD.string
        |> JDP.required "attendantTitle" (JD.maybe JD.string)
        |> JDP.required "attendantAddr1" (JD.maybe JD.string)
        |> JDP.required "attendantAddr2" (JD.maybe JD.string)
        |> JDP.required "informantFullname" JD.string
        |> JDP.required "informantRelationToChild" JD.string
        |> JDP.required "informantAddress" JD.string
        |> JDP.required "preparedByFullname" JD.string
        |> JDP.required "preparedByTitle" JD.string
        |> JDP.required "commTaxNumber" (JD.maybe JD.string)
        |> JDP.required "commTaxDate" (JD.maybe JDE.date)
        |> JDP.required "commTaxPlace" (JD.maybe JD.string)
        |> JDP.required "comments" (JD.maybe JD.string)
        |> JDP.required "baby_id" JD.int


birthCertificateRecordNewToValue : BirthCertificateRecordNew -> JE.Value
birthCertificateRecordNewToValue rec =
    JE.object
        [ ( "table", JE.string (tableToString BirthCertificate) )
        , ( "data"
          , JE.object
                [ ( "birthOrder", JE.string rec.birthOrder )
                , ( "motherMaidenLastname", JE.string rec.motherMaidenLastname )
                , ( "motherMiddlename", JEE.maybe JE.string rec.motherMiddlename )
                , ( "motherFirstname", JE.string rec.motherFirstname )
                , ( "motherCitizenship", JE.string rec.motherCitizenship )
                , ( "motherNumChildrenBornAlive", JE.int rec.motherNumChildrenBornAlive )
                , ( "motherNumChildrenLiving", JE.int rec.motherNumChildrenLiving )
                , ( "motherNumChildrenBornAliveNowDead", JE.int rec.motherNumChildrenBornAliveNowDead )
                , ( "motherAddress", JE.string rec.motherAddress )
                , ( "motherCity", JE.string rec.motherCity )
                , ( "motherProvince", JE.string rec.motherProvince )
                , ( "motherCountry", JE.string rec.motherCountry )
                , ( "fatherLastname", JEE.maybe JE.string rec.fatherLastname )
                , ( "fatherMiddlename", JEE.maybe JE.string rec.fatherMiddlename )
                , ( "fatherFirstname", JEE.maybe JE.string rec.fatherFirstname )
                , ( "fatherCitizenship", JEE.maybe JE.string rec.fatherCitizenship )
                , ( "fatherReligion", JEE.maybe JE.string rec.fatherReligion )
                , ( "fatherOccupation", JEE.maybe JE.string rec.fatherOccupation )
                , ( "fatherAgeAtBirth", JEE.maybe JE.int rec.fatherAgeAtBirth )
                , ( "fatherAddress", JEE.maybe JE.string rec.fatherAddress )
                , ( "fatherCity", JEE.maybe JE.string rec.fatherCity )
                , ( "fatherProvince", JEE.maybe JE.string rec.fatherProvince )
                , ( "fatherCountry", JEE.maybe JE.string rec.fatherCountry )
                , ( "dateOfMarriage", JEE.maybe U.dateToStringValue rec.dateOfMarriage )
                , ( "cityOfMarriage", JEE.maybe JE.string rec.cityOfMarriage )
                , ( "provinceOfMarriage", JEE.maybe JE.string rec.provinceOfMarriage )
                , ( "countryOfMarriage", JEE.maybe JE.string rec.countryOfMarriage )
                , ( "attendantType", JE.string rec.attendantType )
                , ( "attendantOther", JEE.maybe JE.string rec.attendantOther )
                , ( "attendantFullname", JE.string rec.attendantFullname )
                , ( "attendantTitle", JEE.maybe JE.string rec.attendantTitle )
                , ( "attendantAddr1", JEE.maybe JE.string rec.attendantAddr1 )
                , ( "attendantAddr2", JEE.maybe JE.string rec.attendantAddr2 )
                , ( "informantFullname", JE.string rec.informantFullname )
                , ( "informantRelationToChild", JE.string rec.informantRelationToChild )
                , ( "informantAddress", JE.string rec.informantAddress )
                , ( "preparedByFullname", JE.string rec.preparedByFullname )
                , ( "preparedByTitle", JE.string rec.preparedByTitle )
                , ( "commTaxNumber", JEE.maybe JE.string rec.commTaxNumber )
                , ( "commTaxDate", JEE.maybe U.dateToStringValue rec.commTaxDate )
                , ( "commTaxPlace", JEE.maybe JE.string rec.commTaxPlace )
                , ( "comments", JEE.maybe JE.string rec.comments )
                , ( "baby_id", JE.int rec.baby_id )
                ]
          )
        ]


birthCertificateRecordToValue : BirthCertificateRecord -> JE.Value
birthCertificateRecordToValue rec =
    JE.object
        [ ( "table", JE.string (tableToString BirthCertificate) )
        , ( "data"
          , JE.object
                [ ( "id", JE.int rec.id )
                , ( "birthOrder", JE.string rec.birthOrder )
                , ( "motherMaidenLastname", JE.string rec.motherMaidenLastname )
                , ( "motherMiddlename", JEE.maybe JE.string rec.motherMiddlename )
                , ( "motherFirstname", JE.string rec.motherFirstname )
                , ( "motherCitizenship", JE.string rec.motherCitizenship )
                , ( "motherNumChildrenBornAlive", JE.int rec.motherNumChildrenBornAlive )
                , ( "motherNumChildrenLiving", JE.int rec.motherNumChildrenLiving )
                , ( "motherNumChildrenBornAliveNowDead", JE.int rec.motherNumChildrenBornAliveNowDead )
                , ( "motherAddress", JE.string rec.motherAddress )
                , ( "motherCity", JE.string rec.motherCity )
                , ( "motherProvince", JE.string rec.motherProvince )
                , ( "motherCountry", JE.string rec.motherCountry )
                , ( "fatherLastname", JEE.maybe JE.string rec.fatherLastname )
                , ( "fatherMiddlename", JEE.maybe JE.string rec.fatherMiddlename )
                , ( "fatherFirstname", JEE.maybe JE.string rec.fatherFirstname )
                , ( "fatherCitizenship", JEE.maybe JE.string rec.fatherCitizenship )
                , ( "fatherReligion", JEE.maybe JE.string rec.fatherReligion )
                , ( "fatherOccupation", JEE.maybe JE.string rec.fatherOccupation )
                , ( "fatherAgeAtBirth", JEE.maybe JE.int rec.fatherAgeAtBirth )
                , ( "fatherAddress", JEE.maybe JE.string rec.fatherAddress )
                , ( "fatherCity", JEE.maybe JE.string rec.fatherCity )
                , ( "fatherProvince", JEE.maybe JE.string rec.fatherProvince )
                , ( "fatherCountry", JEE.maybe JE.string rec.fatherCountry )
                , ( "dateOfMarriage", JEE.maybe U.dateToStringValue rec.dateOfMarriage )
                , ( "cityOfMarriage", JEE.maybe JE.string rec.cityOfMarriage )
                , ( "provinceOfMarriage", JEE.maybe JE.string rec.provinceOfMarriage )
                , ( "countryOfMarriage", JEE.maybe JE.string rec.countryOfMarriage )
                , ( "attendantType", JE.string rec.attendantType )
                , ( "attendantOther", JEE.maybe JE.string rec.attendantOther )
                , ( "attendantFullname", JE.string rec.attendantFullname )
                , ( "attendantTitle", JEE.maybe JE.string rec.attendantTitle )
                , ( "attendantAddr1", JEE.maybe JE.string rec.attendantAddr1 )
                , ( "attendantAddr2", JEE.maybe JE.string rec.attendantAddr2 )
                , ( "informantFullname", JE.string rec.informantFullname )
                , ( "informantRelationToChild", JE.string rec.informantRelationToChild )
                , ( "informantAddress", JE.string rec.informantAddress )
                , ( "preparedByFullname", JE.string rec.preparedByFullname )
                , ( "preparedByTitle", JE.string rec.preparedByTitle )
                , ( "commTaxNumber", JEE.maybe JE.string rec.commTaxNumber )
                , ( "commTaxDate", JEE.maybe U.dateToStringValue rec.commTaxDate )
                , ( "commTaxPlace", JEE.maybe JE.string rec.commTaxPlace )
                , ( "comments", JEE.maybe JE.string rec.comments )
                , ( "baby_id", JE.int rec.baby_id )
                ]
          )
        ]


birthCertificateRecordNewToBirthCertificateRecord : BirthCertificateId -> BirthCertificateRecordNew -> BirthCertificateRecord
birthCertificateRecordNewToBirthCertificateRecord (BirthCertificateId id) newRec =
    BirthCertificateRecord id
        newRec.birthOrder
        newRec.motherMaidenLastname
        newRec.motherMiddlename
        newRec.motherFirstname
        newRec.motherCitizenship
        newRec.motherNumChildrenBornAlive
        newRec.motherNumChildrenLiving
        newRec.motherNumChildrenBornAliveNowDead
        newRec.motherAddress
        newRec.motherCity
        newRec.motherProvince
        newRec.motherCountry
        newRec.fatherLastname
        newRec.fatherMiddlename
        newRec.fatherFirstname
        newRec.fatherCitizenship
        newRec.fatherReligion
        newRec.fatherOccupation
        newRec.fatherAgeAtBirth
        newRec.fatherAddress
        newRec.fatherCity
        newRec.fatherProvince
        newRec.fatherCountry
        newRec.dateOfMarriage
        newRec.cityOfMarriage
        newRec.provinceOfMarriage
        newRec.countryOfMarriage
        newRec.attendantType
        newRec.attendantOther
        newRec.attendantFullname
        newRec.attendantTitle
        newRec.attendantAddr1
        newRec.attendantAddr2
        newRec.informantFullname
        newRec.informantRelationToChild
        newRec.informantAddress
        newRec.preparedByFullname
        newRec.preparedByTitle
        newRec.commTaxNumber
        newRec.commTaxDate
        newRec.commTaxPlace
        newRec.comments
        newRec.baby_id
