      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-07
      *> Last Updated: 2021-05-07
      *> Purpose: Shared copy book with linkage section definition of
      *>          enemy data record and related variables.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_game.sh
      *>****************************************************************

       01  l-enemy-data.
           05  l-cur-num-enemies           pic 99 comp.
           05  l-enemy           occurs 0 to unbounded times
                                 depending on l-cur-num-enemies.
               10  l-enemy-name            pic x(16).
               10  l-enemy-hp.
                   15  l-enemy-hp-total    pic 999 comp value 10.
                   15  l-enemy-hp-current  pic 999 comp value 10.
               10  l-enemy-attack-damage   pic 999 comp value 1.
               10  l-enemy-pos.
                   15  l-enemy-y           pic 99.
                   15  l-enemy-x           pic 99.
               10  l-enemy-color           pic 9 value red.                                     
               10  l-enemy-char            pic x.
               10  l-enemy-status              pic 9 comp value 0.
                   88  l-enemy-status-alive    value 0.
                   88  l-enemy-status-dead     value 1.
                   88  l-enemy-status-attacked value 2.
                   88  l-enemy-status-other    value 3.
               10  l-enemy-movement-ticks.
                   15  l-enemy-current-ticks   pic 999 comp.
                   15  l-enemy-max-ticks       pic 999 comp value 3.    
               10  l-enemy-exp-worth           pic 9(4) comp.         

