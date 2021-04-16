      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-10
      *> Last Updated: 2021-04-16git 
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
           01  ws-teleport-effect-id  constant as 01.


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

           01  ws-char-to-draw              pic x.               

       linkage section.

      *> TODO: Copy book... 
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
               05  l-cursor-color             pic 9 value yellow.
               05  l-cursor-draw-color-fg     pic 9 value black.
               05  l-cursor-draw-color-bg     pic 9 value black.
               05  l-cursor-draw-char         pic x value space.
               05  l-cursor-draw-highlight    pic a value 'N'.
                   88  l-cursor-highlight     value 'Y'.
                   88  l-cursor-no-highlight  value 'N'.
               05  l-cursor-draw-blocking     pic a value 'N'.
                   88  l-cursor-blocking      value 'Y'.
                   88  l-cursor-not-block     value 'N'.
               05  l-cursor-draw-blinking     pic a value 'N'.
                   88  l-cursor-blink         value 'Y'.
                   88  l-cursor-not-blink     value 'N'. 
               05  l-cursor-enemy-settings.
                   10  l-cursor-enemy-hp              pic 999 value 10.                       
                   10  l-cursor-enemy-attack-damage   pic 999 value 1.
                   10  l-cursor-enemy-color           pic 9 value red.                                           
                   10  l-cursor-enemy-char            pic x value "&". 
                   10  l-cursor-enemy-movement-ticks  pic 9.                   
               05  l-cursor-draw-effect       pic 99.
               05  l-cursor-type              pic a value 'T'.
                   88  l-cursor-type-tile     value 'T'.
                   88  l-cursor-type-enemy    value 'E'.                     
               78  l-cursor-char              value "+".

 
           01  l-tile-map-table-matrix.
               05  l-tile-map           occurs ws-max-map-height times.
                   10  l-tile-map-data  occurs ws-max-map-width times.
                       15  l-tile-fg                   pic 9.   
                       15  l-tile-bg                   pic 9.
                       15  l-tile-char                 pic x.
                       15  l-tile-highlight            pic a value 'N'.
                           88 l-tile-is-highlight      value 'Y'.
                           88 l-tile-not-highlight     value 'N'.
                       15  l-tile-blocking             pic a value 'N'.
                           88  l-tile-is-blocking      value 'Y'.
                           88  l-tile-not-blocking     value 'N'.  
                       15  l-tile-blinking             pic a value 'N'.
                           88  l-tile-is-blinking      value 'Y'.
                           88  l-tile-not-blinking     value 'N'.
                       15  l-tile-effect-id            pic 99.       


           01  l-enemy-data.
               05  l-enemy       occurs 0 to unbounded times
                                  depending on l-num-enemies.
                   10  l-enemy-hp.
                       15  l-enemy-hp-total    pic 999 value 10.
                       15  l-enemy-hp-current  pic 999 value 10.
                   10  l-enemy-attack-damage   pic 999 value 1.
                   10  l-enemy-pos.
                       15  l-enemy-y           pic 99.
                       15  l-enemy-x           pic 99.
                   10  l-enemy-color           pic 9 value red.                                     
      *>TODO: this isn't configurable once enemy is hit.
                   10  l-enemy-char            pic x value "&". 
                       88  l-enemy-char-alive  value "&".
                       88  l-enemy-char-dead   value "X".
                       88  l-enemy-char-hurt   value "#".
                   10  l-enemy-status              pic 9 value 0.
                       88  l-enemy-status-alive    value 0.
                       88  l-enemy-status-dead     value 1.
                       88  l-enemy-status-attacked value 2.
                       88  l-enemy-status-other    value 3.
                   10  l-enemy-movement-ticks.
                       15  l-enemy-current-ticks   pic 9.
                       15  l-enemy-max-ticks       pic 9 value 3.

           01  l-num-enemies                   pic 99.

           01  l-display-mode                     pic a value 'R'.
               88  l-display-mode-regular         value 'R'.
               88  l-display-mode-effects         value 'E'.

       procedure division using 
               l-cursor l-tile-map-table-matrix l-enemy-data
               l-num-enemies l-display-mode.

       main-procedure.

           perform varying ws-counter-1 
           from 1 by 1 until ws-counter-1 > ws-max-view-height
               perform varying ws-counter-2 
               from 1 by 1 until ws-counter-2 > ws-max-view-width

                   move ws-counter-1 to ws-scr-draw-y
                   move ws-counter-2 to ws-scr-draw-x 

                   compute ws-map-pos-y = l-cursor-pos-y + ws-counter-1 
                   compute ws-map-pos-x = l-cursor-pos-x + ws-counter-2 
                                  
      *>  draw world tile:              
                   if ws-map-pos-y < ws-max-map-height
                       and ws-map-pos-x < ws-max-map-width
                       and ws-map-pos-y > 0 and ws-map-pos-x > 0 
                       then 
                           if l-display-mode-effects then            
                               evaluate l-tile-effect-id(
                                   ws-map-pos-y, ws-map-pos-x)

                                   when 0 
                                       move '.' to ws-char-to-draw
                                   when ws-teleport-effect-id 
                                       move "T" to ws-char-to-draw
                                   when other 
                                       move "U" to ws-char-to-draw 
                                   end-evaluate
                           else 
                               move l-tile-char(
                                   ws-map-pos-y, ws-map-pos-x) 
                                   to ws-char-to-draw
                           end-if 

                           call "draw-tile-character" using
                               ws-scr-draw-pos, 
                               l-tile-map-data(
                                   ws-map-pos-y, ws-map-pos-x) 
                               ws-char-to-draw
                           end-call

                   else *> OOB void space
                       display ":"                   
                           at ws-scr-draw-pos
                           background-color black
                           foreground-color red
                       end-display
                   end-if

                   *> draw cursor
                   if ws-scr-draw-pos = l-cursor-scr-pos then

                       display l-cursor-char 
                           at l-cursor-scr-pos 
                           background-color 
                           l-tile-bg(ws-map-pos-y, ws-map-pos-x) 
                           foreground-color yellow highlight
                       end-display  
                   end-if   

               end-perform
           end-perform.

      *> Draw enemies if they exist and are visible.
           if l-num-enemies > 0 then 
               perform varying ls-enemy-idx from 1 by 1 
               until ls-enemy-idx > l-num-enemies

                   if l-enemy-y(ls-enemy-idx) > l-cursor-pos-y then                    
                       compute ls-enemy-draw-y(ls-enemy-idx) = 
                           l-enemy-y(ls-enemy-idx) - l-cursor-pos-y
                       end-compute 
                    end-if 

                   if l-enemy-x(ls-enemy-idx) > l-cursor-pos-x then                    
                       compute ls-enemy-draw-x(ls-enemy-idx) = 
                           l-enemy-x(ls-enemy-idx) - l-cursor-pos-x
                       end-compute 
                   end-if   

      *>       Draw enemy if in visible view area.
                   if ls-enemy-draw-y(ls-enemy-idx) > 0 and 
                   ls-enemy-draw-y(ls-enemy-idx) <= ws-max-view-height
                   and ls-enemy-draw-x(ls-enemy-idx) > 0 and 
                   ls-enemy-draw-x(ls-enemy-idx) <= ws-max-view-width
                   then 
                       display 
                           l-enemy-char(ls-enemy-idx) 
                           at ls-enemy-draw-pos(ls-enemy-idx)
                           foreground-color l-enemy-color(ls-enemy-idx)
                           background-color l-tile-bg(
                               l-enemy-y(ls-enemy-idx), 
                               l-enemy-x(ls-enemy-idx))
                       end-display
                   end-if                   

               end-perform 
           end-if            
    
           display ws-line-mask at 2101  
           
           if l-cursor-type-tile then 
               perform display-cursor-info-tile
           else 
               perform display-cursor-info-enemy
           end-if

           perform display-tile-info          

           goback.



       display-cursor-info-tile.

           display "Tile to Place: " at 1460 underline highlight           
           display "  Tile character: " at 1553 
           if l-cursor-highlight then 
               display 
                   l-cursor-draw-char at 1571
                   foreground-color l-cursor-draw-color-fg
                   background-color l-cursor-draw-color-bg
                   highlight
               end-display 
           else 
               display 
                   l-cursor-draw-char at 1571
                   foreground-color l-cursor-draw-color-fg
                   background-color l-cursor-draw-color-bg
               end-display 
           end-if 
           display "Foreground color: " at 1653 
               l-cursor-draw-color-fg at 1671
           end-display 
           display "Background color: " at 1753 
               l-cursor-draw-color-bg at 1771
           end-display 
           display "    Is highlight: " at 1853
           if l-cursor-highlight then 
               display "true " at 1871
           else 
               display "false" at 1871
           end-if 
           display "     Is blocking: " at 1953
           if l-cursor-blocking then 
               display "true " at 1971
           else 
               display "false" at 1971
           end-if 
           display "     Is blinking: " at 2053
           if l-cursor-blink then 
               display "true " at 2071
           else 
               display "false" at 2071
           end-if 
           display "  Tile effect id:" at 2153
               l-cursor-draw-effect at 2171               
           end-display 

           if l-cursor-draw-effect > 0 then 
               evaluate l-cursor-draw-effect
                   when ws-teleport-effect-id
                       display "(TELEPORT)" at 2174
                   
                   when other 
                       display "(UNKNOWN)" at 2174
               end-evaluate
           else 
               display "               " at 2174
           end-if 
           exit paragraph. 


       display-cursor-info-enemy.

           display "Enemy to Place:" at 1460 underline highlight           
           display " Enemy character: " at 1553 
           
           display 
               l-cursor-enemy-char at 1571
               foreground-color l-cursor-enemy-color
               background-color black               
           end-display 
           
           display "           Color:            " at 1653 
               l-cursor-enemy-color at 1671
           end-display 
           display "              HP:            " at 1753 
               l-cursor-enemy-hp at 1771
           end-display 
           display "   Attack Damage:            " at 1853           
           display l-cursor-enemy-attack-damage at 1871
           
           display "  Movement ticks:            " at 1953
           display l-cursor-enemy-movement-ticks at 1971
           
           display ws-line-mask at 2053           
           display ws-line-mask at 2153               

           exit paragraph. 




       display-tile-info.

      *> TODO : Recalculating this over and over isn't pretty...

           compute ws-temp-map-pos-y = l-cursor-pos-y + l-cursor-scr-y                   
           compute ws-temp-map-pos-x = l-cursor-pos-x + l-cursor-scr-x                   

           display "Current tile info:" at 2201 underline highlight
           display 
               "YX:" at 2302
               ws-temp-map-pos at 2305
               "FG: " at 2311 
               l-tile-fg(ws-temp-map-pos-y, ws-temp-map-pos-x) at 2314
               "BG: " at 2317
               l-tile-bg(ws-temp-map-pos-y, ws-temp-map-pos-x) at 2320
               "CHAR: " at 2323
               l-tile-char(ws-temp-map-pos-y, ws-temp-map-pos-x) 
                   at 2328
               "HL: " at 2331
               l-tile-highlight(
                   ws-temp-map-pos-y, ws-temp-map-pos-x) 
                   at 2334
               "BLOCK: " at 2337
               l-tile-blocking(ws-temp-map-pos-y, ws-temp-map-pos-x) 
                   at 2343
               "BLINK:" at 2346
               l-tile-blinking(ws-temp-map-pos-y, ws-temp-map-pos-x) 
                   at 2352
               "EFFECT: " at 2355
               l-tile-effect-id(ws-temp-map-pos-y, ws-temp-map-pos-x) 
                   at 2363
           end-display 

           exit paragraph.


       end program draw-dynamic-screen-data.
       
