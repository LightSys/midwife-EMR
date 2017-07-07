module Constants exposing (..)

import Color


-- LOCAL IMPORTS

import Types exposing (..)


{-| The list of tables that the admin user is allowed to view
and potentially change, hopefully on a new install only. There
are more tables that the server considers "lookup tables", but
these are the ones that the administrator can change without
causing issues with the server application.

    tables =
        List.map liTable listLookupTables
-}
listLookupTables : List TableMetaInfo
listLookupTables =
    [ TableMetaInfo LabSuite "Labs" "Lists the various laboratory suites of tests and their definitions."
    , TableMetaInfo MedicationType "Medication Types" "Defines medications."
    , TableMetaInfo VaccinationType "Vaccination Types" "Defines vaccinations."
    , TableMetaInfo SelectData "Miscellaneous" "Various system wide multiple choice definitions."
    ]


{-| Same as #FF6464.
-}
errorColor =
    Color.rgb 255 100 100
