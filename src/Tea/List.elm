module Tea.List
    ( Action
    , actionFor
    , update
    , view
    )
    where

import Html
import Tea exposing (Dispatcher, Effects, Updater, Viewer, to)


type Action subaction
    = UpdateElement Int subaction


actionFor : Int -> subaction -> Action subaction
actionFor =
  UpdateElement


update
    : Dispatcher (Action subaction)
    -> Updater model subaction
    -> Action subaction
    -> List model
    -> (List model, Effects)
update dispatcher subupdate (UpdateElement index subaction) models =
  let
    indexedUpdate index' model =
      if index == index' then
        subupdate (to dispatcher (UpdateElement index)) subaction model
      else
        (model, Tea.doNothing)

    (newModels, effects) =
      List.unzip (List.indexedMap indexedUpdate models)
  in
    (newModels, Tea.batch effects)


view
    : Dispatcher (Action subaction)
    -> Viewer model subaction
    -> List model
    -> List Html.Html
view dispatcher subview models =
  let
    indexedView index model =
      subview (to dispatcher (UpdateElement index)) model
  in
    List.indexedMap indexedView models

