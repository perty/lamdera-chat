module Backend exposing (Model, app, init, update, updateFromFrontend)

import Dict
import Lamdera exposing (ClientId, SessionId, broadcast, onConnect, onDisconnect, sendToFrontend)
import List.Extra
import Types exposing (..)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub BackendMsg
subscriptions _ =
    Sub.batch
        [ onConnect ClientConnect
        , onDisconnect ClientDisconnect
        ]


init : ( Model, Cmd BackendMsg )
init =
    ( { messages = []
      , sessions = Dict.empty
      , users = Dict.empty
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        ClientConnect sessionId clientId ->
            let
                currentClients =
                    Dict.get sessionId model.sessions |> Maybe.withDefault []
            in
            ( { model | sessions = Dict.insert sessionId (clientId :: currentClients) model.sessions }, Cmd.none )

        ClientDisconnect sessionId clientId ->
            let
                currentClients =
                    Dict.get sessionId model.sessions |> Maybe.withDefault []

                newSessions =
                    Dict.insert sessionId (List.Extra.remove clientId currentClients) model.sessions
            in
            ( { model
                | sessions = newSessions
                , users =
                    if (Dict.get sessionId newSessions |> Maybe.withDefault [] |> List.length) == 0 then
                        Dict.remove sessionId model.users

                    else
                        model.users
              }
            , Cmd.none
            )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        LoginUser userName ->
            ( { model | users = Dict.insert sessionId userName model.users }
            , sendToFrontend clientId (LoggedIn clientId)
            )

        LoadMessages ->
            ( model, sendToFrontend clientId (AllMessages model.messages clientId) )

        NewMessage message ->
            let
                newMessages =
                    model.messages ++ [ message ]
            in
            ( { model | messages = newMessages }, broadcast <| NewMessages newMessages )
