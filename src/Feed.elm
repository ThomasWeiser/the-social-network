module Feed where

import Html exposing (..)
import Html.Attributes exposing (..)

import Story
import User
import Tea exposing (Dispatcher, Effects, to)
import Tea.List as TList


-- MODEL

type alias Model =
    { stories : List Story.Model
    }


-- UPDATE

type Action
    = Story (TList.Action Story.Action)


update : User.Model -> Dispatcher Action -> Action -> Model -> (Model, Effects)
update user dispatcher feedAction model =
  case feedAction of
    Story action ->
      let
        (newStories, effects) =
          TList.update (to dispatcher Story) (Story.update user) action model.stories
      in
        ( { model | stories <- newStories }
        , effects
        )


-- VIEW

(=>) = (,)


view : Dispatcher Action -> Model -> Html
view dispatcher model =
  div
    [ myStyle ]
    (TList.view (to dispatcher Story) Story.view model.stories)


myStyle : Attribute
myStyle =
  style
    [ "flex-grow" => "1"
    , "height" => "100%"
    , "display" => "block"
    , "background-color" => "rgb(240, 240, 240)"
    , "overflow-y" => "scroll"
    ]


-- DUMMY DATA

model : Model
model =
  { stories =
      [
          {
              id = "1",
              author =
                  {
                      id = "william",
                      first = "William",
                      last = "Strunk"
                  },
              message = "In exposition and in argument, the writer must likewise never lose his hold upon the concrete; and even when he is dealing with general principles, he must furnish particular instances of their application.",
              like = { pending = False, state = False }
          },
          {
              id = "2",
              author =
                  {
                      id = "groucho",
                      first = "Groucho",
                      last = "Marx"
                  },
              message = "I wouldn't want to belong to any club that would accept me as a member.",
              like = { pending = False, state = False }
          },
          {
              id = "3",
              author =
                  {
                      id = "thomas",
                      first = "Thomas",
                      last = "Jefferson"
                  },
              message = "Banking establishments are more dangerous than standing armies.",
              like = { pending = False, state = False }
          },
          {
              id = "4",
              author =
                  {
                      id = "alexander",
                      first = "Alexander",
                      last = "Bell"
                  },
              message = "Great discoveries and improvements invariably involve the cooperation of many minds. I may be given credit for having blazed the trail but when I look at the subsequent developments I feel the credit is due to others rather than to myself.",
              like = { pending = False, state = False }
          },
          {
              id = "5",
              author =
                  {
                      id = "theodore",
                      first = "Theodore",
                      last = "Roosevelt"
                  },
              message = "The first requisite of a good citizen in this Republic of ours is that he shall be able and willing to pull his weight.",
              like = { pending = False, state = False }
          },
          {
              id = "6",
              author =
                  {
                      id = "dwight",
                      first = "Dwight",
                      last = "Eisenhower"
                  },
              message = "Farming looks mighty easy when your plow is a pencil and you're a thousand miles from the corn field.",
              like = { pending = False, state = False }
          }
      ]
  }
