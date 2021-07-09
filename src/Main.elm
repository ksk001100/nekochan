module Main exposing (..)

import Browser
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src)
import Http
import Json.Decode exposing (Decoder, field, string)



---- FLAGS ----


type alias Flags =
    { apiKey : String }



---- MODEL ----


type State
    = Failure
    | Loading
    | Success (List String)


type alias Model =
    { flags : Flags
    , state : State
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { flags = flags, state = Loading }, getCats flags.apiKey )



---- UPDATE ----


type Msg
    = GotCats (Result Http.Error (List String))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotCats result ->
            case result of
                Ok images ->
                    ( { flags = model.flags, state = Success images }, Cmd.none )

                Err _ ->
                    ( { flags = model.flags, state = Failure }, Cmd.none )



---- VIEW ----


viewImage : String -> Html Msg
viewImage image =
    img [ src image ] []


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Neko chan" ]
        , div []
            (case model.state of
                Success images ->
                    List.map viewImage images

                _ ->
                    List.map viewImage []
            )
        ]



---- HTTP ----


getCats : String -> Cmd Msg
getCats apiKey =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "x-api-key" apiKey
            ]
        , url = "https://api.thecatapi.com/v1/images/search?limit=100"
        , expect = Http.expectJson GotCats catsDecoder
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }


catsDecoder : Decoder (List String)
catsDecoder =
    Json.Decode.list
        (field "url" string)



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
