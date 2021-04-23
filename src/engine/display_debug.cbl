      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-23
      *> Last Updated: 2021-04-23
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
           01  ws-counter-1                 pic 999.
           01  ws-counter-2                 pic 999.
           01  ls-enemy-idx                 pic 99.
           
           01  ws-scr-draw-pos.
               05  ws-scr-draw-y            pic 99.
               05  ws-scr-draw-x            pic 99.

           01  ws-map-pos.           
               05  ws-map-pos-y             pic S999.
               05  ws-map-pos-x             pic S999.

           01  ws-line-mask                 pic x(80) value spaces. 

           01  ls-enemy-draw-pos    occurs 0 to ws-max-num-enemies times
                                    depending on l-cur-num-enemies.
               05  ls-enemy-draw-y          pic 99.
               05  ls-enemy-draw-x          pic 99.

           01  ws-char-to-draw              pic x. 

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

       procedure division using 
               l-player l-tile-map-table-matrix l-enemy-data.

       main-procedure.

           display space blank screen

           display "Debug Info" at 0115 with underline highlight 

           perform with test after until ws-exit 
               accept ws-kb-input at 0125
               if ws-kb-input = 'q' then 
                   set ws-exit to true 
               end-if 
           end-perform 
               
           goback.

       end program display-debug.
