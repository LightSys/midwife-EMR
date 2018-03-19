module Data.BirthCert
    exposing
        ( Field(..)
        , SubMsg(..)
        )

import Const exposing (Dialog(..), FldChgValue)
import Data.DataCache exposing (DataCache)
import Data.DatePicker exposing (DateFieldMessage)
import Data.PregnancyHeader exposing (PregHeaderContentMsg)
import Data.Table exposing (Table)
import Dict exposing (Dict)


type SubMsg
      -- DataCache is the mechanism used to retrieve records from
      -- the top-level that it has received from the server. The
      -- top-level intercepts this message and creates a new message
      -- with the latest DataCache that it has and sends it down to
      -- us again. We, in turn, populate our page Model based on the
      -- list of tables passed through.
    = DataCache (Maybe (Dict String DataCache)) (Maybe (List Table))
      -- These two are used for browsers that do not support the
      -- input date type and require the use of jQueryUI datepicker.
    | OpenDatePickerSubMsg String
    | DateFieldSubMsg DateFieldMessage
    | FldChgSubMsg Field FldChgValue
    | HandleBirthCertificateModal Dialog
    | CloseAllDialogs


type Field
    = BCBirthOrderFld
    | BCMotherMaidenLastnameFld
    | BCMotherMiddlenameFld
    | BCMotherFirstnameFld
    | BCMotherCitizenshipFld
    | BCMotherNumChildrenBornAliveFld
    | BCMotherNumChildrenLivingFld
    | BCMotherNumChildrenBornAliveNowDeadFld
    | BCMotherAddressFld
    | BCMotherCityFld
    | BCMotherProvinceFld
    | BCMotherCountryFld
    | BCFatherLastnameFld
    | BCFatherMiddlenameFld
    | BCFatherFirstnameFld
    | BCFatherCitizenshipFld
    | BCFatherReligionFld
    | BCFatherOccupationFld
    | BCFatherAgeAtBirthFld
    | BCFatherAddressFld
    | BCFatherCityFld
    | BCFatherProvinceFld
    | BCFatherCountryFld
    | BCDateOfMarriageFld
    | BCCityOfMarriageFld
    | BCProvinceOfMarriageFld
    | BCCountryOfMarriageFld
    | BCAttendantTypeFld
    | BCAttendantOtherFld
    | BCAttendantFullnameFld
    | BCAttendantTitleFld
    | BCAttendantAddr1Fld
    | BCAttendantAddr2Fld
    | BCInformantFullnameFld
    | BCInformantRelationToChildFld
    | BCInformantAddressFld
    | BCPreparedByFullnameFld
    | BCPreparedByTitleFld
    | BCCommTaxNumberFld
    | BCCommTaxDateFld
    | BCCommTaxPlaceFld
    | BCReceivedByNameFld
    | BCReceivedByTitleFld
    | BCAffiateNameFld
    | BCAffiateAddressFld
    | BCAffiateCitizenshipCountryFld
    | BCAffiateReasonFld
    | BCAffiateIAmFld
    | BCAffiateCommTaxNumberFld
    | BCAffiateCommTaxDateFld
    | BCAffiateCommTaxPlace
    | BCCommentsFld
    | PrintingPage1TopFld
    | PrintingPage1LeftFld
    | PrintingPage2TopFld
    | PrintingPage2LeftFld
    | PrintingPaternityFld
    | PrintingDelayedRegistrationFld
