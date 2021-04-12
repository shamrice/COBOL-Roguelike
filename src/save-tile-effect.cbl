      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-12
      *> Last Updated: 2021-04-12
      *> Purpose: Sets up tile effect data based on tile effect id.
      *> Tectonics:
      *>     ./build_editor.sh
      *>*****************************************************************
       identification division.
       program-id. save-tile-effect.

       environment division.

       configuration section.

       input-output section.

       file-control.

           select optional fd-teleport-data 
               assign to dynamic l-map-tel-file      
               organization is indexed
               access is dynamic 
               record key is f-teleport-pos.  
  
       data division.

       file section.

           fd  fd-teleport-data.
           01  f-teleport-data-record.
               05  f-teleport-pos.
                   10  f-teleport-y        pic S99.
                   10  f-teleport-x        pic S99.
               05  f-teleport-dest-pos.
                   10  f-teleport-dest-y   pic S99.
                   10  f-teleport-dest-x   pic S99.
               05  f-teleport-dest-map     pic x(15).

       working-storage section.

           copy screenio.

           01  ws-map-files.  
               05  ws-map-name             pic x(15) value "world1".
               05  ws-map-name-temp        pic x(15) value "world1".
               05  ws-map-dat-file         pic x(15).               
               05  ws-map-tel-file         pic x(15).
                          
           78  ws-data-file-ext            value ".dat".
           78  ws-teleport-file-ext        value ".tel".

           01  ws-temp-input               pic a.

      *> Tile effect ids           
           01  ws-teleport-effect-id constant as 01.


       linkage section.

           01  l-tile-effect-id             pic 99.

           01  l-map-files.  
               05  l-map-name             pic x(15).
               05  l-map-name-temp        pic x(15).
               05  l-map-dat-file         pic x(15).               
               05  l-map-tel-file         pic x(15).
          

           01  l-cursor-pos.
               05  l-cursor-pos-y        pic S99.
               05  l-cursor-pos-x        pic S99.

           01  l-teleport-data-record.
               05  l-teleport-pos.
                   10  l-teleport-y        pic S99.
                   10  l-teleport-x        pic S99.
               05  l-teleport-dest-pos.
                   10  l-teleport-dest-y   pic S99.
                   10  l-teleport-dest-x   pic S99.
               05  l-teleport-dest-map     pic x(15).           

       procedure division using 
           l-tile-effect-id l-map-files l-cursor-pos 
           l-teleport-data-record.
       
       main-procedure.

           evaluate l-tile-effect-id

               when ws-teleport-effect-id
                   perform save-teleport

               when other 
                   display "Not implemented" at 2525

           end-evaluate 
          
           goback.

       save-teleport.
           
      *     compute ws-temp-map-pos-y = ws-cursor-pos-y + ws-cursor-scr-y
                   
      *     compute ws-temp-map-pos-x = ws-cursor-pos-x + ws-cursor-scr-x                   

           open i-o fd-teleport-data

           move l-cursor-pos to f-teleport-pos

           read fd-teleport-data into l-teleport-data-record
               key is f-teleport-pos
               invalid key 
      *             display "Teleport dest y: " at 2101
      *             accept ws-teleport-dest-y at 2118
      *             display "Teleport dest x: " at 2101
      *             accept ws-teleport-dest-x at 2118
      *             display "Teleport dest map: " at 2101
      *             accept ws-teleport-dest-map at 2120

                   if l-teleport-dest-y not = 0 
                       and l-teleport-dest-x not = 0
                       and l-teleport-dest-map not = spaces then 
                       
                       subtract 10 from l-teleport-dest-y
                       subtract 20 from l-teleport-dest-x

      *                 move ws-temp-map-pos to ws-teleport-pos
                       move l-cursor-pos to l-teleport-pos 
                       write f-teleport-data-record 
                           from l-teleport-data-record
                       end-write
                       display "Teleport placed.              " at 2101
                   end-if 
           

               not invalid key 
                   display "Remove teleport? [Y/N] " at 2101
                   accept ws-temp-input at 2125
                   if ws-temp-input = 'Y' or 'y' then 
                       delete fd-teleport-data
                           invalid key 
                               display "Cannot find teleport to remove."
                                   at 2101
                               end-display 
                           not invalid key 
                               display "Teleport removed              " 
                                   at 2101
                               end-display 
                       end-delete
                   end-if 
           end-read    

           close fd-teleport-data

           exit paragraph.
           
       end program save-tile-effect.
