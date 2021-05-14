      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-07
      *> Last Updated: 2021-05-07
      *> Purpose: Shared copy book with working storage definition of
      *>          enemy data record and related variables.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_game.sh
      *>****************************************************************
       

       01  ws-enemy-data.
           05  ws-cur-num-enemies           pic 99 comp value 0.
           05  ws-enemy             occurs 0 to ws-max-num-enemies times
                                    depending on ws-cur-num-enemies.
               10  ws-enemy-name           pic x(16) value 'NONAME'.
               10  ws-enemy-hp.
                   15  ws-enemy-hp-total    pic 999 value 10.
                   15  ws-enemy-hp-current  pic 999 value 10.
               10  ws-enemy-attack-damage   pic 999 value 1.
               10  ws-enemy-pos.
                   15  ws-enemy-y           pic 99.
                   15  ws-enemy-x           pic 99.
               10  ws-enemy-color           pic 9 value 4.
               10  ws-enemy-char            pic x.
               10  ws-enemy-status              pic 9 value 3.
                   88  ws-enemy-status-alive    value 0.
                   88  ws-enemy-status-dead     value 1.
                   88  ws-enemy-status-attacked value 2.
                   88  ws-enemy-status-other    value 3.
               10  ws-enemy-movement-ticks.
                   15  ws-enemy-current-ticks   pic 999.
                   15  ws-enemy-max-ticks       pic 999.
               10  ws-enemy-exp-worth           pic 9(4).
