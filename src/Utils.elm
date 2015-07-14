module Utils
  ( (=>)
  , Dispatcher, tag
  , Effects, doNothing, arbitraryTask, batch
  , Never
  , start
  ) where


import Debug
import Html exposing (Html)
import Task


(=>) = (,)


-- DISPATCHERS

type alias Dispatcher a =
    Signal.Address a


tag : (a -> b) -> Dispatcher b -> Dispatcher a
tag f dispatcher =
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
        {
            frames =
                Signal.map (app.view address << fst) state
        ,
            effects =
                Signal.map stateToTask state
        }



type alias App model action =
    {
        model : model,
        view : Dispatcher action -> model -> Html,
        update : Dispatcher action -> action -> model -> (model, Effects)
    }

type alias Output =
    {
        frames : Signal Html,
        effects : Signal (Task.Task Never ())
    }