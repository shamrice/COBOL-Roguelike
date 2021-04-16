      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-12
      *> Last Updated: 2021-04-16
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

           01  ws-map-files.  
               05  ws-map-name             pic x(15) value "world1".
               05  ws-map-name-temp        pic x(15) value "world1".           
               05  ws-map-dat-file         pic x(15).               
               05  ws-map-tel-file         pic x(15).
                          
           78  ws-data-file-ext            value ".dat".
           78  ws-teleport-file-ext        value ".tel".

           01  ws-filler                   pic a.

           01  ws-blank-line               pic a(50) value spaces.

      *> Tile effect ids           
           01  ws-teleport-effect-id constant as 01.


       linkage section.
           01  l-tile-effect-id             pic 99.

           01  l-teleport-data-record.
               05  l-teleport-pos.
                   10  l-teleport-y        pic S99.
                   10  l-teleport-x        pic S99.
               05  l-teleport-dest-pos.
                   10  l-teleport-dest-y   pic S99.
                   10  l-teleport-dest-x   pic S99.
               05  l-teleport-dest-map     pic x(15).           

       procedure division using l-tile-effect-id l-teleport-data-record.
       
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
           accept l-teleport-dest-map at 2133 update 
           display "Enter teleport destination Y position: " at 2101
           accept l-teleport-dest-y at 2140 update 
           display "Enter teleport destination X position: " at 2101
           accept l-teleport-dest-x at 2140 update 

           if l-teleport-dest-map = spaces or l-teleport-dest-y <= 0 
               or l-teleport-dest-x <= 0 then 
               move zeros to l-tile-effect-id 
               display "Tile effect canceled. Press Enter.  " at 2101
               display "                         " at 2135
               accept ws-filler at 2140
           end-if 

           exit paragraph.
           
       end program setup-tile-effect.
