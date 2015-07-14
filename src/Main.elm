module Main where

import Task exposing (Task)

import TheSocialNetwork as TSN
import Tea


app =
    Tea.start
        {
            model = TSN.model,
            view = TSN.view,
            update = TSN.update
        }


main =
    app.frames


port services : Signal (Task Tea.Never ())
port services =
    app.effects