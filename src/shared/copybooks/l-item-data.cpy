      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-11
      *> Last Updated: 2021-05-11
      *> Purpose: Shared copy book with linkage section definition of
      *>          item data record and related variables.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_game.sh
      *>****************************************************************

       01  l-item-data.
           05  l-cur-num-items            pic 999 comp.
           05  l-item-data-record         occurs 0 to ws-max-num-items
                                          depending on l-cur-num-items.
               10  l-item-name            pic x(16).                                          
               10  l-item-pos.
                   15  l-item-y           pic S99.
                   15  l-item-x           pic S99.
               10  l-item-taken           pic a value 'N'.
                   88  l-item-is-taken    value 'Y'.
                   88  l-item-not-taken   value 'N'.               
               10  l-item-effect-id       pic 99.
               10  l-item-worth           pic 999.
               10  l-item-color           pic 9. 
               10  l-item-char            pic x.               
