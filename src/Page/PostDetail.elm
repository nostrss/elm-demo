module Page.PostDetail exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Types exposing (Post, WebData(..))


view : WebData Post -> Html msg
view webData =
    case webData of
        Loading ->
            div [] [ text "Loading..." ]

        Failure ->
            div [] [ text "Failed to load post detail." ]

        Success post ->
            div []
                [ a [ href "/" ] [ text "← Back to list" ]
                , h1 [ style "margin-top" "20px" ] [ text post.title ]
                , div [ style "color" "#666", style "margin" "10px 0" ]
                    [ text ("작성자: " ++ String.fromInt post.userId)
                    , text " | "
                    , text post.createdAt
                    ]
                , div [ style "margin-top" "20px", style "line-height" "1.6" ]
                    [ text post.content ]
                ]
