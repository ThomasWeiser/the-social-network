module TheSocialNetwork where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (lazy2)

import Ads
import Feed
import Sidebar
import User
import Utils exposing ((=>), Dispatcher, Effects, tag)


-- MODEL

type alias Model =
    { sidebar : Sidebar.Model
    , feed : Feed.Model
    , ads : Ads.Model
    }


model : Model
model =
  { sidebar = Sidebar.model
  , feed = Feed.model
  , ads = Ads.model
  }


user : User.Model
user =
  { id = "alice"
  , first = "Alice"
  , last = "Smith"
  }


-- UPDATE

type Action
    = Sidebar Sidebar.Action
    | Feed Feed.Action
    | Ads Ads.Action


update : Dispatcher Action -> Action -> Model -> (Model, Effects)
update dispatcher tsnAction model =
    case tsnAction of
        Sidebar action ->
            let
                (newSidebar, effects) =
                    Sidebar.update (tag Sidebar dispatcher) action model.sidebar
            in
                ( { model | sidebar <- newSidebar }
                , effects
                )

        Feed action ->
            let
                (newFeed, effects) =
                    Feed.update user (tag Feed dispatcher) action model.feed
            in
                ( { model | feed <- newFeed }
                , effects
                )

        Ads action ->
            let
                (newAds, effects) =
                    Ads.update (tag Ads dispatcher) action model.ads
            in
                ( { model | ads <- newAds }
                , effects
                )



view : Dispatcher Action -> Model -> Html
view dispatcher model =
    div
        [
            class "the-social-network",
            style
                [
                    "width" => "100%",
                    "height" => "100%",
                    "display" => "flex",
                    "flex-direction" => "row"
                ]
        ]
        [
            lazy2
                Sidebar.view
                (tag Sidebar dispatcher)
                model.sidebar
        ,
            lazy2
                Feed.view
                (tag Feed dispatcher)
                model.feed
        ,
            lazy2
                Ads.view
                (tag Ads dispatcher)
                model.ads
        ]