module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, field, string)
import Page.PostDetail
import Page.PostList
import Types exposing (Post, WebData(..))
import Url
import Url.Parser as Parser exposing ((</>), Parser, top)


-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


-- MODEL


type alias Model =
    { key : Nav.Key
    , page : Page
    , posts : WebData (List Post)
    , postDetail : WebData Post
    }


type Page
    = PostListPage
    | PostDetailPage Int
    | NotFound


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        page =
            urlToPage url

        ( initialModel, cmd ) =
            case page of
                PostListPage ->
                    ( { key = key
                      , page = page
                      , posts = Loading
                      , postDetail = Loading
                      }
                    , fetchPosts
                    )

                PostDetailPage id ->
                    ( { key = key
                      , page = page
                      , posts = Loading
                      , postDetail = Loading
                      }
                    , fetchPostDetail id
                    )

                NotFound ->
                    ( { key = key
                      , page = page
                      , posts = Loading
                      , postDetail = Loading
                      }
                    , Cmd.none
                    )
    in
    ( initialModel, cmd )


-- URL PARSING


urlToPage : Url.Url -> Page
urlToPage url =
    Parser.parse routeParser url
        |> Maybe.withDefault NotFound


routeParser : Parser (Page -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map PostListPage top
        , Parser.map PostDetailPage (Parser.s "post" </> Parser.int)
        ]


-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotPosts (Result Http.Error (List Post))
    | GotPostDetail (Result Http.Error Post)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            let
                page =
                    urlToPage url
            in
            case page of
                PostListPage ->
                    ( { model | page = page, posts = Loading }
                    , fetchPosts
                    )

                PostDetailPage id ->
                    ( { model | page = page, postDetail = Loading }
                    , fetchPostDetail id
                    )

                NotFound ->
                    ( { model | page = page }, Cmd.none )

        GotPosts result ->
            case result of
                Ok posts ->
                    ( { model | posts = Success (List.take 10 posts) }, Cmd.none )

                Err _ ->
                    ( { model | posts = Failure }, Cmd.none )

        GotPostDetail result ->
            case result of
                Ok post ->
                    ( { model | postDetail = Success post }, Cmd.none )

                Err _ ->
                    ( { model | postDetail = Failure }, Cmd.none )


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


-- HTTP


fetchPosts : Cmd Msg
fetchPosts =
    Http.get
        { url = "https://koreanjson.com/posts"
        , expect = Http.expectJson GotPosts (Decode.list postDecoder)
        }


fetchPostDetail : Int -> Cmd Msg
fetchPostDetail id =
    Http.get
        { url = "https://koreanjson.com/posts/" ++ String.fromInt id
        , expect = Http.expectJson GotPostDetail postDecoder
        }


postDecoder : Decoder Post
postDecoder =
    Decode.map5 Post
        (field "id" Decode.int)
        (field "title" string)
        (field "content" string)
        (field "UserId" Decode.int)
        (field "createdAt" string)


-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Korean JSON Posts"
    , body =
        [ div [ style "padding" "20px", style "font-family" "sans-serif" ]
            [ case model.page of
                PostListPage ->
                    Page.PostList.view model.posts

                PostDetailPage _ ->
                    Page.PostDetail.view model.postDetail

                NotFound ->
                    div [] [ text "404 - Page not found" ]
            ]
        ]
    }
