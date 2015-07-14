module TheSocialNetwork where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (lazy2)

import Ads
import Feed
import Sidebar
import User
import Tea exposing (Dispatcher, Effects, to)


(=>) = (,)


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
                    Sidebar.update (to dispatcher Sidebar) action model.sidebar
            in
                ( { model | sidebar <- newSidebar }
                , effects
                )

        Feed action ->
            let
                (newFeed, effects) =
                    Feed.update user (to dispatcher Feed) action model.feed
            in
                ( { model | feed <- newFeed }
                , effects
                )

        Ads action ->
            let
                (newAds, effects) =
                    Ads.update (to dispatcher Ads) action model.ads
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
                (to dispatcher Sidebar)
                model.sidebar
        ,
            lazy2
                Feed.view
                (to dispatcher Feed)
                model.feed
        ,
            lazy2
                Ads.view
                (to dispatcher Ads)
                model.ads
        ]