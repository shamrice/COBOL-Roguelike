      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-11
      *> Last Updated: 2021-05-14
      *> Purpose: Shared copy book with working storage definition of
      *>          item data record and related variables.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_game.sh
      *>****************************************************************

       01  ws-item-data.
           05  ws-cur-num-items            pic 999 comp.
           05  ws-item-data-record         occurs 0 to ws-max-num-items
                                          depending on ws-cur-num-items.
               10  ws-item-name            pic x(16).                                          
               10  ws-item-pos.
                   15  ws-item-y           pic S99.
                   15  ws-item-x           pic S99.
               10  ws-item-taken           pic a value 'N'.
                   88  ws-item-is-taken    value 'Y'.
                   88  ws-item-not-taken   value 'N'.               
               10  ws-item-effect-id       pic 99.
               10  ws-item-worth           pic 999.
               10  ws-item-color           pic 9. 
               10  ws-item-char            pic x.
               