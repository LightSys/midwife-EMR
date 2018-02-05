module Data.Toast
    exposing
        ( ToastRecord
        , ToastType(..)
        )


type ToastType
    = InfoToast
    | WarningToast
    | ErrorToast


type alias ToastRecord =
    { msgs : List String
    , secondsLeft : Int
    , toastType : ToastType
    }
