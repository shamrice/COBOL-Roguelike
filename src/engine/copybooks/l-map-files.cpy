      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-08
      *> Last Updated: 2022-04-21
      *> Purpose: Shared copy book with linkage section definition of
      *>          file names, file statuses, etc.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_game.sh
      *>****************************************************************

       01  l-map-files.  
           05  l-map-name             pic x(15).
           05  l-map-name-temp        pic x(15).           
           05  l-map-dat-file         pic x(15).               
           05  l-map-tel-file         pic x(15).
           05  l-map-enemy-file       pic x(15).
           05  l-map-working-dir      pic x(1024).
           