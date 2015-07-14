module Ads where

import Html exposing (..)
import Html.Attributes exposing (..)

import Tea exposing (Dispatcher, Effects)


(=>) = (,)


type alias Model =
    {
    }


model : Model
model =
    {
    }


type Action
    = NoOp


update : Dispatcher Action -> Action -> Model -> (Model, Effects)
update dispatcher action model =
  case action of
    NoOp ->
      (model, Tea.doNothing)


view : Dispatcher Action -> Model -> Html
view dispatcher model =
    div [ myStyle ] [ text "ads" ]


myStyle : Attribute
myStyle =
  style
    [ "width" => "300px"
    , "height" => "100%"
    , "background-color" => "rgb(200, 200, 200)"
    , "display" => "flex"
    , "justify-content" => "center"
    ]