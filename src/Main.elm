module Main where

import Task exposing (Task)

import TheSocialNetwork as TSN
import Utils


app =
    Utils.start
        {
            model = TSN.model,
            view = TSN.view,
            update = TSN.update
        }


main =
    app.frames


port services : Signal (Task Utils.Never ())
port services =
    app.effects