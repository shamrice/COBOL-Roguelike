      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-07
      *> Last Updated: 2021-05-07
      *> Purpose: Shared copy book with linkage section definition of
      *>          teleport data record and related variables.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_game.sh
      *>****************************************************************

       01  l-teleport-data.
           05  l-cur-num-teleports        pic 999 comp.
           05  l-teleport-data-record     occurs 0 
                                          to ws-max-num-teleports
                                      depending on l-cur-num-teleports.
               10  l-teleport-pos.
                   15  l-teleport-y        pic S99.
                   15  l-teleport-x        pic S99.
               10  l-teleport-dest-pos.
                   15  l-teleport-dest-y   pic S99.
                   15  l-teleport-dest-x   pic S99.
               10  l-teleport-dest-map     pic x(15).  
