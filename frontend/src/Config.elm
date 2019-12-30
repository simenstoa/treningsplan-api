module Config exposing (globalConfig)


type alias Config =
    { graphQLUrl : String }


globalConfig =
    { graphQLUrl = "http://treningsplan-api.s33.no" }
