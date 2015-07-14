module User where

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Json exposing ((:=))

import Utils exposing (..)


type alias Model =
    { id : String
    , first : String
    , last : String
    }


-- JSON

decoder : Json.Decoder Model
decoder =
  Json.object3
    Model
    ("id" := Json.string)
    ("first" := Json.string)
    ("last" := Json.string)


-- UPDATE

type Action
    = NoOp


update : Dispatcher Action -> Action -> Model -> (Model, Effects)
update dispatcher action model =
    case action of
        NoOp ->
            (model, doNothing)


-- VIEW

view : Dispatcher Action -> Model -> Html
view dispatcher {first, last, id} =
    div
      []
      [ text (first ++ " " ++ last)
      , img [src ("/user/" ++ id ++ "/picture")] []
      ]


toLink : Model -> Html
toLink {first, last, id} =
  a [ href ("/user/" ++ id) ] [ text (first ++ " " ++ last) ]

