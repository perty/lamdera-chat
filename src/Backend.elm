module Backend exposing (Model, app, init, update, updateFromFrontend)

import Html
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import Types exposing (..)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Sub.none
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { messages = [] }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend _ clientId msg model =
    case msg of
        LoadMessages ->
            ( model, sendToFrontend clientId (AllMessages model.messages clientId) )

        NewMessage message ->
            let
                newMessages =
                    model.messages ++ [ message ]
            in
            ( { model | messages = newMessages }, broadcast <| NewMessages newMessages )
