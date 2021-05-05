      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-03-14
      *> Last Updated: 2021-05-05
      *> Purpose: Map editor for the game
      *> Tectonics:
      *>     ./build_editor.sh
      *>*****************************************************************
       identification division.
       program-id. cobol-roguelike-editor.

       environment division.

       configuration section.
           special-names.
               crt status is ws-crt-status.
               cursor is ws-mouse-position.

       input-output section.

       file-control.
               select optional fd-tile-data 
               assign to dynamic ws-map-dat-file 
               organization is record sequential.         
          
               select optional fd-enemy-data
               assign to dynamic ws-map-enemy-file
               organization is record sequential.

               select optional fd-teleport-data
               assign to dynamic ws-map-tel-file
               organization is record sequential.

       data division.

       file section.

      * TODO : copy book for shared file stuff      

           fd  fd-tile-data.
           01  f-tile-data-record.
               05  f-tile-fg               pic 9.   
               05  f-tile-bg               pic 9.
               05  f-tile-char             pic x.
               05  f-tile-highlight        pic a.
               05  f-tile-blocking         pic a.
               05  f-tile-blinking         pic a.
               05  f-tile-effect-id        pic 99.

           fd  fd-enemy-data.           
           01  f-enemy.
               05  f-enemy-name                 pic x(16).
               05  f-enemy-hp.
                   10  f-enemy-hp-total         pic 999.
                   10  f-enemy-hp-current       pic 999.
               05  f-enemy-attack-damage        pic 999.
               05  f-enemy-pos.
                   10  f-enemy-y                pic 99.
                   10  f-enemy-x                pic 99.
               05  f-enemy-color                pic 9. 
               05  f-enemy-char                 pic x.
               05  f-enemy-status               pic 9.
               05  f-enemy-movement-ticks.
                   10  f-enemy-current-ticks    pic 999.
                   10  f-enemy-max-ticks        pic 999.
               05  f-enemy-exp-worth            pic 9(4).

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

           01  ws-mouse-flags              pic 9(4).

           01  ws-crt-status.
               05  ws-crt-status-key-1     pic 99.
               05  ws-crt-status-key-2     pic 99.

           01  ws-mouse-position.
               05  ws-mouse-row            pic 99.
               05  ws-mouse-col            pic 99.

           01  ws-mouse-click-status       pic a value 'N'.
               88  ws-mouse-clicked        value 'Y'.
               88  ws-mouse-not-clicked    value 'N'.

           01  ws-temp-time                pic 9(9).


           01  ws-map-files.  
               05  ws-map-name             pic x(15) value "NEWMAP".
               05  ws-map-name-temp        pic x(15) value "NEWMAP".
               05  ws-map-dat-file         pic x(15).               
               05  ws-map-tel-file         pic x(15).
               05  ws-map-enemy-file       pic x(15).
                          
           78  ws-data-file-ext            value ".DAT".
           78  ws-teleport-file-ext        value ".TEL".
           78  ws-enemy-file-ext           value ".BGS".


      *> Color constants:    
           01  black   constant as 0.
           01  blue    constant as 1.
           01  green   constant as 2.
           01  cyan    constant as 3.
           01  red     constant as 4.
           01  magenta constant as 5.
           01  yellow  constant as 6.  
           01  white   constant as 7.

           78  ws-max-map-height              value 25.
           78  ws-max-map-width               value 80.
           78  ws-max-num-enemies             value 99.
           78  ws-max-num-teleports           value 999.

           01  ws-line-mask                   pic x(50) value spaces.

           01  ws-cursor.
               05  ws-cursor-pos.
                   10  ws-cursor-pos-y        pic S99.
                   10  ws-cursor-pos-x        pic S99.
               05  ws-cursor-pos-delta.               
                   10  ws-cursor-pos-delta-y  pic S99. 
                   10  ws-cursor-pos-delta-x  pic S99.
               05  ws-cursor-scr-pos.  
                   10  ws-cursor-scr-y         pic 99 value 10.
                   10  ws-cursor-scr-x         pic 99 value 20.                      
               05  ws-cursor-color            pic 9 value yellow.
               05  ws-cursor-draw-color-fg    pic 9 value black.
               05  ws-cursor-draw-color-bg    pic 9 value black.
               05  ws-cursor-draw-char        pic x value space.
               05  ws-cursor-draw-highlight   pic a value 'N'.
                   88  ws-cursor-highlight    value 'Y'.
                   88  ws-cursor-no-highlight value 'N'.
               05  ws-cursor-draw-blocking    pic a value 'N'.
                   88  ws-cursor-blocking     value 'Y'.
                   88  ws-cursor-not-block    value 'N'.
               05  ws-cursor-draw-blinking    pic a value 'N'.
                   88  ws-cursor-blink        value 'Y'.
                   88  ws-cursor-not-blink    value 'N'.
               05  ws-cursor-enemy-settings.
                   10  ws-cursor-enemy-name    pic x(16) value 'NONAME'.
                   10  ws-cursor-enemy-hp              pic 999 value 10.                       
                   10  ws-cursor-enemy-attack-damage   pic 999 value 1.
                   10  ws-cursor-enemy-color           pic 9 value red.                                           
                   10  ws-cursor-enemy-char            pic x value "&". 
                   10  ws-cursor-enemy-movement-ticks  pic 999 value 3.
                   10  ws-cursor-enemy-exp-worth       pic 9(4) value 1.
               05  ws-cursor-teleport-settings.
                   10  ws-cursor-tel-dest-y            pic 99.
                   10  ws-cursor-tel-dest-x            pic 99.
                   10  ws-cursor-tel-dest-map          pic x(15).    
               05  ws-cursor-draw-effect               pic 99.                   
               05  ws-cursor-type                      pic a value 'T'.
                   88  ws-cursor-type-tile             value 'T'.
                   88  ws-cursor-type-enemy            value 'E'.                                                      
               78  ws-cursor-char             value "+".


           01  ws-kb-input                    pic x.

           01  ws-is-quit                     pic a value 'N'.
               88  ws-quit                    value 'Y'.
               88  ws-not-quit                value 'N'.

           01  ws-display-mode                     pic a value 'R'.
               88  ws-display-mode-regular         value 'R'.
               88  ws-display-mode-effects         value 'E'.
                     

           01  ws-enemy-data.
               05  ws-cur-num-enemies           pic 99 value 0.
               05  ws-enemy       occurs 0 to ws-max-num-enemies times
                                  depending on ws-cur-num-enemies.
                   10  ws-enemy-name           pic x(16) value 'NONAME'.
                   10  ws-enemy-hp.
                       15  ws-enemy-hp-total    pic 999 value 10.
                       15  ws-enemy-hp-current  pic 999 value 10.
                   10  ws-enemy-attack-damage   pic 999 value 1.
                   10  ws-enemy-pos.
                       15  ws-enemy-y           pic 99.
                       15  ws-enemy-x           pic 99.
                   10  ws-enemy-color           pic 9 value red.                                     
                   10  ws-enemy-char            pic x.
                   10  ws-enemy-status              pic 9 value 0.
                       88  ws-enemy-status-alive    value 0.
                       88  ws-enemy-status-dead     value 1.
                       88  ws-enemy-status-attacked value 2.
                       88  ws-enemy-status-other    value 3.
                   10  ws-enemy-movement-ticks.
                       15  ws-enemy-current-ticks   pic 999.
                       15  ws-enemy-max-ticks       pic 999 value 3.
                   10  ws-enemy-exp-worth           pic 9(4) value 1.


           01  ws-tile-map-table-matrix.
               05  ws-tile-map           occurs ws-max-map-height times.
                   10  ws-tile-map-data   occurs ws-max-map-width times.
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


           01  ws-teleport-data.
               05  ws-cur-num-teleports        pic 999.
               05  ws-teleport-data-record     occurs 0 
                                               to ws-max-num-teleports
                                      depending on ws-cur-num-teleports.
                   10  ws-teleport-pos.
                       15  ws-teleport-y        pic S99.
                       15  ws-teleport-x        pic S99.
                   10  ws-teleport-dest-pos.
                       15  ws-teleport-dest-y   pic S99.
                       15  ws-teleport-dest-x   pic S99.
                   10  ws-teleport-dest-map     pic x(15).
       
           

           01  ws-temp-input                pic x.

           01  ws-scr-refresh-req           pic a value 'Y'.
               88  ws-scr-refresh           value 'Y'.
               88  ws-scr-no-refresh        value 'N'.

           01  ws-counter-1                 pic 999.
           01  ws-counter-2                 pic 999.

           01  ws-temp-map-pos.
               05  ws-temp-map-pos-y        pic S99 value 01.
               05  ws-temp-map-pos-x        pic S99 value 01.

           01  ws-filler                    pic 9(9).

           01  ws-enemy-placed-found        pic a value 'N'.
               88  ws-enemy-found           value 'Y'.
               88  ws-enemy-not-found       value 'N'.
           01  ws-enemy-found-idx           pic 99.

           01  ws-replace-enemy             pic a.

           01  ws-load-return-code          pic 9.

       procedure division.
       
       init-setup. 
           set environment "COB_SCREEN_EXCEPTIONS" to 'Y'.
           set environment "COB_SCREEN_ESC" to 'Y'.
           set environment "COB_SCREEN_TAB" to 'Y'.
           set environment "COB_TIMEOUT_SCALE" to '3'.       
      
      *> make mouse active
           compute ws-mouse-flags = COB-AUTO-MOUSE-HANDLING
                   + COB-ALLOW-LEFT-DOWN 
      *             + COB-ALLOW-MIDDLE-DOWN   
      *             + COB-ALLOW-RIGHT-DOWN
                   + COB-ALLOW-LEFT-UP 
      *             + COB-ALLOW-MIDDLE-UP     
      *             + COB-ALLOW-RIGHT-UP
      *             + COB-ALLOW-LEFT-DOUBLE + COB-ALLOW-MIDDLE-DOUBLE 
      *             + COB-ALLOW-RIGHT-DOUBLE
                   + COB-ALLOW-MOUSE-MOVE
           set environment "COB_MOUSE_FLAGS" to ws-mouse-flags

           move '1010' to ws-cursor-pos           
           display space blank screen 

           accept ws-temp-time from time 
           move function random(ws-temp-time) to ws-filler

           perform generate-init-world-data.


       set-file-names.
      *> Set file names based on map name
           move function concatenate(
               function trim(ws-map-name), ws-data-file-ext)
               to ws-map-dat-file

           move function concatenate(
               function trim(ws-map-name), ws-teleport-file-ext)
               to ws-map-tel-file            

           move function concatenate(
               function trim(ws-map-name), ws-enemy-file-ext)
               to ws-map-enemy-file       
           
           exit paragraph.
         


       main-procedure.

           perform display-commands       

           perform until ws-quit         
               perform draw-screen               
               perform get-input
               perform move-cursor

           end-perform
      
           goback.


       draw-screen.
      *> only redraw if needed.
           if ws-scr-no-refresh then 
               exit paragraph 
           end-if 
      
           call "draw-dynamic-screen-data" 
               using ws-cursor ws-tile-map-table-matrix ws-enemy-data
               ws-display-mode
           end-call 
           set ws-scr-no-refresh to true

           exit paragraph.


       get-input.
                              
           accept ws-kb-input at 2601 with auto-skip no-echo upper
                     

      *> Check special keys being pressed.
           evaluate ws-crt-status 

               when COB-SCR-KEY-DOWN 
                   add 1 to ws-cursor-pos-delta-y

               when COB-SCR-KEY-UP
                   subtract 1 from ws-cursor-pos-delta-y

               when COB-SCR-KEY-LEFT
                   subtract 1 from ws-cursor-pos-delta-x

               when COB-SCR-KEY-RIGHT
                   add 1 to ws-cursor-pos-delta-x

               when COB-SCR-ESC
                   display "QUITING" at 0917 
                   set ws-quit to true 

               when COB-SCR-F6 
                   if ws-display-mode-effects then 
                       set ws-display-mode-regular to true 
                   else 
                       set ws-display-mode-effects to true 
                   end-if 

               when COB-SCR-TAB                    
                   if ws-cursor-type-tile then 
                       set ws-cursor-type-enemy to true 
                   else 
                       set ws-cursor-type-tile to true 
                   end-if


      *> Mouse click status
               when COB-SCR-LEFT-PRESSED 
                   set ws-mouse-clicked to true 
      *             display "CLICKED" at 3505

               when COB-SCR-LEFT-RELEASED
                   set ws-mouse-not-clicked to true 
      *             display "NOT CL" at 3505

    
      *         when other 
      *             display "KB INPUT" at 1750 ws-crt-status at 1765

           end-evaluate

      *     display ws-mouse-click-status at 3601
      *     display ws-crt-status at 3611

      *> Check mouse input           
           if ws-mouse-position not = zeros                
               and ws-mouse-row <= 20 
               and ws-mouse-clicked then                      
               perform place-item-at-mouse-pos      
           end-if 
 
      *> Non-special key input handling.
           evaluate true

               when ws-kb-input = 'Q'
                   display "QUITING" at 0917
                   set ws-quit to true              
      

               when ws-kb-input = '0' 
                   move zero to ws-cursor-draw-color-fg

               when ws-kb-input = 'B'
                   perform toggle-blocking-mode

               when ws-kb-input = 'C'
                   perform set-tile-char
               
               when ws-kb-input = 'D'
                   perform set-enemy-settings

               when ws-kb-input = 'E'
                   perform set-effect-id

               when ws-kb-input = 'F'
                   perform set-foreground-color

               when ws-kb-input = 'G'
                   perform set-background-color

               when ws-kb-input = 'H'
                   perform toggle-fg-highlight
               
               when ws-kb-input = 'K'
                   perform toggle-blink

               when ws-kb-input = 'L'
                   perform load-map-data
               
               when ws-kb-input = 'O' 
                   perform write-world-data                   

               when ws-kb-input = space
                   if ws-crt-status not = COB-SCR-TIME-OUT
                       and ws-cursor-pos-delta = zeros 
                       and ws-crt-status = zeros      
                       then       
                           perform place-item-at-cursor-pos
                   end-if 
                  
               when other   
                   display "KB INPUT: " at 2601 ws-kb-input at 2610

           end-evaluate

           exit paragraph.

       move-cursor.
           
           if ws-cursor-pos-delta <> 0 then 

      *> only move cursor if tile is not blocking and inside map.
               move ws-cursor-pos to ws-temp-map-pos
               add ws-cursor-scr-y to ws-temp-map-pos-y
               add ws-cursor-scr-x to ws-temp-map-pos-x
               add ws-cursor-pos-delta-y to ws-temp-map-pos-y
               add ws-cursor-pos-delta-x to ws-temp-map-pos-x
               

               if ws-temp-map-pos-y >= ws-max-map-height 
                  or ws-temp-map-pos-x >= ws-max-map-width
                  or ws-temp-map-pos-y <= 0 or ws-temp-map-pos-x <= 0 
               then
                   display     
                       "Caught out of bounds: " at 2532 
                       ws-temp-map-pos-y at 2555
                       ws-temp-map-pos-x at 2557
                   end-display
                   move zeros to ws-cursor-pos-delta
                   exit paragraph
               end-if 
               
      *        move ws-temp-map-pos to ws-cursor-pos
               add ws-cursor-pos-delta-x to ws-cursor-pos-x
               add ws-cursor-pos-delta-y to ws-cursor-pos-y 
               set ws-scr-refresh to true                

           end-if
           display "MapYX: " at 2501 ws-temp-map-pos at 2508
           move zeros to ws-cursor-pos-delta
           exit paragraph.


       set-foreground-color.     
           display "Foreground color [ " at 2101
           display "0" at 2119 
               foreground-color 0 background-color 0
               highlight 
           end-display 
           display "1" at 2120 
               foreground-color 1 background-color 1
               highlight 
           end-display 
           display "2" at 2121 
               foreground-color 2 background-color 2
               highlight 
           end-display 
           display "3" at 2122 
               foreground-color 3 background-color 3
               highlight 
           end-display 
           display "4" at 2123 
               foreground-color 4 background-color 4
               highlight 
           end-display 
           display "5" at 2124 
               foreground-color 5 background-color 5
               highlight 
           end-display 
           display "6" at 2125 
               foreground-color 6 background-color 6
               highlight 
           end-display 
           display "7" at 2126 
               foreground-color 7 background-color 7
               highlight 
           end-display 
           display "]:" at 2127 foreground-color 7 background-color 0               

           accept ws-cursor-draw-color-fg at 2130 update
           if ws-cursor-draw-color-fg > 7 then 
               move 7 to ws-cursor-draw-color-fg
           end-if 
           set ws-scr-refresh to true 
           exit paragraph.


       set-background-color.
           display "Background color [ " at 2101                   
           display "0" at 2119 foreground-color 7 background-color 0
           display "1" at 2120 foreground-color 0 background-color 1
           display "2" at 2121 foreground-color 0 background-color 2
           display "3" at 2122 foreground-color 0 background-color 3
           display "4" at 2123 foreground-color 0 background-color 4
           display "5" at 2124 foreground-color 0 background-color 5
           display "6" at 2125 foreground-color 0 background-color 6
           display "7" at 2126 foreground-color 0 background-color 7
           display "]:" at 2127 foreground-color 7 background-color 0
           accept ws-cursor-draw-color-bg at 2130 update
           if ws-cursor-draw-color-bg > 7 then 
               move 7 to ws-cursor-draw-color-bg
           end-if 
           set ws-scr-refresh to true 
           exit paragraph. 


       set-tile-char.
           display "Tile character: " at 2101
      *> Accepts are inverted on default so revert colors back to give
      *> actual representation of tile to be placed.  
      *> Also highlight is reversed as well, so cannot display highlight
      *> foreground characters on accept.              
           accept 
               ws-cursor-draw-char at 2117 update 
               foreground-color ws-cursor-draw-color-bg
               background-color ws-cursor-draw-color-fg
           end-accept
           
           set ws-scr-refresh to true 
           exit paragraph.        


       toggle-fg-highlight.
           if ws-cursor-highlight then
               set ws-cursor-no-highlight to true 
      *         display "Highlight disabled." at 2701
           else 
               set ws-cursor-highlight to true
      *         display "Highlight enabled. " at 2701 
           end-if 
           exit paragraph. 


       toggle-blocking-mode.
           if ws-cursor-blocking then 
               set ws-cursor-not-block to true 
      *         display "Blocking disabled." at 2701
           else 
               set ws-cursor-blocking to true 
      *         display "Blocking enabled. " at 2701
           end-if 
           exit paragraph.


       toggle-blink.
           if ws-cursor-blink then 
               set ws-cursor-not-blink to true 
           else 
               set ws-cursor-blink to true 
           end-if 
           exit paragraph.


       set-effect-id. 
           display "Tile effect id: " at 2101
           display "[Zero to clear]" at 2122
           accept ws-cursor-draw-effect at 2117 update 

           if ws-cursor-draw-effect > 0 then 
               call "setup-tile-effect" using 
                   ws-cursor-draw-effect ws-cursor-teleport-settings
           end-if 

           set ws-scr-refresh to true 
           exit paragraph.


       load-map-data.

           display "Map name to load: " at 2101
           display "[Blank to cancel]" at 2135
           accept ws-map-name at 2120 update upper
           display ws-line-mask at 2101
           
           if ws-map-name not = spaces 
           and ws-map-name not = ws-map-name-temp then 
               
                              
               call "load-map-data" using 
                   ws-map-files ws-tile-map-table-matrix 
                   ws-enemy-data ws-teleport-data
                   ws-load-return-code
               end-call 

               if ws-load-return-code not = 0 then 
                   display "Error loading: " at 0201 ws-map-name at 0225
                   accept ws-kb-input at 2101
                   move ws-map-name-temp to ws-map-name 
               else
                   move ws-map-name to ws-map-name-temp 
               end-if  

           end-if 

           exit paragraph.


       set-enemy-settings.
           display "Enter enemy name: " at 2101
           accept ws-cursor-enemy-name at 2120 update 
           display ws-line-mask at 2101
       
           display "Enter enemy max hp:" at 2101
           accept ws-cursor-enemy-hp at 2121 update 
                      
           display "Enter enemy attack damage: " at 2101
           accept ws-cursor-enemy-attack-damage at 2128 update

           display ws-line-mask at 2101  

           display "Enter enemy color [0-7]: " at 2101
           accept ws-cursor-enemy-color at 2126 update 

           display ws-line-mask at 2101  

           display "Enter enemy character: " at 2101
           accept ws-cursor-enemy-char at 2124 update 

           display ws-line-mask at 2101  

           display "Enter enemy ticks to move: " at 2101
           accept ws-cursor-enemy-movement-ticks at 2128 update 

           display ws-line-mask at 2101
           display "Enter enemy exp worth: " at 2101
           accept ws-cursor-enemy-exp-worth at 2124

           exit paragraph.




       place-item-at-mouse-pos.           
           compute ws-temp-map-pos-y = ws-cursor-pos-y + ws-mouse-row                   
           compute ws-temp-map-pos-x = ws-cursor-pos-x + ws-mouse-col 

           if ws-temp-map-pos-y > 0
               and ws-temp-map-pos-x > 0 
               and ws-temp-map-pos-y <= ws-max-map-height
               and ws-temp-map-pos-x <= ws-max-map-width then 

               display "MOUSE: " at 2260 ws-temp-map-pos at 2270
               if ws-cursor-type-tile then 
                   perform place-tile                  
               else 
                   perform place-enemy
               end-if 
           end-if 

           exit paragraph.


       place-item-at-cursor-pos.
           compute ws-temp-map-pos-y = ws-cursor-pos-y + ws-cursor-scr-y
           compute ws-temp-map-pos-x = ws-cursor-pos-x + ws-cursor-scr-x                   
           if ws-cursor-type-tile then 
                   perform place-tile                  
               else 
                   perform place-enemy
               end-if 
           exit paragraph.


      *> Called from place item at cursor or mouse!!! not directly!!!
       place-tile.

           move ws-cursor-draw-color-fg 
               to ws-tile-fg(ws-temp-map-pos-y, ws-temp-map-pos-x)

           move ws-cursor-draw-color-bg 
               to ws-tile-bg(ws-temp-map-pos-y, ws-temp-map-pos-x)

           move ws-cursor-draw-char
               to ws-tile-char(ws-temp-map-pos-y, ws-temp-map-pos-x)

           move ws-cursor-draw-highlight
               to ws-tile-highlight(
                   ws-temp-map-pos-y, ws-temp-map-pos-x)

           move ws-cursor-draw-blocking 
               to ws-tile-blocking(ws-temp-map-pos-y, ws-temp-map-pos-x)

           move ws-cursor-draw-blinking
               to ws-tile-blinking(ws-temp-map-pos-y, ws-temp-map-pos-x)
                   
           if ws-cursor-draw-effect > 0 then 
               call "set-tile-effect" using
                   ws-temp-map-pos
                   ws-tile-effect-id(
                       ws-temp-map-pos-y, ws-temp-map-pos-x)
                   ws-cursor ws-teleport-data 
               end-call 
           end-if 

           display "Tile placed at:" at 2401 ws-temp-map-pos at 2417                  

           exit paragraph.


      *> Called from place item at cursor or mouse!!! not directly!!!
       place-enemy.
      
      *> Check to see if enemy was previously placed there.
      *> If so, ask to remove it.
           set ws-enemy-not-found to true
           move zeros to ws-enemy-found-idx

           perform varying ws-counter-1 from 1 by 1
               until ws-counter-1 > ws-cur-num-enemies

               if ws-temp-map-pos = ws-enemy-pos(ws-counter-1) then 
                   set ws-enemy-found to true 
                   move ws-counter-1 to ws-enemy-found-idx                   
                   exit perform 
               end-if 
           end-perform 

           if ws-enemy-found then 
               display "Remove placed enemy? [y/n] " at 2101                
               accept ws-replace-enemy at 2128 with auto-skip upper
               if ws-replace-enemy = 'Y' then 
      *>           Shift whole array down one element, replacing deleted enemy               
                   perform varying ws-counter-1 
                       from ws-enemy-found-idx by 1 
                       until ws-counter-1 > ws-cur-num-enemies + 1
                       
                       move ws-enemy(ws-counter-1 + 1) to 
                           ws-enemy(ws-counter-1)
                   end-perform 

                   subtract 1 from ws-cur-num-enemies
               end-if 
               exit paragraph 
           end-if 

      *> Place new enemy if none exists and enemy to place isn't empty.
           if ws-cursor-enemy-hp not = zeros 
               and ws-cursor-enemy-char not = spaces 
               and ws-cursor-enemy-movement-ticks not = zeros then 

               add 1 to ws-cur-num-enemies

               move ws-cursor-enemy-name 
                   to ws-enemy-name(ws-cur-num-enemies)

               move ws-cursor-enemy-color 
                   to ws-enemy-color(ws-cur-num-enemies)
           
               move ws-cursor-enemy-attack-damage 
                   to ws-enemy-attack-damage(ws-cur-num-enemies)
           
               move ws-cursor-enemy-char 
                   to ws-enemy-char(ws-cur-num-enemies)
           
               move ws-cursor-enemy-hp 
                   to ws-enemy-hp-current(ws-cur-num-enemies)

               move ws-cursor-enemy-hp 
                   to ws-enemy-hp-total(ws-cur-num-enemies)

               move ws-cursor-enemy-movement-ticks 
                   to ws-enemy-max-ticks(ws-cur-num-enemies) 

               move ws-cursor-enemy-movement-ticks
                   to ws-enemy-current-ticks(ws-cur-num-enemies)              

               move ws-cursor-enemy-exp-worth 
                   to ws-enemy-exp-worth(ws-cur-num-enemies)

               move ws-temp-map-pos-y to ws-enemy-y(ws-cur-num-enemies) 
               move ws-temp-map-pos-x to ws-enemy-x(ws-cur-num-enemies)

               display 
                   "Enemy placed at:" at 2401 ws-temp-map-pos at 2417                  
               end-display
           end-if 

           exit paragraph.


       generate-init-world-data.

           perform varying ws-counter-1 
           from 1 by 1 until ws-counter-1 > ws-max-map-height
               perform varying ws-counter-2 
               from 1 by 1 until ws-counter-2 > ws-max-map-width                        

                   move white to 
                       ws-tile-fg(ws-counter-1, ws-counter-2)
                                      
                   move green to 
                       ws-tile-bg(ws-counter-1, ws-counter-2)

                   set ws-tile-not-highlight(ws-counter-1, ws-counter-2)
                       to true 

                   set ws-tile-not-blocking(ws-counter-1, ws-counter-2) 
                       to true 
                   
                   set ws-tile-not-blinking(ws-counter-1, ws-counter-2) 
                       to true 

                   move space 
                       to ws-tile-char(ws-counter-1, ws-counter-2)    

                   move zero 
                       to ws-tile-effect-id(ws-counter-1, ws-counter-2)                                          

               end-perform
           end-perform    
           exit paragraph.                                  
      

       write-world-data.
           
           display "Enter map name: " at 2101
           accept ws-map-name at 2117 update upper
           if ws-map-name = spaces then 
               move ws-map-name-temp to ws-map-name 
               exit paragraph 
           else 
               move ws-map-name to ws-map-name-temp 
               perform set-file-names 
           end-if 
           
           open output fd-tile-data

           perform varying ws-counter-1 
           from 1 by 1 until ws-counter-1 > ws-max-map-height
               perform varying ws-counter-2 
               from 1 by 1 until ws-counter-2 > ws-max-map-width

                   move ws-tile-map-data(ws-counter-1, ws-counter-2) 
                       to f-tile-data-record

                   write f-tile-data-record                                                                      

               end-perform
           end-perform

           close fd-tile-data

           open output fd-enemy-data
               perform varying ws-counter-1 
               from 1 by 1 until ws-counter-1 > ws-cur-num-enemies
                   move ws-enemy(ws-counter-1) to f-enemy
                   write f-enemy 
               end-perform 
           close fd-enemy-data


           open output fd-teleport-data
               perform varying ws-counter-1 
               from 1 by 1 until ws-counter-1 > ws-cur-num-teleports
                   move ws-teleport-data-record(ws-counter-1) 
                       to f-teleport-data-record
                   write f-teleport-data-record
               end-perform 
           close fd-teleport-data

           display 
               "Saved map data: " at 2101
               ws-map-name at 2117
           end-display 
           accept ws-kb-input at 2150

           exit paragraph. 


       display-commands.
           display "Commands:" at 0160 underline highlight           
           display "arrows - move cursor" at 0253
           display "     b - toggle blocking tiles" at 0353
           display "     c - set tile character" at 0453
           display "     d - set enemy attributes" at 0553
           display "   f/g - set fore/background tile color" at 0653
           display "     h - toggle fg tile highlight" at 0753
           display "     k - toggle blinking tiles" at 0853
           display "     l - load map data" at 0953
           display "     o - save map data" at 1053
           display "     q - quit editor" at 1153
           display " space - place tile or enemy" at 1253
           display "   tab - toggle tile/enemy placement mode" at 1353

           exit paragraph.      


       end program cobol-roguelike-editor.
