      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-07
      *> Last Updated: 2021-05-07
      *> Purpose: Shared copy book with file descriptor definition of
      *>          enemy data file.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_game.sh
      *>****************************************************************

       fd  fd-enemy-data.           
       01  f-enemy.
           05  f-enemy-name                 pic x(16).
           05  f-enemy-hp.
               10  f-enemy-hp-total         pic 999.
               10  f-enemy-hp-current       pic 999.
           05  f-enemy-attack-damage        pic 999.
           05  f-enemy-pos.
               10  f-enemy-y                pic 99.
               10  f-enemy-x                pic 99.
           05  f-enemy-color                pic 9. 
           05  f-enemy-char                 pic x. 
           05  f-enemy-status               pic 9.
           05  f-enemy-movement-ticks.
               10  f-enemy-current-ticks    pic 999.
               10  f-enemy-max-ticks        pic 999.
           05  f-enemy-exp-worth            pic 9(4).     
