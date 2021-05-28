      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-08
      *> Last Updated: 2021-05-27
      *> Purpose: Module for engine used to handle what happens when the
      *>          player steps on a tile that has a tile effect.
      *> Tectonics:
      *>     ./build_engine.sh
      *>*****************************************************************
       identification division.
       program-id. tile-effect-handler.

       environment division.

       data division.

       working-storage section.
       
       copy "shared/copybooks/ws-constants.cpy".

       01  ws-tele-idx                    pic 999 comp.

       local-storage section.

  
       linkage section.

       01  l-tile-effect-id               pic 99 comp.

       copy "engine/copybooks/l-player.cpy".

       01  l-temp-map-pos.
           05  l-temp-map-pos-y        pic S99.
           05  l-temp-map-pos-x        pic S99.

       copy "shared/copybooks/l-teleport-data.cpy".

       copy "engine/copybooks/l-map-files.cpy".

       01  l-tile-effect-return-code      pic 99.
      

       procedure division using 
           l-tile-effect-id l-player l-temp-map-pos
           l-teleport-data l-map-files 
           l-tile-effect-return-code.

       main-procedure.

           move zeros to l-tile-effect-return-code

           if l-tile-effect-id is zeros then 
               goback
           end-if 

           evaluate l-tile-effect-id

               when ws-teleport-effect-id
                   perform check-teleport

               when ws-conveyor-right-effect-id
                   perform handle-conveyor-right

               when ws-conveyor-down-effect-id
                   perform handle-conveyor-down

               when ws-conveyor-left-effect-id
                   perform handle-conveyor-left

               when ws-conveyor-up-effect-id
                   perform handle-conveyor-up

           end-evaluate

           goback.

      ******************************************************************
      * Checks if player steps on a teleport tile. If so, they are 
      * moved to the teleport destination.
      ******************************************************************
       check-teleport.

           if l-cur-num-teleports = 0 then 
               exit paragraph
           end-if 

           perform varying ws-tele-idx 
           from 1 by 1 until ws-tele-idx > l-cur-num-teleports
               if l-teleport-pos(ws-tele-idx) = l-temp-map-pos then 

                   compute l-player-y = 
                       l-teleport-dest-y(ws-tele-idx) - l-player-scr-y
                   end-compute 

                   compute l-player-x = 
                       l-teleport-dest-x(ws-tele-idx) - l-player-scr-x
                   end-compute 

                   if l-teleport-dest-map(ws-tele-idx) 
                   not = l-map-name then
                       move l-teleport-dest-map(ws-tele-idx) 
                           to l-map-name-temp                       
                   end-if 
                   exit perform 
               
               end-if 

           end-perform           

           *> set return code to load the map.
           if l-map-name-temp not = l-map-name then    
               move l-map-name-temp to l-map-name             
               move ws-load-map-return-code 
                   to l-tile-effect-return-code                   
           end-if    
           exit paragraph.    



       handle-conveyor-right.
           add 1 to l-player-x
           exit paragraph.


       handle-conveyor-down.
           add 1 to l-player-y
           exit paragraph.


       handle-conveyor-left.
           subtract 1 from l-player-x
           exit paragraph.


       handle-conveyor-up.
           subtract 1 from l-player-y
           exit paragraph.           


       end program tile-effect-handler.
