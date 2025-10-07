module Page.PostList exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Types exposing (Post, WebData(..))


view : WebData (List Post) -> Html msg
view webData =
    case webData of
        Loading ->
            div [] [ text "Loading..." ]

        Failure ->
            div [] [ text "Failed to load posts." ]

        Success posts ->
            div []
                [ h1 [] [ text "Posts" ]
                , ul [ style "list-style" "none", style "padding" "0" ]
                    (List.map viewPostItem posts)
                ]


viewPostItem : Post -> Html msg
viewPostItem post =
    li
        [ style "border" "1px solid #ddd"
        , style "margin" "10px 0"
        , style "padding" "15px"
        , style "border-radius" "5px"
        ]
        [ a
            [ href ("/post/" ++ String.fromInt post.id)
            , style "text-decoration" "none"
            , style "color" "#333"
            ]
            [ h3 [ style "margin" "0 0 10px 0" ] [ text post.title ]
            , p [ style "color" "#666", style "margin" "0" ]
                [ text ("작성자: " ++ String.fromInt post.userId)
                , text " | "
                , text post.createdAt
                ]
            ]
        ]
