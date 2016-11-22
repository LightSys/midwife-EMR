module Constants exposing (..)

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
    [ TableMetaInfo LabSuite "labSuite" "Lists the various laboratory suites of tests."
    , TableMetaInfo LabTest "labTest" "Defines individual laboratory tests."
    , TableMetaInfo MedicationType "medicationType" "Defines medications."
    , TableMetaInfo VaccinationType "vaccinationType" "Defines vaccinations."
    ]
