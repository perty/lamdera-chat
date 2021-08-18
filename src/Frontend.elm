module Frontend exposing (app)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Element exposing (Color, Element, column, fill, height, minimum, padding, rgb255, row, scrollbarY, text, width)
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
        , subscriptions = \_ -> Sub.none
        , view = view
        }


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init _ key =
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

        UrlChanged _ ->
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
    { title = "The chat!"
    , body =
        [ Element.layout [ Element.width Element.fill, Element.height Element.fill ] <|
            viewChat model
        ]
    }


viewChat : Model -> Element.Element FrontendMsg
viewChat model =
    column [ width fill, height <| minimum 0 <| fill ]
        [ viewMessages model.messages
        , viewInput model.currentMessage
        ]


viewMessages : List Message -> Element msg
viewMessages messages =
    column [ height <| minimum 0 <| fill, scrollbarY ] <|
        List.map viewMessage messages


viewMessage : Message -> Element msg
viewMessage message =
    text message


viewInput : String -> Element FrontendMsg
viewInput currentMessage =
    row [ width fill ]
        [ Input.text []
            { text = currentMessage
            , label = Input.labelHidden "input"
            , onChange = UpdateCurrentMessage
            , placeholder = Nothing
            }
        , button "Send" SendMessage
        ]


button : String -> msg -> Element msg
button label msg =
    Input.button
        [ Font.size 28
        , padding 10
        , Background.color buttonBackground
        , Font.center
        , Border.rounded 10
        ]
        { label = text label, onPress = Just msg }


buttonBackground : Color
buttonBackground =
    rgb255 0 128 0
