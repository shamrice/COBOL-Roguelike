      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-12
      *> Last Updated: 2021-05-27
      *> Purpose: Sets up tile effect data based on tile effect id.
      *> Tectonics:
      *>     ./build_editor.sh
      *>*****************************************************************
       identification division.
       program-id. set-tile-effect.

       environment division.

       configuration section.

       input-output section.

       file-control.
  
       data division.

       file section.

       working-storage section.      

       copy "shared/copybooks/ws-constants.cpy".

       01  ws-temp-input               pic a.

       01  ws-counter-1                pic 999 comp.
           

       local-storage section.

       01  ls-teleport-found           pic a value 'N'.
           88  ls-teleport-is-found    value 'Y'.
           88  ls-teleport-not-found   value 'N'.

       01  ls-found-idx                pic 999 comp.

       linkage section.

       01  l-placement-pos.
           05  l-placement-pos-y         pic S99.
           05  l-placement-pos-x         pic S99.  

       01  l-cur-tile-effect-id          pic 99 comp.

       copy "editor/copybooks/l-cursor.cpy".

       copy "shared/copybooks/l-teleport-data.cpy".          


       procedure division using 
           l-placement-pos l-cur-tile-effect-id 
           l-cursor l-teleport-data.
       
       main-procedure.

           evaluate l-cursor-draw-effect

               when ws-no-tile-effect-id
                   move ws-no-tile-effect-id to l-cur-tile-effect-id              

               when ws-teleport-effect-id
                   perform set-teleport

               when ws-conveyor-right-effect-id
                   perform set-conveyor-right

               when ws-conveyor-down-effect-id
                   perform set-conveyor-down

               when ws-conveyor-left-effect-id
                   perform set-conveyor-left

               when ws-conveyor-up-effect-id
                   perform set-conveyor-up

               when ws-conveyor-reverse-effect-id
                   perform set-conveyor-reverse

               when ws-player-start-effect-id
                   move ws-player-start-effect-id 
                       to l-cur-tile-effect-id

               when other 
                   display "Not implemented" at 2525

           end-evaluate 
          
           goback.


       set-teleport.        
      *> Check to see if teleport was previously placed there.
      *> If so, ask to remove it.
           set ls-teleport-not-found to true
           move zeros to ls-found-idx

           perform varying ws-counter-1 from 1 by 1
               until ws-counter-1 > l-cur-num-teleports

               if l-placement-pos = l-teleport-pos(ws-counter-1) then 
                   set ls-teleport-is-found to true 
                   move ws-counter-1 to ls-found-idx
                   exit perform 
               end-if 
           end-perform 

           if ls-teleport-is-found then 
               display "Remove placed teleport? [y/n] " at 2101                
               accept ws-temp-input at 2130 with auto-skip upper
               if ws-temp-input = 'Y' then                    
      *>           Shift whole array down one element, replacing deleted               
                   perform varying ws-counter-1 
                       from ls-found-idx by 1 
                       until ws-counter-1 > l-cur-num-teleports + 1
                       
                       move l-teleport-data-record(ws-counter-1 + 1) to 
                           l-teleport-data-record(ws-counter-1)
                   end-perform 

                   subtract 1 from l-cur-num-teleports
                   move zeros to l-cur-tile-effect-id             
               end-if 
               exit paragraph 
           end-if 

      *> Place new teleport if none exists 
           if l-cursor-tel-dest-y not = zeros 
               and l-cursor-tel-dest-x not = zeros
               and l-cursor-tel-dest-map not = spaces then 

               add 1 to l-cur-num-teleports
               move l-cursor-draw-effect to l-cur-tile-effect-id

               move l-placement-pos 
                   to l-teleport-pos(l-cur-num-teleports)

               move l-cursor-tel-dest-y 
                   to l-teleport-dest-y(l-cur-num-teleports)

               move l-cursor-tel-dest-x
                   to l-teleport-dest-x(l-cur-num-teleports)

               move l-cursor-tel-dest-map
                   to l-teleport-dest-map(l-cur-num-teleports)                   

               display 
                   "Teleport placed at:" at 2401 
                   l-teleport-pos(l-cur-num-teleports) at 2417                  
               end-display
           end-if    

           exit paragraph.
           

       set-conveyor-right.
           move ws-conveyor-right-effect-id to l-cur-tile-effect-id
           exit paragraph.


       set-conveyor-down.
           move ws-conveyor-down-effect-id to l-cur-tile-effect-id
           exit paragraph.

       set-conveyor-left.
           move ws-conveyor-left-effect-id to l-cur-tile-effect-id
           exit paragraph.


       set-conveyor-up.
           move ws-conveyor-up-effect-id to l-cur-tile-effect-id
           exit paragraph.

       set-conveyor-reverse.
           move ws-conveyor-reverse-effect-id to l-cur-tile-effect-id
           exit paragraph.

       end program set-tile-effect.
