      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-23
      *> Last Updated: 2021-05-03
      *> Purpose: Module for engine to display debug information.
      *> Tectonics:
      *>     ./build_engine.sh
      *>*****************************************************************
       identification division.
       program-id. display-debug.

       environment division.

       data division.

       working-storage section.

      *> Color constants:    
           01  black   constant as 0.
           01  blue    constant as 1.
           01  green   constant as 2.
           01  cyan    constant as 3.
           01  red     constant as 4.
           01  magenta constant as 5.
           01  yellow  constant as 6.  
           01  white   constant as 7.

      *> Tile effect ids           
           01  ws-teleport-effect-id  constant as 01.


           78  ws-max-map-height            value 25.
           78  ws-max-map-width             value 80.
           78  ws-max-view-height           value 20.
           78  ws-max-view-width            value 50.
           78  ws-max-num-enemies           value 99.

       local-storage section.
    

           01  ws-kb-input                  pic x.

           01  ws-exit-sw                   pic a value 'N'.
               88  ws-exit                  value 'Y'.
               88  ws-not-exit              value 'N'.              

       linkage section.

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


       *> TODO : Copy book!!
           01  l-tile-map-table-matrix.
               05  l-tile-map           occurs ws-max-map-height times.
                   10  l-tile-map-data  occurs ws-max-map-width times.
                       15  l-tile-fg                   pic 9.   
                       15  l-tile-bg                   pic 9.
                       15  l-tile-char                 pic x.
                       15  l-tile-highlight            pic a value 'N'.
                           88 l-tile-is-highlight      value 'Y'.
                           88 l-tile-not-highlight     value 'N'.
                       15  l-tile-blocking             pic a value 'N'.
                           88  l-tile-is-blocking      value 'Y'.
                           88  l-tile-not-blocking     value 'N'.  
                       15  l-tile-blinking             pic a value 'N'.
                           88  l-tile-is-blinking      value 'Y'.
                           88  l-tile-not-blinking     value 'N'.
                       15  l-tile-effect-id            pic 99.       


           01  l-enemy-data.
               05  l-cur-num-enemies           pic 99.
               05  l-enemy       occurs 0 to unbounded times
                                  depending on l-cur-num-enemies.
                   10  l-enemy-name            pic x(16).
                   10  l-enemy-hp.
                       15  l-enemy-hp-total    pic 999 value 10.
                       15  l-enemy-hp-current  pic 999 value 10.
                   10  l-enemy-attack-damage   pic 999 value 1.
                   10  l-enemy-pos.
                       15  l-enemy-y           pic 99.
                       15  l-enemy-x           pic 99.
                   10  l-enemy-color           pic 9 value red.                                     
      *>TODO: this isn't configurable once enemy is hit.
                   10  l-enemy-char            pic x value "&". 
                       88  l-enemy-char-alive  value "&".
                       88  l-enemy-char-dead   value "X".
                       88  l-enemy-char-hurt   value "#".
                   10  l-enemy-status              pic 9 value 0.
                       88  l-enemy-status-alive    value 0.
                       88  l-enemy-status-dead     value 1.
                       88  l-enemy-status-attacked value 2.
                       88  l-enemy-status-other    value 3.
                   10  l-enemy-movement-ticks.
                       15  l-enemy-current-ticks   pic 999.
                       15  l-enemy-max-ticks       pic 999 value 3.  
                   10  l-enemy-exp-worth           pic 9(4).                                

           01  l-temp-map-pos.
               05  l-temp-map-pos-y        pic S99.
               05  l-temp-map-pos-x        pic S99.

       procedure division using 
               l-player l-tile-map-table-matrix l-enemy-data
               l-temp-map-pos.

       main-procedure.

           display space blank screen

           display "Debug Info" at 0115 with underline highlight 

           display "pscrpos: " at 1960 l-player-scr-pos at 1970
           display "P delta: " at 2101 l-player-pos-delta at 2110
           display "Pyx: " at 2301 l-player-pos at 2305
           display "MAPyx: " at 2240 l-temp-map-pos at 2246

       

           perform with test after until ws-exit 
               accept ws-kb-input at 0125
               if ws-kb-input = 'q' then 
                   set ws-exit to true 
               end-if 
           end-perform 
               
           goback.

       end program display-debug.
