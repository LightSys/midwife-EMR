module Types
    exposing
        ( User
        , Role
        , SystemMessage
        , emptySystemMessage
        )


type alias SystemMessage =
    { id : String
    , msgType : String
    , updatedAt : Int
    , workerId : String
    , processedBy : List String
    , systemLog : String
    }


{-| Used when there is an error decoding from JS.
-}
emptySystemMessage : SystemMessage
emptySystemMessage =
    { id = "ERROR"
    , msgType = ""
    , updatedAt = 0
    , workerId = ""
    , processedBy = []
    , systemLog = ""
    }


type alias User =
    { id : Int
    , username : String
    , firstname : String
    , lastname : String
    , password : String
    , email : String
    , lang : String
    , shortName : String
    , displayName : String
    , status : Bool
    , note : String
    , isCurrentTeacher : Bool
    , roleId : Int
    }


type alias Role =
    { id : Int
    , name : String
    , description : String
    }
