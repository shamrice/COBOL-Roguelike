      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-08
      *> Last Updated: 2021-06-02
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

       01  ws-tele-idx                   pic 999 comp.
       01  ws-idx-y                      pic 999 comp.
       01  ws-idx-x                      pic 999 comp.

       01  ws-color-temp              pic 9.

       01  ws-swap-colors-sw             pic a value 'N'.
           88  ws-swap-colors            value 'Y'.
           88  ws-not-swap-colors        value 'N'.

       
       local-storage section.
       
       01  ls-action-history-temp          pic x(75).      


       linkage section.

       01  l-tile-effect-id-src            pic 99 comp.

       01  l-tile-char-src                 pic x.       

       copy "engine/copybooks/l-player.cpy".

       01  l-temp-map-pos.
           05  l-temp-map-pos-y        pic S99.
           05  l-temp-map-pos-x        pic S99.

       copy "shared/copybooks/l-teleport-data.cpy".

       copy "engine/copybooks/l-map-files.cpy".

       copy "shared/copybooks/l-tile-map-table-matrix.cpy".

       01  l-tile-effect-return-code      pic 99.
      
       01  l-player-moved-sw              pic a.
           88  l-player-moved             value 'Y'.
           88  l-player-not-moved         value 'N'.

       copy "engine/copybooks/l-action-history.cpy".

       procedure division using 
           l-tile-effect-id-src 
           l-tile-char-src
           l-player l-temp-map-pos
           l-teleport-data l-map-files 
           l-tile-map-table-matrix
           l-player-moved-sw
           l-action-history
           l-tile-effect-return-code.

       main-procedure.

           move zeros to l-tile-effect-return-code

           if l-tile-effect-id-src is zeros then 
               goback
           end-if 
                  
           evaluate l-tile-effect-id-src

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
                   
               when ws-conveyor-reverse-effect-id 
               *>Only check switch when player steps on it.
                   if l-player-moved then                   
                       perform handle-conveyor-reverse-switch
                   end-if 
                   
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
               move ws-load-map-tele-return-code 
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


       handle-conveyor-reverse-switch.

           if l-tile-char-src = '\' then 
               move '/' to l-tile-char-src
               move "Switch pressed. Conveyor belt direction: REVERSE"
                   to ls-action-history-temp
           else 
               move '\' to l-tile-char-src
               move "Switch pressed. Conveyor belt direction: FORWARD"
                   to ls-action-history-temp
           end-if   

           call "add-action-history-item" using
               ls-action-history-temp l-action-history
           end-call                         

      *>Find conveyor belts, flip their effect id, character and 
      *>swap the fg and bg colors.

      *> TODO : All switches in the map should be flipped to match 
      *>        switch direction that was pressed. Otherwise wrong 
      *>        direction is displayed in action history.
           perform varying ws-idx-y 
           from 1 by 1 until ws-idx-y > ws-max-map-height
               perform varying ws-idx-x 
               from 1 by 1 until ws-idx-x > ws-max-map-width                   

                   set ws-not-swap-colors to true 

                   evaluate l-tile-effect-id(ws-idx-y, ws-idx-x)

                       when ws-conveyor-right-effect-id
                           move '<' to l-tile-char(ws-idx-y, ws-idx-x)
                           move ws-conveyor-left-effect-id
                               to l-tile-effect-id(ws-idx-y, ws-idx-x)
                           set ws-swap-colors to true 

                       when ws-conveyor-down-effect-id
                           move '^' to l-tile-char(ws-idx-y, ws-idx-x)
                           move ws-conveyor-up-effect-id
                               to l-tile-effect-id(ws-idx-y, ws-idx-x)
                           set ws-swap-colors to true 

                       when ws-conveyor-left-effect-id
                           move '>' to l-tile-char(ws-idx-y, ws-idx-x)
                           move ws-conveyor-right-effect-id
                               to l-tile-effect-id(ws-idx-y, ws-idx-x)
                           set ws-swap-colors to true 

                       when ws-conveyor-up-effect-id
                           move 'v' to l-tile-char(ws-idx-y, ws-idx-x)
                           move ws-conveyor-down-effect-id
                               to l-tile-effect-id(ws-idx-y, ws-idx-x)
                           set ws-swap-colors to true 

                   end-evaluate

                   if ws-swap-colors then 
                       move l-tile-bg(ws-idx-y, ws-idx-x) 
                           to ws-color-temp
                       move l-tile-fg(ws-idx-y, ws-idx-x)
                           to l-tile-bg(ws-idx-y, ws-idx-x) 
                       move ws-color-temp
                           to l-tile-fg(ws-idx-y, ws-idx-x)

           *> TODO: decide if to keep blink toggle
                       if l-tile-is-blinking(ws-idx-y, ws-idx-x) then 
                           set l-tile-not-blinking(ws-idx-y, ws-idx-x)
                               to true
                       else
                           set l-tile-is-blinking(ws-idx-y, ws-idx-x)
                               to true
                       end-if  
                   end-if 

               end-perform
           end-perform
           
           exit paragraph.

       end program tile-effect-handler.
