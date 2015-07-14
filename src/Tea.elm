module Tea
  ( Dispatcher, to
  , Viewer
  , Updater
  , Effects, doNothing, arbitraryTask, batch
  , Never
  , start
  )
  where


import Html exposing (Html)
import Task


-- CONVIENT ALIASES

type alias Viewer model action =
  Dispatcher action -> model -> Html


type alias Updater model action =
  Dispatcher action -> action -> model -> (model, Effects)


-- DISPATCHERS

type alias Dispatcher a =
    Signal.Address a


to : Dispatcher b -> (a -> b) -> Dispatcher a
to dispatcher f =
  Signal.forwardTo dispatcher f


-- EFFECTS

type Effects =
    Effects (List (Task.Task Never ()))


doNothing : Effects
doNothing =
  Effects []


arbitraryTask : Dispatcher action -> Task.Task Never action -> Effects
arbitraryTask dispatcher task =
  Effects [ task `Task.andThen` Signal.send dispatcher ]


batch : List Effects -> Effects
batch effectList =
  Effects (List.concatMap (\(Effects effects) -> effects) effectList)


-- NEVER

type Never = Never Never


-- START

start : App model action -> Output
start app =
  let
    actions =
      Signal.mailbox Nothing

    address =
      Signal.forwardTo actions.address Just

    state =
      Signal.foldp
        (\(Just action) (model, _) -> app.update address action model)
        (app.model, doNothing)
        actions.signal

    stateToTask (_, Effects taskList) =
      Task.sequence taskList
        `Task.andThen` \_ -> Task.succeed ()
  in
    { frames =
        Signal.map (app.view address << fst) state
    , effects =
        Signal.map stateToTask state
    }



type alias App model action =
    { model : model
    , view : Viewer model action
    , update : Updater model action
    }


type alias Output =
    { frames : Signal Html
    , effects : Signal (Task.Task Never ())
    }

