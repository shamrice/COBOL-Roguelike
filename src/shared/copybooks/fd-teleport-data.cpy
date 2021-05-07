      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-07
      *> Last Updated: 2021-05-07
      *> Purpose: Shared copy book with file descriptor definition of
      *>          teleport data file.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_game.sh
      *>****************************************************************

       fd  fd-teleport-data.
       01  f-teleport-data-record.
           05  f-teleport-pos.
               10  f-teleport-y        pic S99.
               10  f-teleport-x        pic S99.
           05  f-teleport-dest-pos.
               10  f-teleport-dest-y   pic S99.
               10  f-teleport-dest-x   pic S99.
           05  f-teleport-dest-map     pic x(15).

