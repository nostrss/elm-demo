module Types exposing (Post, WebData(..))


type alias Post =
    { id : Int
    , title : String
    , content : String
    , userId : Int
    , createdAt : String
    }


type WebData a
    = Loading
    | Success a
    | Failure
