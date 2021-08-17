module Types exposing (BackendModel, BackendMsg(..), FrontendModel, FrontendMsg(..), Message, ToBackend(..), ToFrontend(..))

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Url exposing (Url)


type alias Message =
    String


type alias FrontendModel =
    { key : Key
    , messages : List Message
    , clientId : ClientId
    , currentMessage : String
    }


type alias BackendModel =
    { messages : List Message
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | UpdateCurrentMessage String
    | SendMessage


type ToBackend
    = LoadMessages
    | NewMessage String


type BackendMsg
    = NoOp


type ToFrontend
    = AllMessages (List Message) ClientId
    | NewMessages (List Message)


type alias ClientId =
    String