module Main exposing (..)

import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Modal as Modal
import Browser
import Html exposing (Html, audio, button, div, h1, img, text)
import Html.Attributes exposing (id, src, style)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, field, string)
import Ports exposing (playAudio)



---- MODEL ----


type alias Flags =
    { apiKey : String }


type CatImageState
    = Failure
    | Loading
    | Success (List String)


type alias Model =
    { flags : Flags
    , catImageState : CatImageState
    , modalVisibility : Modal.Visibility
    , selectImageUrl : Maybe String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { flags = flags, catImageState = Loading, modalVisibility = Modal.hidden, selectImageUrl = Nothing }, getCats flags.apiKey )



---- UPDATE ----


type Msg
    = GotCats (Result Http.Error (List String))
    | CloseModal
    | ShowModal String
    | PlayAudio


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotCats result ->
            case result of
                Ok images ->
                    ( { model | catImageState = Success images }, Cmd.none )

                Err _ ->
                    ( { model | catImageState = Failure }, Cmd.none )

        CloseModal ->
            ( { model | modalVisibility = Modal.hidden, selectImageUrl = Nothing }, Cmd.none )

        ShowModal imageUrl ->
            ( { model | modalVisibility = Modal.shown, selectImageUrl = Just imageUrl }, Cmd.none )

        PlayAudio ->
            ( model, playAudio () )



---- VIEW ----


viewAudioButton : Html Msg
viewAudioButton =
    div []
        [ button
            [ onClick PlayAudio
            , style "position" "fixed"
            , style "bottom" "10px"
            , style "right" "10px"
            , style "width" "10vh"
            , style "height" "10vh"
            , style "padding" "0"
            , style "margin" "0"
            , style "background" "none"
            , style "border" "none"
            ]
            [ img
                [ src "%PUBLIC_URL%/assets/images/nikukyuu.png"
                , style "width" "10vh"
                , style "height" "10vh"
                , style "padding" "0"
                , style "margin" "0"
                ]
                []
            ]
        , audio [ src "%PUBLIC_URL%/assets/sounds/meow.mp3", id "audio-player" ] []
        ]


viewImage : String -> Html Msg
viewImage image =
    img [ src image, style "margin" "15px", onClick (ShowModal image) ] []


viewModal : Model -> Html Msg
viewModal model =
    Modal.config CloseModal
        |> Modal.small
        |> Modal.body []
            [ Grid.containerFluid [ style "text-align" "center" ]
                [ case model.selectImageUrl of
                    Just url ->
                        img [ src url ] []

                    Nothing ->
                        text ""
                ]
            ]
        |> Modal.view model.modalVisibility


viewMainContent : Model -> Html Msg
viewMainContent model =
    div []
        [ h1 [ style "text-align" "center" ] [ text "Neko chan" ]
        , div [ style "text-align" "center" ]
            (case model.catImageState of
                Success images ->
                    List.map viewImage images

                _ ->
                    List.map viewImage []
            )
        , viewModal model
        , viewAudioButton
        ]


view : Model -> Html Msg
view model =
    Grid.container []
        [ CDN.stylesheet
        , viewMainContent model
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
