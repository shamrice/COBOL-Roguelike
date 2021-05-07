      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-07
      *> Last Updated: 2021-05-07
      *> Purpose: Shared copy book with linkage section definition of
      *>          player data record and related variables.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_engine.sh
      *>****************************************************************

       01  l-player.
           05  l-player-name              pic x(16).
           05  l-player-hp.
               10  l-player-hp-current    pic 999.
               10  l-player-hp-max        pic 999.
           05  l-player-pos.
               10  l-player-y             pic S99.
               10  l-player-x             pic S99.
           05  l-player-pos-delta.    
               10  l-player-pos-delta-y   pic S99.
               10  l-player-pos-delta-x   pic S99.
           05  l-player-scr-pos.  
               10  l-player-scr-y         pic 99 value 10.
               10  l-player-scr-x         pic 99 value 20.
           05  l-player-status              pic 9 value 0.
               88  l-player-status-alive    value 0.
               88  l-player-status-dead     value 1.
               88  l-player-status-attacked value 2.
               88  l-player-status-other    value 3.                   
           05  l-player-attack-damage     pic 999.
           05  l-player-level             pic 999.
           05  l-player-experience.
               10  l-player-exp-total     pic 9(7).                   
               10  l-player-exp-next-lvl  pic 9(7).    
           78  l-player-char              value "@".

