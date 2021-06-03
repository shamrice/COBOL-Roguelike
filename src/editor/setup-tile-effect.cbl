      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-12
      *> Last Updated: 2021-06-02
      *> Purpose: Sets up tile effect data based on tile effect id.
      *> Tectonics:
      *>     ./build_editor.sh
      *>*****************************************************************
       identification division.
       program-id. setup-tile-effect.

       environment division.

       configuration section.

       input-output section.

       file-control.
  
       data division.

       file section.


       working-storage section.

       copy screenio.

       copy "shared/copybooks/ws-constants.cpy".

       01  ws-filler                   pic a.

       01  ws-blank-line               pic a(50) value spaces.

       linkage section.

       01  l-cursor-tile-effect-id            pic 99.

       01  l-cursor-teleport-settings.
           05  l-cursor-tel-dest-y            pic 99.
           05  l-cursor-tel-dest-x            pic 99.
           05  l-cursor-tel-dest-map          pic x(15).              

       01  l-cursor-draw-char                 pic x.

       procedure division using 
           l-cursor-tile-effect-id l-cursor-teleport-settings
           l-cursor-draw-char.
       
       main-procedure.

           evaluate l-cursor-tile-effect-id

               when ws-no-tile-effect-id
                   goback

               when ws-teleport-effect-id
                   perform setup-teleport

               when ws-conveyor-right-effect-id
                   move ">" to l-cursor-draw-char
   
               when ws-conveyor-down-effect-id
                   move "v" to l-cursor-draw-char

               when ws-conveyor-left-effect-id
                   move "<" to l-cursor-draw-char
                  
               when ws-conveyor-up-effect-id
                   move "^" to l-cursor-draw-char

               when ws-conveyor-reverse-effect-id
                   move "\" to l-cursor-draw-char

               when ws-player-start-effect-id
                   display "Nothing to set." at 2101
              
               when other 
                   display ws-blank-line at 2101
                   display "Not implemented. Press any key." at 2101
                   accept ws-filler at 2150 with auto-skip no-echo 
                   display ws-blank-line at 2101
                   move zeros to l-cursor-tile-effect-id                   

           end-evaluate 
          
           goback.

       setup-teleport.
           display "Enter teleport destination map: " at 2101
           accept l-cursor-tel-dest-map at 2133 update upper           
           display "Enter teleport destination Y position: " at 2101
           accept l-cursor-tel-dest-y at 2140 update 
           display "Enter teleport destination X position: " at 2101
           accept l-cursor-tel-dest-x at 2140 update 

           if l-cursor-tel-dest-map = spaces or l-cursor-tel-dest-y <= 0 
           or l-cursor-tel-dest-x <= 0 then 
               move zeros to l-cursor-tile-effect-id 
               display "Tile effect canceled. Press Enter.  " at 2101
               display "                         " at 2135
               accept ws-filler at 2140
           end-if 

           exit paragraph.
           
       end program setup-tile-effect.
