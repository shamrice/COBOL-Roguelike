      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-03-14
      *> Last Updated: 2021-04-11
      *> Purpose: Map editor for the tile based console game
      *> Tectonics:
      *>     ./build_editor.sh
      *>*****************************************************************
       identification division.
       program-id. tile-game-world-editor.

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
          

       data division.

       file section.

      * TODO : copy book for shared file stuff
      * TODO : implement BLINK tile.

           fd fd-tile-data.
           01  f-tile-data-record.
               05  f-tile-fg               pic 9.   
               05  f-tile-bg               pic 9.
               05  f-tile-char             pic x.
               05  f-tile-highlight        pic a.
               05  f-tile-blocking         pic a.
               05  f-tile-blinking         pic a.
               05  f-tile-effect-id        pic 99.


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
               05  ws-map-name             pic x(15) value "world1".
               05  ws-map-name-temp        pic x(15) value "world1".           
               05  ws-map-dat-file         pic x(15).               
               05  ws-map-tel-file         pic x(15).
                          
           78  ws-data-file-ext            value ".dat".
           78  ws-teleport-file-ext        value ".tel".


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
               05  ws-cursor-draw-effect      pic 99.
               78  ws-cursor-char             value "+".


           01  ws-kb-input                    pic x.

           01  ws-is-quit                     pic a value 'N'.
               88  ws-quit                    value 'Y'.
               88  ws-not-quit                value 'N'.

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


           01  ws-teleport-data-record.
               05  ws-teleport-pos.
                   10  ws-teleport-y        pic S99.
                   10  ws-teleport-x        pic S99.
               05  ws-teleport-dest-pos.
                   10  ws-teleport-dest-y   pic S99.
                   10  ws-teleport-dest-x   pic S99.
               05  ws-teleport-dest-map     pic x(15).
       
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


       procedure division.
       
       init-setup. 
           set environment "COB_SCREEN_EXCEPTIONS" to 'Y'.
           set environment "COB_SCREEN_ESC" to 'Y'.
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

           move 1010 to ws-cursor-pos           
           display space blank screen 

           accept ws-temp-time from time 
           move function random(ws-temp-time) to ws-filler

      *> Set file names based on map name
           move function concatenate(
               function trim(ws-map-name), ws-data-file-ext)
               to ws-map-dat-file

           move function concatenate(
               function trim(ws-map-name), ws-teleport-file-ext)
               to ws-map-tel-file


           perform generate-init-world-data.
      

      * load-tile-map.
      *     open input fd-tile-data

      *     perform varying ws-counter-1 
      *     from 1 by 1 until ws-counter-1 > ws-max-map-height
      *         perform varying ws-counter-2 
      *         from 1 by 1 until ws-counter-2 > ws-max-map-width

      *             read fd-tile-data 
      *                 into ws-tile-map-data(ws-counter-1, ws-counter-2)
      *             end-read 

      *         end-perform
      *     end-perform

      *     close fd-tile-data.       

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
               using ws-cursor ws-tile-map-table-matrix
           end-call 
           set ws-scr-no-refresh to true

           exit paragraph.


       get-input.
                              
           accept ws-kb-input at 2601 with auto-skip no-echo
                     

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

      *> Mouse click status
               when COB-SCR-LEFT-PRESSED 
                   set ws-mouse-clicked to true 
      *             display "CLICKED" at 3505

               when COB-SCR-LEFT-RELEASED
                   set ws-mouse-not-clicked to true 
      *             display "NOT CL" at 3505

               when COB-SCR-ESC
                   display "QUITING" at 0917 
                   set ws-quit to true 

      *         when other 
      *             display "KB INPUT" at 1750 ws-crt-status at 1765

           end-evaluate

      *     display ws-mouse-click-status at 3601
      *     display ws-crt-status at 3611

      *> Check mouse input           
           if ws-mouse-position not = zeros                
               and ws-mouse-row <= 20 
               and ws-mouse-clicked then                      
               perform place-tile-at-mouse-pos      
           end-if 
 
      *> Non-special key input handling.
           evaluate true

               when ws-kb-input = 'q'
                   display "QUITING" at 0917
                   set ws-quit to true              

      *> TODO : alphabetize these

               when ws-kb-input = '0' 
                   move zero to ws-cursor-draw-color-fg

               when ws-kb-input = 'e'
                   perform set-effect-id

               when ws-kb-input = 'f'
                   perform set-foreground-color

               when ws-kb-input = 'g'
                   perform set-background-color

               when ws-kb-input = 'c'
                   perform set-tile-char
               
               when ws-kb-input = 'b'
                   perform toggle-blocking-mode

               when ws-kb-input = 'o' 
                   perform write-world-data

               when ws-kb-input = 'h'
                   perform toggle-fg-highlight

               when ws-kb-input = 'k'
                   perform toggle-blink
                   

               when ws-kb-input = space
                   if ws-crt-status not = COB-SCR-TIME-OUT
                       and ws-cursor-pos-delta = zeros 
                       and ws-crt-status = zeros      
                       then                        
                       perform place-tile-at-cursor-pos
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

           accept ws-cursor-draw-color-fg at 2130
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
           accept ws-cursor-draw-color-bg at 2130
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
               ws-cursor-draw-char at 2117 
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
           accept ws-cursor-draw-effect at 2117

           if ws-cursor-draw-effect > 0 then 
               call "setup-tile-effect" using 
                   ws-cursor-draw-effect ws-teleport-data-record
           end-if 

           set ws-scr-refresh to true 
           exit paragraph.



       place-tile-at-mouse-pos.           
           compute ws-temp-map-pos-y = ws-cursor-pos-y + ws-mouse-row                   
           compute ws-temp-map-pos-x = ws-cursor-pos-x + ws-mouse-col 

           if ws-temp-map-pos-y > 0
               and ws-temp-map-pos-x > 0 
               and ws-temp-map-pos-y <= ws-max-map-height
               and ws-temp-map-pos-x <= ws-max-map-width then 

               display "MOUSE: " at 2260 ws-temp-map-pos at 2270
               perform place-tile                  
           end-if 

           exit paragraph.


       place-tile-at-cursor-pos.
           compute ws-temp-map-pos-y = ws-cursor-pos-y + ws-cursor-scr-y
           compute ws-temp-map-pos-x = ws-cursor-pos-x + ws-cursor-scr-x                   
           perform place-tile.
           exit paragraph.


      *> Called from place tile of cursor or mouse!!! not directly!!!
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

           move ws-cursor-draw-effect
               to ws-tile-effect-id(
                   ws-temp-map-pos-y, ws-temp-map-pos-x)
                   
           if ws-cursor-draw-effect > 0 then 
               call "save-tile-effect" using 
                   ws-cursor-draw-effect ws-map-files ws-cursor-pos 
                   ws-teleport-data-record
               end-call 
           end-if 

           display "Tile placed at:" at 2401 ws-temp-map-pos at 2417                  

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

           display "Saved world data." at 0101

           exit paragraph. 


       display-commands.
           display "Commands:" at 0160 underline highlight           
           display "arrows - move cursor" at 0253
           display "     b - toggle blocking tiles" at 0353
           display "     c - set tile character" at 0453
           display "   f/g - set foreground/background color" at 0553
           display "     h - toggle fg highlight" at 0653
           display "     k - toggle blinking tiles" at 0753
           display "     l - load map data" at 0853
           display "     o - save map data" at 0953
           display "     q - quit editor" at 1053
           display " space - place tile" at 1153

           exit paragraph.      


       end program tile-game-world-editor.