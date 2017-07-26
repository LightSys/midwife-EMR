module Data.Pregnancy exposing (getPregId, PregnancyId(..))


type PregnancyId
    = PregnancyId Int


getPregId : PregnancyId -> Int
getPregId (PregnancyId id) =
    id
