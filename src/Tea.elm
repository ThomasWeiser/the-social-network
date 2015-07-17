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

type Effects
  = NoEffect
  | SingleTask (Task.Task Never ())
  | Sequential (List Effects)
  | Concurrent (List Effects)


doNothing : Effects
doNothing =
  NoEffect


arbitraryTask : Dispatcher action -> Task.Task Never action -> Effects
arbitraryTask dispatcher task =
  SingleTask ( task `Task.andThen` Signal.send dispatcher )


batch : List Effects -> Effects
batch = Sequential


effectsToTask : Effects -> Task.Task Never ()
effectsToTask effects =
  case effects of
    NoEffect ->
      Task.succeed ()
    SingleTask task ->
      task
    Sequential listOfEffects ->
      List.map effectsToTask listOfEffects
      |> Task.sequence
      |> Task.map (always ())
    Concurrent listOfEffects ->
      List.map (effectsToTask >> Task.spawn) listOfEffects
      |> Task.sequence
      |> Task.map (always ())


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

    stateToTask (_, effects) =
      effectsToTask effects
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

