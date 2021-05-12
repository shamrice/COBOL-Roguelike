      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-07
      *> Last Updated: 2021-05-12
      *> Purpose: Shared copy book with working storage definition of
      *>          tile map data record and related variables.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_game.sh
      *>****************************************************************


       01  ws-tile-map-table-matrix.
           05  ws-tile-map           occurs ws-max-map-height times.
               10  ws-tile-map-data   occurs ws-max-map-width times.
                   15  ws-tile-fg                   pic 9.   
                   15  ws-tile-bg                   pic 9.
                   15  ws-tile-char                 pic x.
                   15  ws-tile-highlight            pic a value 'N'.
                       88 ws-tile-is-highlight      value 'Y'.
                       88 ws-tile-not-highlight     value 'N'.
                   15  ws-tile-blocking             pic a value 'N'.
                       88  ws-tile-is-blocking      value 'Y'.
                       88  ws-tile-not-blocking     value 'N'.  
                   15  ws-tile-blinking             pic a value 'N'.
                       88  ws-tile-is-blinking      value 'Y'.
                       88  ws-tile-not-blinking     value 'N'.
                   15  ws-tile-effect-id            pic 99.  
                   15  ws-tile-visibility           pic 999.    


       
      