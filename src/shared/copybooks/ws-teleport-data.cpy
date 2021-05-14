      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-07
      *> Last Updated: 2021-05-07
      *> Purpose: Shared copy book with working storage definition of
      *>          teleport data record and related variables.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_game.sh
      *>****************************************************************

       01  ws-teleport-data.
           05  ws-cur-num-teleports        pic 999 comp.
           05  ws-teleport-data-record  occurs 0 to ws-max-num-teleports
                                      depending on ws-cur-num-teleports.
               10  ws-teleport-pos.
                   15  ws-teleport-y        pic S99.
                   15  ws-teleport-x        pic S99.
               10  ws-teleport-dest-pos.
                   15  ws-teleport-dest-y   pic S99.
                   15  ws-teleport-dest-x   pic S99.
               10  ws-teleport-dest-map     pic x(15).
