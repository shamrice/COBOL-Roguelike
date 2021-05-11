      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-11
      *> Last Updated: 2021-05-11
      *> Purpose: Shared copy book with file descriptor definition of
      *>          item data file.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_game.sh
      *>****************************************************************

       fd  fd-item-data.
       01  f-item-data-record.                               
           05  f-item-name            pic x(16).                                          
           05  f-item-pos.
               10  f-item-y           pic S99.
               10  f-item-x           pic S99.
           05  f-item-taken           pic a.
           05  f-item-effect-id       pic 99.
           05  f-item-worth           pic 999.

