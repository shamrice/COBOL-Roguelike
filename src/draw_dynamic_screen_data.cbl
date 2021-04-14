      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-10
      *> Last Updated: 2021-04-14
      *> Purpose: Module to draw data passed to the screen.
      *> Tectonics:
      *>     ./build_editor.sh
      *>*****************************************************************

      *> As the editor cursor is more complex than the player in the regular 
      *> game program, this cannot be re-used in the tile-game program.
      *> A similar sub-program will need to be created for that implementation.

       identification division.
       program-id. draw-dynamic-screen-data.

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
           01  ws-teleport-effect-id constant as 01.


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

           01  ws-temp-map-pos.
               05  ws-temp-map-pos-y        pic S99 value 01.
               05  ws-temp-map-pos-x        pic S99 value 01.

           01  ws-line-mask                 pic x(80) value spaces. 

           01  ls-enemy-draw-pos    occurs 0 to ws-max-num-enemies times
                                    depending on l-num-enemies.
               05  ls-enemy-draw-y          pic 99.
               05  ls-enemy-draw-x          pic 99.

       linkage section.

      *> TODO: Copy book... also linkage section should not be "ws"
           01  ws-cursor.
               05  ws-cursor-pos.
                   10  ws-cursor-pos-y         pic S99.
                   10  ws-cursor-pos-x         pic S99.
               05  ws-cursor-pos-delta.               
                   10  ws-cursor-pos-delta-y   pic S99. 
                   10  ws-cursor-pos-delta-x   pic S99.
               05  ws-cursor-scr-pos.  
                   10  ws-cursor-scr-y         pic 99 value 10.
                   10  ws-cursor-scr-x         pic 99 value 20.                      
               05  ws-cursor-color             pic 9 value yellow.
               05  ws-cursor-draw-color-fg     pic 9 value black.
               05  ws-cursor-draw-color-bg     pic 9 value black.
               05  ws-cursor-draw-char         pic x value space.
               05  ws-cursor-draw-highlight    pic a value 'N'.
                   88  ws-cursor-highlight     value 'Y'.
                   88  ws-cursor-no-highlight  value 'N'.
               05  ws-cursor-draw-blocking     pic a value 'N'.
                   88  ws-cursor-blocking      value 'Y'.
                   88  ws-cursor-not-block     value 'N'.
               05  ws-cursor-draw-blinking     pic a value 'N'.
                   88  ws-cursor-blink         value 'Y'.
                   88  ws-cursor-not-blink     value 'N'. 
               05  ws-cursor-draw-effect       pic 99.
               78  ws-cursor-char              value "+".

 
           01  ws-tile-map-table-matrix.
               05  ws-tile-map           occurs ws-max-map-height times.
                   10  ws-tile-map-data  occurs ws-max-map-width times.
                       15  ws-tile-fg                   pic 9.   
                       15  ws-tile-bg                   pic 9.
                       15  ws-tile-char                 pic x.
                       15  ws-tile-highlight            pic a value 'N'.
                           88 ws-tile-is-highlight      value 'Y'.
                           88 ws-tile-not-highlight     value 'N'.
                       15  ws-tile-blocking             pic a value 'N'.
                           88  ws-tile-is-blocking      value 'Y'.
                           88  ws-tile-not-blocking     value 'N'.  
                       15  ws-tile-blinking             pic a value 'N'.
                           88  ws-tile-is-blinking      value 'Y'.
                           88  ws-tile-not-blinking     value 'N'.
                       15  ws-tile-effect-id            pic 99.       


           01  ws-enemy-data.
               05  ws-enemy       occurs 0 to unbounded times
                                  depending on l-num-enemies.
                   10  ws-enemy-hp.
                       15  ws-enemy-hp-total    pic 999 value 10.
                       15  ws-enemy-hp-current  pic 999 value 10.
                   10  ws-enemy-attack-damage   pic 999 value 1.
                   10  ws-enemy-pos.
                       15  ws-enemy-y           pic 99.
                       15  ws-enemy-x           pic 99.
                   10  ws-enemy-color           pic 9 value red.                                     
      *>TODO: this isn't configurable.
                   10  ws-enemy-char            pic x value "&". 
                       88  ws-enemy-char-alive  value "&".
                       88  ws-enemy-char-dead   value "X".
                       88  ws-enemy-char-hurt   value "#".
                   10  ws-enemy-status              pic 9 value 0.
                       88  ws-enemy-status-alive    value 0.
                       88  ws-enemy-status-dead     value 1.
                       88  ws-enemy-status-attacked value 2.
                       88  ws-enemy-status-other    value 3.
                   10  ws-enemy-movement-ticks.
                       15  ws-enemy-current-ticks   pic 9.
                       15  ws-enemy-max-ticks       pic 9 value 3.

           01  l-num-enemies                   pic 99.

       procedure division using 
           ws-cursor ws-tile-map-table-matrix ws-enemy-data
           l-num-enemies.

       main-procedure.


      *> If there's an enemies on the visible section of the screen, 
      *> Find their draw screen positions to be placed during the tile
      *> loop below.
           if l-num-enemies > 0 then 
               perform varying ls-enemy-idx from 1 by 1 
               until ls-enemy-idx > l-num-enemies

                   if ws-enemy-y(ls-enemy-idx) > ws-cursor-pos-y then                    
                       compute ls-enemy-draw-y(ls-enemy-idx) = 
                           ws-enemy-y(ls-enemy-idx) - ws-cursor-pos-y
                       end-compute 
                    end-if 

                   if ws-enemy-x(ls-enemy-idx) > ws-cursor-pos-x then                    
                       compute ls-enemy-draw-x(ls-enemy-idx) = 
                           ws-enemy-x(ls-enemy-idx) - ws-cursor-pos-x
                       end-compute 
                    end-if                    

               end-perform 
           end-if 


           perform varying ws-counter-1 
           from 1 by 1 until ws-counter-1 > ws-max-view-height
               perform varying ws-counter-2 
               from 1 by 1 until ws-counter-2 > ws-max-view-width

                   move ws-counter-1 to ws-scr-draw-y
                   move ws-counter-2 to ws-scr-draw-x 

                   compute ws-map-pos-y = ws-cursor-pos-y + ws-counter-1 
                   compute ws-map-pos-x = ws-cursor-pos-x + ws-counter-2 
                   
               
      *>  draw world tile:
              
                   if ws-map-pos-y < ws-max-map-height
                       and ws-map-pos-x < ws-max-map-width
                       and ws-map-pos-y > 0 and ws-map-pos-x > 0 
                       then 
                           call "draw-tile-character" using
                               ws-scr-draw-pos, 
                               ws-tile-map-data(
                                   ws-map-pos-y, ws-map-pos-x) 
                           end-call

                   else *> OOB void space
                       display ":"                   
                           at ws-scr-draw-pos
                           background-color black
                           foreground-color red
                       end-display
                   end-if

                   *> draw cursor
                   if ws-scr-draw-pos = ws-cursor-scr-pos then

                       display ws-cursor-char 
                           at ws-cursor-scr-pos 
                           background-color 
                           ws-tile-bg(ws-map-pos-y, ws-map-pos-x) 
                           foreground-color yellow highlight
                       end-display  
                   end-if   

      *> Draw enemies
                   perform varying ls-enemy-idx from 1 by 1 
                   until ls-enemy-idx > l-num-enemies
                       if ws-scr-draw-pos = 
                           ls-enemy-draw-pos(ls-enemy-idx) then 
                           display 
                               ws-enemy-char(ls-enemy-idx) 
                               at ls-enemy-draw-pos(ls-enemy-idx)
                               foreground-color
                                   ws-enemy-color(ls-enemy-idx)
                               background-color
                                  ws-tile-bg(ws-map-pos-y, ws-map-pos-x)
                           end-display
                       end-if 
                   end-perform

               end-perform
           end-perform.
    
           display ws-line-mask at 2101  

           perform display-cursor-info
           perform display-tile-info


           goback.



       display-cursor-info.

           display "Tile to Place:" at 1360 underline highlight           
           display "  Tile character: " at 1453 
           if ws-cursor-highlight then 
               display 
                   ws-cursor-draw-char at 1471
                   foreground-color ws-cursor-draw-color-fg
                   background-color ws-cursor-draw-color-bg
                   highlight
               end-display 
           else 
               display 
                   ws-cursor-draw-char at 1471
                   foreground-color ws-cursor-draw-color-fg
                   background-color ws-cursor-draw-color-bg
               end-display 
           end-if 
           display "Foreground color: " at 1553 
               ws-cursor-draw-color-fg at 1571
           end-display 
           display "Background color: " at 1653 
               ws-cursor-draw-color-bg at 1671
           end-display 
           display "    Is highlight: " at 1753
           if ws-cursor-highlight then 
               display "true " at 1771
           else 
               display "false" at 1771
           end-if 
           display "     Is blocking: " at 1853
           if ws-cursor-blocking then 
               display "true " at 1871
           else 
               display "false" at 1871
           end-if 
           display "     Is blinking: " at 1953
           if ws-cursor-blink then 
               display "true " at 1971
           else 
               display "false" at 1971
           end-if 
           display "  Tile effect id:" at 2053
               ws-cursor-draw-effect at 2071               
           end-display 

           if ws-cursor-draw-effect > 0 then 
               evaluate ws-cursor-draw-effect
                   when ws-teleport-effect-id
                       display "(TELEPORT)" at 2074
                   
                   when other 
                       display "(UNKNOWN)" at 2074
               end-evaluate

           exit paragraph. 



       display-tile-info.

      *> TODO : Recalculating this over and over isn't pretty...

           compute ws-temp-map-pos-y = ws-cursor-pos-y + ws-cursor-scr-y                   
           compute ws-temp-map-pos-x = ws-cursor-pos-x + ws-cursor-scr-x                   

           display "Current tile info:" at 2201 underline highlight
           display 
               "YX:" at 2302
               ws-temp-map-pos at 2305
               "FG: " at 2311 
               ws-tile-fg(ws-temp-map-pos-y, ws-temp-map-pos-x) at 2314
               "BG: " at 2317
               ws-tile-bg(ws-temp-map-pos-y, ws-temp-map-pos-x) at 2320
               "CHAR: " at 2323
               ws-tile-char(ws-temp-map-pos-y, ws-temp-map-pos-x) 
                   at 2328
               "HL: " at 2331
               ws-tile-highlight(
                   ws-temp-map-pos-y, ws-temp-map-pos-x) 
                   at 2334
               "BLOCK: " at 2337
               ws-tile-blocking(ws-temp-map-pos-y, ws-temp-map-pos-x) 
                   at 2343
               "BLINK:" at 2346
               ws-tile-blinking(ws-temp-map-pos-y, ws-temp-map-pos-x) 
                   at 2352
               "EFFECT: " at 2355
               ws-tile-effect-id(ws-temp-map-pos-y, ws-temp-map-pos-x) 
                   at 2363
           end-display 

           exit paragraph.


       end program draw-dynamic-screen-data.
       