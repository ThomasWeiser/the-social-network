module Story where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json exposing ((:=))
import Task

import User
import Utils exposing (..)


type alias Model =
    { id : String
    , author : User.Model
    , message : String
    , like : LikeState
    }


type alias LikeState =
    { pending : Bool
    , state : Bool
    }


-- JSON

decoder : Json.Decoder Model
decoder =
  Json.object4
    Model
    ("id" := Json.string)
    ("author" := User.decoder)
    ("message" := Json.string)
    ("like" := likeStateDecoder)


likeStateDecoder : Json.Decoder LikeState
likeStateDecoder =
  let
    toLikeState bool =
      { pending = False, state = bool }
  in
    Json.map toLikeState Json.bool


-- UPDATE

type Action
    = RequestLike Bool
    | SetLike Bool


update : User.Model -> Dispatcher Action -> Action -> Model -> (Model, Effects)
update user dispatcher action story =
  case action of
    RequestLike bool ->
      (
        { story |
            like <- { pending = True, state = bool }
        }
      ,
        Utils.arbitraryTask dispatcher (requestLikeState user story bool)
      )

    SetLike bool ->
      (
        { story |
            like <- { pending = False, state = bool }
        }
      ,
        Utils.doNothing
      )


requestLikeState : User.Model -> Model -> Bool -> Task.Task Utils.Never Action
requestLikeState user story goal =
  let
    urlChunk =
      if goal then "like" else "unlike"

    postLike =
      Http.post
        (Json.succeed ())
        ("/user/" ++ user.id ++ "/" ++ urlChunk ++ "/" ++ story.id)
        Http.empty

    toAction result =
      Task.succeed <| SetLike <|
        case result of
          Err _ ->
            not goal
          Ok _ ->
            goal
  in
    Task.toResult postLike `Task.andThen` toAction


-- VIEW

view : Dispatcher Action -> Model -> Html
view dispatcher story =
  let
    eventHandler =
      if story.like.pending then
        []
      else
        [ onClick dispatcher (SetLike (not story.like.state)) ]

    likeButton =
      a (href "#" :: eventHandler)
        [ text (if story.like.state then "unlike" else "like") ]
  in
    div
      [ myStyle ]
      [ p [] [ User.toLink story.author ]
      , p [] [ text story.message ]
      , p [] [ likeButton ]
      ]


myStyle : Attribute
myStyle =
  style
    [ "width" => "80%"
    , "padding" => "10px 5%"
    , "margin" => "20px 5%"
    , "background-color" => "white"
    , "display" => "block"
    ]
