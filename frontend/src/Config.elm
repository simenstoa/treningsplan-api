module Config exposing (globalConfig)


type alias Config =
    { graphQLUrl : String }


globalConfig =
    { graphQLUrl = "https://treningsplan-api.s33.no" }
