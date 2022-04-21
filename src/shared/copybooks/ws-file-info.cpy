      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-07
      *> Last Updated: 2022-04-21
      *> Purpose: Shared copy book with working storage definition of
      *>          file names, file statuses, etc.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_game.sh
      *>****************************************************************

       01  ws-map-files.  
           05  ws-map-name             pic x(15) value "VOIDSPACE".
           05  ws-map-name-temp        pic x(15) value "VOIDSPACE".           
           05  ws-map-dat-file         pic x(15).               
           05  ws-map-tel-file         pic x(15).
           05  ws-map-enemy-file       pic x(15).
           05  ws-map-item-file        pic x(15).
           05  ws-map-working-dir      pic x(1024).

       01  ws-map-file-statuses.
           05  ws-map-file-status      pic xx.
           05  ws-teleport-file-status pic xx.
           05  ws-enemy-file-status    pic xx.
           05  ws-item-file-status     pic xx.



