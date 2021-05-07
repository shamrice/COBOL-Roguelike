      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-23
      *> Last Updated: 2021-05-07
      *> Purpose: Module for engine to display debug information.
      *> Tectonics:
      *>     ./build_engine.sh
      *>*****************************************************************
       identification division.
       program-id. display-debug.

       environment division.

       data division.

       working-storage section.

       copy "shared/copybooks/ws-constants.cpy".


       local-storage section.
    
       01  ws-kb-input                  pic x.

       01  ws-exit-sw                   pic a value 'N'.
           88  ws-exit                  value 'Y'.
           88  ws-not-exit              value 'N'.              


       linkage section.

       copy "engine/copybooks/l-player.cpy".

       copy "shared/copybooks/l-tile-map-table-matrix.cpy".
           
       copy "shared/copybooks/l-enemy-data.cpy".                           

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
