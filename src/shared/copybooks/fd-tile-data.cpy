      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-07
      *> Last Updated: 2021-05-07
      *> Purpose: Shared copy book with file descriptor definition of
      *>          tile data file.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_game.sh
      *>****************************************************************

       fd  fd-tile-data.
       01  f-tile-data-record.
           05  f-tile-fg               pic 9.   
           05  f-tile-bg               pic 9.
           05  f-tile-char             pic x.
           05  f-tile-highlight        pic a.
           05  f-tile-blocking         pic a.
           05  f-tile-blinking         pic a.
           05  f-tile-effect-id        pic 99.
