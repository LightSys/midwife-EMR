module Data.SiteMessage
    exposing
        ( SiteKeyValue(..)
        , SiteMsg
        , siteMsg
        )

import Dict exposing (Dict)
import Json.Decode as JD
import Json.Decode.Pipeline as JDP


{-| The server sends dynamic key/values where the keys are
always a String but the values can be any allowable JSON, so
that needs to be handled.

Note: will need to add to this as server sends different types
of values.
-}
type SiteKeyValue
    = SiteKeyValueString String
    | SiteKeyValueInt Int
    | SiteKeyValueBool Bool
    | SiteKeyValueFloat Float


type alias SiteMsg =
    { namespace : String
    , msgType : String
    , payload : SiteMsgPayload
    }


type alias SiteMsgPayload =
    { updatedAt : Int
    , data : Dict String SiteKeyValue
    }


siteMsg : JD.Decoder SiteMsg
siteMsg =
    JDP.decode SiteMsg
        |> JDP.required "namespace" JD.string
        |> JDP.required "msgType" JD.string
        |> JDP.required "payload" siteMsgPayload


siteMsgPayload : JD.Decoder SiteMsgPayload
siteMsgPayload =
    JDP.decode SiteMsgPayload
        |> JDP.required "updatedAt" JD.int
        |> JDP.required "data" (JD.dict siteKeyValue)


siteKeyValue : JD.Decoder SiteKeyValue
siteKeyValue =
    JD.oneOf
        [ JD.string |> JD.map SiteKeyValueString
        , JD.int |> JD.map SiteKeyValueInt
        , JD.bool |> JD.map SiteKeyValueBool
        , JD.float |> JD.map SiteKeyValueFloat
        ]
