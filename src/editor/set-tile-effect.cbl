      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-12
      *> Last Updated: 2021-05-01
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

           01  ws-temp-input               pic a.

           01  ws-counter-1                pic 999.

           78  ws-max-num-teleports        value 999.

      *> Tile effect ids           
           01  ws-teleport-effect-id constant as 01.

       local-storage section.
           01  ls-teleport-found           pic a value 'N'.
               88  ls-teleport-is-found    value 'Y'.
               88  ls-teleport-not-found   value 'N'.

           01  ls-found-idx                pic 999.

       linkage section.

           01  l-placement-pos.
               05  l-placement-pos-y         pic S99.
               05  l-placement-pos-x         pic S99.

           01  l-cursor.
               05  l-cursor-pos.
                   10  l-cursor-pos-y         pic S99.
                   10  l-cursor-pos-x         pic S99.
               05  l-cursor-pos-delta.               
                   10  l-cursor-pos-delta-y   pic S99. 
                   10  l-cursor-pos-delta-x   pic S99.
               05  l-cursor-scr-pos.  
                   10  l-cursor-scr-y         pic 99 value 10.
                   10  l-cursor-scr-x         pic 99 value 20.                      
               05  l-cursor-color             pic 9.
               05  l-cursor-draw-color-fg     pic 9.
               05  l-cursor-draw-color-bg     pic 9.
               05  l-cursor-draw-char         pic x value space.
               05  l-cursor-draw-highlight    pic a.
                   88  l-cursor-highlight     value 'Y'.
                   88  l-cursor-no-highlight  value 'N'.
               05  l-cursor-draw-blocking     pic a.
                   88  l-cursor-blocking      value 'Y'.
                   88  l-cursor-not-block     value 'N'.
               05  l-cursor-draw-blinking     pic a.
                   88  l-cursor-blink         value 'Y'.
                   88  l-cursor-not-blink     value 'N'. 
               05  l-cursor-enemy-settings.
                   10  l-cursor-enemy-name            pic x(16).
                   10  l-cursor-enemy-hp              pic 999.
                   10  l-cursor-enemy-attack-damage   pic 999.
                   10  l-cursor-enemy-color           pic 9.   
                   10  l-cursor-enemy-char            pic x.
                   10  l-cursor-enemy-movement-ticks  pic 999.    
                   10  l-cursor-enemy-exp-worth       pic 9(4). 
               05  l-cursor-teleport-settings.
                   10  l-cursor-tel-dest-y            pic 99.
                   10  l-cursor-tel-dest-x            pic 99.
                   10  l-cursor-tel-dest-map          pic x(15).                       
               05  l-cursor-draw-effect       pic 99.
               05  l-cursor-type              pic a.
                   88  l-cursor-type-tile     value 'T'.
                   88  l-cursor-type-enemy    value 'E'.                     
               78  l-cursor-char              value "+".


           01  l-teleport-data.
               05  l-cur-num-teleports        pic 999.
               05  l-teleport-data-record     occurs 0 
                                               to ws-max-num-teleports
                                      depending on l-cur-num-teleports.
                   10  l-teleport-pos.
                       15  l-teleport-y        pic S99.
                       15  l-teleport-x        pic S99.
                   10  l-teleport-dest-pos.
                       15  l-teleport-dest-y   pic S99.
                       15  l-teleport-dest-x   pic S99.
                   10  l-teleport-dest-map     pic x(15).                      



           01  l-cur-tile-effect-id                pic 99.

       procedure division using 
           l-placement-pos l-cur-tile-effect-id 
           l-cursor l-teleport-data.
       
       main-procedure.

           evaluate l-cursor-draw-effect

               when ws-teleport-effect-id
                   perform set-teleport

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
           
       end program set-tile-effect.
