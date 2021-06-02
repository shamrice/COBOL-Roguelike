      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-10
      *> Last Updated: 2021-06-02
      *> Purpose: Module to draw data passed to the screen.
      *> Tectonics:
      *>     ./build_editor.sh
      *>*****************************************************************

      *> As the editor cursor is more complex than the player in the regular 
      *> game program, this cannot be re-used in the tile-game program.

       identification division.
       program-id. draw-dynamic-screen-data.

       environment division.

       data division.

       working-storage section.

       copy "shared/copybooks/ws-constants.cpy".

       local-storage section.
       
       01  ws-counter-1                 pic 999 comp.
       01  ws-counter-2                 pic 999 comp.
       01  ls-enemy-idx                 pic 99 comp.
           
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
                                    depending on l-cur-num-enemies.
           05  ls-enemy-draw-y          pic 99.
           05  ls-enemy-draw-x          pic 99.

       01  ws-char-to-draw              pic x.  

       01  ws-tile-info-display.
           05  ws-disp-tile-fg             pic 9.
           05  ws-disp-tile-bg             pic 9.
           05  ws-disp-tile-char           pic x.
           05  ws-disp-tile-highlight      pic a.
           05  ws-disp-tile-blocking       pic a.
           05  ws-disp-tile-blinking       pic a.
           05  ws-disp-tile-effect-id      pic 99.       
           05  ws-disp-tile-visibility     pic 999.             

       linkage section.

       copy "editor/copybooks/l-cursor.cpy".

       copy "shared/copybooks/l-tile-map-table-matrix.cpy".

       copy "shared/copybooks/l-enemy-data.cpy".

           01  l-display-mode                     pic a value 'R'.
               88  l-display-mode-regular         value 'R'.
               88  l-display-mode-effects         value 'E'.

       procedure division using 
               l-cursor l-tile-map-table-matrix l-enemy-data
               l-display-mode.

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
                                   when ws-conveyor-right-effect-id
                                       move ">" to ws-char-to-draw
                                   when ws-conveyor-down-effect-id
                                       move "v" to ws-char-to-draw
                                   when ws-conveyor-left-effect-id
                                       move "<" to ws-char-to-draw
                                   when ws-conveyor-up-effect-id
                                       move "^" to ws-char-to-draw   
                                   when ws-conveyor-reverse-effect-id
                                       move "R" to ws-char-to-draw                                                                                                                  
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
           if l-cur-num-enemies > 0 then 
               perform varying ls-enemy-idx from 1 by 1 
               until ls-enemy-idx > l-cur-num-enemies

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

           display "Tile to Place: " at 1260 underline highlight  

           display ws-line-mask at 1353          

           display "  Tile character: " at 1353 
           if l-cursor-highlight then 
               display 
                   l-cursor-draw-char at 1371
                   foreground-color l-cursor-draw-color-fg
                   background-color l-cursor-draw-color-bg
                   highlight
               end-display 
           else 
               display 
                   l-cursor-draw-char at 1371
                   foreground-color l-cursor-draw-color-fg
                   background-color l-cursor-draw-color-bg
               end-display 
           end-if 
           display "Foreground color: " at 1453 
               l-cursor-draw-color-fg at 1471
           end-display 
           display "Background color: " at 1553 
               l-cursor-draw-color-bg at 1571
           end-display 
           display "    Is highlight: " at 1653
           if l-cursor-highlight then 
               display "true " at 1671
           else 
               display "false" at 1671
           end-if 
           display "     Is blocking: " at 1753
           if l-cursor-blocking then 
               display "true " at 1771
           else 
               display "false" at 1771
           end-if 
           display "     Is blinking: " at 1853
           if l-cursor-blink then 
               display "true " at 1871
           else 
               display "false" at 1871
           end-if 
           display "  Tile effect id:" at 1953
               l-cursor-draw-effect at 1971               
           end-display 
           

           *>TODO : there is code duplication here with tile info with 
           *>       just a difference of 10+ rows in display location. 
           evaluate l-cursor-draw-effect
               when zero 
                   display "(NONE)          " at 1974
               
               when ws-teleport-effect-id
                   display "(TELEPORT)      " at 1974

               when ws-conveyor-right-effect-id
                   display "(CONVEYOR RIGHT)" at 1974 

               when ws-conveyor-down-effect-id
                   display "(CONVEYOR DOWN) " at 1974 

               when ws-conveyor-left-effect-id
                   display "(CONVEYOR LEFT) " at 1974 

               when ws-conveyor-up-effect-id
                   display "(CONVEYOR UP)   " at 1974                                                          

               when ws-conveyor-reverse-effect-id
                   display "(CON REV SWITCH)" at 1974

               when other 
                   display "(UNKNOWN)       " at 1974
           end-evaluate           
           
           display "      Visibility: " at 2053
               l-cursor-draw-visibility at 2071
           end-display 

           display space at 1473 background-color l-cursor-draw-color-fg
           display space at 1573 background-color l-cursor-draw-color-bg

           exit paragraph. 


       display-cursor-info-enemy.

           display "Enemy to Place:" at 1260 underline highlight           

           display "      Enemy name:            " at 1353 
           display l-cursor-enemy-name at 1371

           display " Enemy character:            " at 1453            
           display 
               l-cursor-enemy-char at 1471
               foreground-color l-cursor-enemy-color
               background-color black               
           end-display 
           
           display "           Color:            " at 1553 
               l-cursor-enemy-color at 1571
           end-display 
           display "              HP:            " at 1653 
               l-cursor-enemy-hp at 1671
           end-display 
           display "   Attack Damage:            " at 1753
           display l-cursor-enemy-attack-damage at 1771
           
           display "  Movement ticks:            " at 1853
           display l-cursor-enemy-movement-ticks at 1871
           
           display "       Exp Worth:            " at 1953
           display l-cursor-enemy-exp-worth at 1971

           display ws-line-mask at 2053

           exit paragraph. 




       display-tile-info.

           compute ws-temp-map-pos-y = l-cursor-pos-y + l-cursor-scr-y                   
           compute ws-temp-map-pos-x = l-cursor-pos-x + l-cursor-scr-x                   

           move l-tile-fg(ws-temp-map-pos-y, ws-temp-map-pos-x)
               to ws-disp-tile-fg 
           
           move l-tile-bg(ws-temp-map-pos-y, ws-temp-map-pos-x)
               to ws-disp-tile-bg 
           
           move l-tile-char(ws-temp-map-pos-y, ws-temp-map-pos-x)
               to ws-disp-tile-char

           move l-tile-highlight(ws-temp-map-pos-y, ws-temp-map-pos-x)
               to ws-disp-tile-highlight

           move l-tile-blocking(ws-temp-map-pos-y, ws-temp-map-pos-x)
               to ws-disp-tile-blocking

           move l-tile-blinking(ws-temp-map-pos-y, ws-temp-map-pos-x)
               to ws-disp-tile-blinking

           move l-tile-effect-id(ws-temp-map-pos-y, ws-temp-map-pos-x)
               to ws-disp-tile-effect-id

           move l-tile-visibility(ws-temp-map-pos-y, ws-temp-map-pos-x)
               to ws-disp-tile-visibility

           display "Current Tile Info:" at 0160 underline highlight
           display 
               "             Y/X:      " at 0253
               ws-temp-map-pos-y at 0271
               "/" at 0273
               ws-temp-map-pos-x at 0274
               "Foreground color:      " at 0353 
               ws-disp-tile-fg at 0371
               "Background color:      " at 0453
               ws-disp-tile-bg at 0471               
               "  Tile Character:      " at 0553
               "       Highlight:      " at 0653
               ws-disp-tile-highlight at 0671
               "        Blocking:      " at 0753
               ws-disp-tile-blocking at 0771
               "        Blinking:      " at 0853
               ws-disp-tile-blinking at 0871
               "  Tile Effect Id:      " at 0953
               ws-disp-tile-effect-id at 0971
               "      Visibility:      " at 1053
               ws-disp-tile-visibility at 1071
           end-display 

           if ws-disp-tile-highlight = 'Y' then 
               display 
                   ws-disp-tile-char at 0571
                   foreground-color ws-disp-tile-fg
                   background-color ws-disp-tile-bg
                   highlight
               end-display 
           else 
               display 
                   ws-disp-tile-char at 0571
                   foreground-color ws-disp-tile-fg
                   background-color ws-disp-tile-bg                   
               end-display 
           end-if 


           evaluate ws-disp-tile-effect-id
               when zero 
                   display "(NONE)          " at 0974
               
               when ws-teleport-effect-id
                   display "(TELEPORT)      " at 0974

               when ws-conveyor-right-effect-id
                   display "(CONVEYOR RIGHT)" at 0974 

               when ws-conveyor-down-effect-id
                   display "(CONVEYOR DOWN) " at 0974 

               when ws-conveyor-left-effect-id
                   display "(CONVEYOR LEFT) " at 0974 

               when ws-conveyor-up-effect-id
                   display "(CONVEYOR UP)   " at 0974                                                          

               when ws-conveyor-reverse-effect-id
                   display "(CON REV SWITCH)" at 0974

               when other 
                   display "(UNKNOWN)       " at 0974
           end-evaluate  

           display space at 0373 background-color ws-disp-tile-fg
           display space at 0473 background-color ws-disp-tile-bg

           exit paragraph.


       end program draw-dynamic-screen-data.
       
