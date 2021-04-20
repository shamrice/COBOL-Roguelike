      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-12
      *> Last Updated: 2021-04-18
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

           01  ws-filler                   pic a.

           01  ws-blank-line               pic a(50) value spaces.

      *> Tile effect ids           
           01  ws-teleport-effect-id constant as 01.


       linkage section.
           01  l-tile-effect-id             pic 99.

           01  l-cursor-teleport-settings.
               05  l-cursor-tel-dest-y            pic 99.
               05  l-cursor-tel-dest-x            pic 99.
               05  l-cursor-tel-dest-map          pic x(15).              

       procedure division using 
           l-tile-effect-id l-cursor-teleport-settings.
       
       main-procedure.

           evaluate l-tile-effect-id

               when ws-teleport-effect-id
                   perform setup-teleport

               when other 
                   display ws-blank-line at 2101
                   display "Not implemented. Press any key." at 2101
                   accept ws-filler at 2150 with auto-skip no-echo 
                   display ws-blank-line at 2101
                   move zeros to l-tile-effect-id                   

           end-evaluate 
          
           goback.

       setup-teleport.
           display "Enter teleport destination map: " at 2101
           accept l-cursor-tel-dest-map at 2133 update            
           display "Enter teleport destination Y position: " at 2101
           accept l-cursor-tel-dest-y at 2140 update 
           display "Enter teleport destination X position: " at 2101
           accept l-cursor-tel-dest-x at 2140 update 

           if l-cursor-tel-dest-map = spaces or l-cursor-tel-dest-y <= 0 
           or l-cursor-tel-dest-x <= 0 then 
               move zeros to l-tile-effect-id 
               display "Tile effect canceled. Press Enter.  " at 2101
               display "                         " at 2135
               accept ws-filler at 2140
           end-if 

           exit paragraph.
           
       end program setup-tile-effect.