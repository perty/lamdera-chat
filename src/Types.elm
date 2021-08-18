module Types exposing (BackendModel, BackendMsg(..), FrontendModel, FrontendMsg(..), Message, ToBackend(..), ToFrontend(..), ViewMode(..))

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict
import Lamdera exposing (SessionId)
import Url exposing (Url)


type alias Message =
    String


type ViewMode
    = Login
    | Chat


type alias FrontendModel =
    { key : Key
    , messages : List Message
    , clientId : ClientId
    , currentMessage : String
    , viewMode : ViewMode
    , userName : String
    }


type alias BackendModel =
    { messages : List Message
    , sessions : Dict.Dict SessionId (List ClientId)
    , users : Dict.Dict SessionId User
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | UpdateCurrentMessage String
    | UpdateUserName String
    | PressedLogin
    | SendMessage


type ToBackend
    = LoginUser String
    | NewMessage String
    | LoadMessages


type BackendMsg
    = ClientConnect SessionId ClientId
    | ClientDisconnect SessionId ClientId


type ToFrontend
    = LoggedIn ClientId
    | AllMessages (List Message) ClientId
    | NewMessages (List Message)


type alias ClientId =
    String


type alias User =
    String
