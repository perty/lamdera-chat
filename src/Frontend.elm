module Frontend exposing (Model, app, init, update, updateFromBackend, view)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Element
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Lamdera exposing (sendToBackend)
import Types exposing (..)
import Url


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , messages = []
      , clientId = ""
      , currentMessage = ""
      }
    , sendToBackend LoadMessages
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                External url ->
                    ( model, Nav.load url )

        UrlChanged url ->
            ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )

        UpdateCurrentMessage string ->
            ( { model | currentMessage = string }, Cmd.none )

        SendMessage ->
            ( { model | currentMessage = "" }, sendToBackend <| NewMessage model.currentMessage )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        AllMessages messages clientId ->
            ( { model | messages = messages, clientId = clientId }, Cmd.none )

        NewMessages messages ->
            ( { model | messages = messages }, Cmd.none )


view : Model -> Browser.Document FrontendMsg
view model =
    { title = "The counter!"
    , body =
        [ Element.layout [ Element.width Element.fill, Element.height Element.fill ] <|
            viewChat model
        ]
    }


viewChat : Model -> Element.Element FrontendMsg
viewChat model =
    Element.column []
        [ viewMessages model.messages
        , viewInput model.currentMessage
        ]


viewMessages : List Message -> Element.Element msg
viewMessages messages =
    Element.column [] <| List.map viewMessage messages


viewMessage : Message -> Element.Element msg
viewMessage message =
    Element.text message


viewInput : String -> Element.Element FrontendMsg
viewInput currentMessage =
    Element.row [ Element.width Element.fill ]
        [ Input.text []
            { text = currentMessage
            , label = Input.labelHidden "input"
            , onChange = UpdateCurrentMessage
            , placeholder = Nothing
            }
        , button "Send" SendMessage
        ]


button : String -> msg -> Element.Element msg
button text msg =
    Input.button
        [ Font.size 28
        , Element.padding 10
        , Background.color buttonBackground
        , Font.center
        , Border.rounded 10
        ]
        { label = Element.text text, onPress = Just msg }


buttonBackground : Element.Color
buttonBackground =
    Element.rgb255 0 128 0
