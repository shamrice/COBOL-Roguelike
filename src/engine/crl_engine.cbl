      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-03-14
      *> Last Updated: 2021-04-19
      *> Purpose: Tile based console game
      *> Tectonics:
      *>     cobc -x tile_game.cbl
      *>*****************************************************************
       identification division.
       program-id. cobol-roguelike-engine.

       environment division.

       configuration section.

       special-names.
           crt status is ws-crt-status.
          

       input-output section.

       file-control.
           select optional fd-tile-data 
               assign to dynamic ws-map-dat-file 
               organization is record sequential
               file status is ws-map-file-status.

           select optional fd-teleport-data
               assign to dynamic ws-map-tel-file
               organization is record sequential
               file status is ws-teleport-file-status.            

           select optional fd-enemy-data
               assign to dynamic ws-map-enemy-file
               organization is record sequential
               file status is ws-enemy-file-status.

       data division.

       file section.

           fd  fd-tile-data.
           01  f-tile-data-record.
               05  f-tile-fg               pic 9.   
               05  f-tile-bg               pic 9.
               05  f-tile-char             pic x.
               05  f-tile-highlight        pic a.
               05  f-tile-blocking         pic a.
               05  f-tile-blinking         pic a.
               05  f-tile-effect-id        pic 99.


       fd  fd-teleport-data.
           01  f-teleport-data-record.
               05  f-teleport-pos.
                   10  f-teleport-y        pic S99.
                   10  f-teleport-x        pic S99.
               05  f-teleport-dest-pos.
                   10  f-teleport-dest-y   pic S99.
                   10  f-teleport-dest-x   pic S99.
               05  f-teleport-dest-map     pic x(15).

           fd  fd-enemy-data.           
           01  f-enemy.
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

       working-storage section.

       copy screenio.

           01  ws-crt-status.
               05  ws-crt-status-key-1     pic 99.
               05  ws-crt-status-key-2     pic 99.

           01  ws-map-files.  
               05  ws-map-name             pic x(15) value "world0".
               05  ws-map-name-temp        pic x(15) value "world0".           
               05  ws-map-dat-file         pic x(15).               
               05  ws-map-tel-file         pic x(15).
               05  ws-map-enemy-file       pic x(15).

           01  ws-map-file-statuses.
               05  ws-map-file-status      pic xx.
               05  ws-teleport-file-status pic xx.
               05  ws-enemy-file-status    pic xx.

           78  ws-file-status-ok           value "00".
           78  ws-file-status-eof          value "10".

           78  ws-data-file-ext            value ".dat".
           78  ws-teleport-file-ext        value ".tel".
           78  ws-enemy-file-ext           value ".bgs".

           01  ws-temp-time                pic 9(9).

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
           78  ws-max-view-height             value 20.
           78  ws-max-view-width              value 45.
           78  ws-max-num-enemies             value 99.
           78  ws-max-num-teleports           value 999.

           01  ws-player.
               05  ws-player-pos.
                   10  ws-player-y             pic S99.
                   10  ws-player-x             pic S99.
               05  ws-player-pos-delta.    
                   10  ws-player-pos-delta-y   pic S99.
                   10  ws-player-pos-delta-x   pic S99.
               05  ws-player-scr-pos.  
                   10  ws-player-scr-y         pic 99 value 10.
                   10  ws-player-scr-x         pic 99 value 20.    
               78  ws-player-char              value "@".

           
           01  ws-cur-num-enemies           pic 99 value 0.

           01  ws-enemy-data.
               05  ws-enemy       occurs 0 to ws-max-num-enemies times
                                  depending on ws-cur-num-enemies.
                   10  ws-enemy-hp.
                       15  ws-enemy-hp-total    pic 999 value 10.
                       15  ws-enemy-hp-current  pic 999 value 10.
                   10  ws-enemy-attack-damage   pic 999 value 1.
                   10  ws-enemy-pos.
                       15  ws-enemy-y           pic 99.
                       15  ws-enemy-x           pic 99.
                   10  ws-enemy-color           pic 9 value red.                                     
      *>TODO: this isn't configurable will reset after hit.
                   10  ws-enemy-char            pic x value space. 
                       88  ws-enemy-char-alive  value "&".
                       88  ws-enemy-char-dead   value "X".
                       88  ws-enemy-char-hurt   value "#".
                   10  ws-enemy-status              pic 9 value 3.
                       88  ws-enemy-status-alive    value 0.
                       88  ws-enemy-status-dead     value 1.
                       88  ws-enemy-status-attacked value 2.
                       88  ws-enemy-status-other    value 3.
                   10  ws-enemy-movement-ticks.
                       15  ws-enemy-current-ticks   pic 999.
                       15  ws-enemy-max-ticks       pic 999.

           01  ws-enemy-placed-found        pic a value 'N'.
               88  ws-enemy-found           value 'Y'.
               88  ws-enemy-not-found       value 'N'.
           01  ws-enemy-found-idx           pic 99.

           01  ws-enemy-temp-pos.
               05  ws-enemy-temp-y          pic 99.
               05  ws-enemy-temp-x          pic 99.

           01  ws-enemy-draw-pos    occurs 0 to ws-max-num-enemies times
                                    depending on ws-cur-num-enemies.
               05  ws-enemy-draw-y          pic 99.
               05  ws-enemy-draw-x          pic 99.


           01  ws-kb-input                  pic x.

           01  ws-is-quit                   pic a value 'N'.
               88  ws-quit                  value 'Y'.
               88  ws-not-quit              value 'N'.

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

           01  ws-scr-refresh-req           pic a value 'Y'.
               88  ws-scr-refresh           value 'Y'.
               88  ws-scr-no-refresh        value 'N'.

           01  ws-scr-draw-pos.
               05  ws-scr-draw-y            pic 99.
               05  ws-scr-draw-x            pic 99.

           01  ws-map-pos.
               05  ws-map-pos-y             pic S999.
               05  ws-map-pos-x             pic S999.

           01  ws-counter-1                 pic 999.
           01  ws-counter-2                 pic 999.
           01  ws-enemy-idx                 pic 99.
           01  ws-tele-idx                  pic 999.

           01  ws-temp-color                pic 9.

           01  ws-temp-map-pos.
               05  ws-temp-map-pos-y        pic S99.
               05  ws-temp-map-pos-x        pic S99.

           01  ws-filler                    pic 9(9).

           01  ws-eof                       pic a value 'N'.
               88 ws-is-eof                 value 'Y'.
               88 ws-not-eof                value 'N'.

      *> Currently unused.
           01  ws-frame-rate.
               05  ws-start-frame           pic 9(2).
               05  ws-end-frame             pic 9(2).
               05  ws-frame-diff            pic 9(2).
               05  ws-sleep-time            pic 9(2).
      *> Currently unused.
           01 ws-current-date-data.
               05  ws-current-date.
                   10  ws-current-year         PIC 9(04).
                   10  ws-current-month        PIC 9(02).
                   10  ws-current-day          PIC 9(02).
               05  ws-current-time.
                   10  ws-current-hour         PIC 9(02).
                   10  ws-current-minute       PIC 9(02).
                   10  ws-current-second       PIC 9(02).
                   10  ws-current-millisecond  PIC 9(02).

       procedure division.
           set environment "COB_SCREEN_EXCEPTIONS" to 'Y'.
           set environment "COB_SCREEN_ESC" to 'Y'.
           set environment "COB_TIMEOUT_SCALE" to '3'.

       init-setup. 
           move '0505' to ws-player-pos                         

           display space blank screen 

           accept ws-temp-time from time 
           move function random(ws-temp-time) to ws-filler.

      *     perform generate-fake-world-data.
           
       load-tile-map.

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

      *> Load data from files.

           open input fd-tile-data

           if ws-map-file-status not = ws-file-status-ok then 
               display 
                   "Failed to open tile data: " at 0101
                   ws-map-dat-file at 0130
               end-display 
               stop run 
           end-if     
                     
           
           perform varying ws-counter-1 
           from 1 by 1 until ws-counter-1 > ws-max-map-height
               perform varying ws-counter-2 
               from 1 by 1 until ws-counter-2 > ws-max-map-width

                   read fd-tile-data 
                       into ws-tile-map-data(ws-counter-1, ws-counter-2)
                   end-read 
                   if ws-map-file-status not = ws-file-status-ok then 
                       display "Error reading tile map data." at 0101
                       display ws-map-file-status at 0201
                       close fd-tile-data
                       stop run 
                   end-if 
               end-perform
           end-perform
           display "Press enter to close input file" at 0625
           accept ws-filler 
           close fd-tile-data
           display "Input file closed" at 0625
           display ws-player-pos at 0725
           accept ws-filler 
           
      *> Reset and load enemy file info.
           move 0 to ws-cur-num-enemies
           set ws-not-eof to true             

           open input fd-enemy-data      
               perform until ws-is-eof 
                   add 1 to ws-cur-num-enemies        
                   if ws-cur-num-enemies < ws-max-num-enemies then  

                       initialize ws-enemy(ws-cur-num-enemies)  
                       initialize ws-enemy-draw-pos(ws-cur-num-enemies)

                       read fd-enemy-data 
                           into ws-enemy(ws-cur-num-enemies)    
                           at end set ws-is-eof to true 
                       end-read

                       if ws-enemy-file-status not = 
                       ws-file-status-ok and ws-enemy-file-status not = 
                       ws-file-status-eof then 
                           display "Error reading enemy data." at 0101
                           display ws-enemy-file-status at 0201
                           close fd-enemy-data
                           stop run 
                       end-if  

                   else 
                       set ws-is-eof to true 
                   end-if 
                   
                   display ws-cur-num-enemies at 0101
                   display f-enemy at 0201
                   display ws-eof at 0301      
               end-perform 
           close fd-enemy-data


      *> Reset and load teleport file info.
           move 0 to ws-cur-num-teleports
           set ws-not-eof to true             

           open input fd-teleport-data      
               perform until ws-is-eof 
                   add 1 to ws-cur-num-teleports        
                   if ws-cur-num-teleports < ws-max-num-teleports then  

                       initialize 
                           ws-teleport-data-record(ws-cur-num-teleports)  
                                              
                       read fd-teleport-data 
                           into ws-teleport-data-record(
                               ws-cur-num-teleports)
                           at end set ws-is-eof to true 
                       end-read

                       if ws-teleport-file-status not = 
                       ws-file-status-ok and ws-teleport-file-status 
                       not = ws-file-status-eof then 
                           display "Error reading tele data." at 0101
                           display ws-teleport-file-status at 0201
                           close fd-teleport-data
                           stop run 
                       end-if  

                   else 
                       set ws-is-eof to true 
                   end-if                    
               end-perform 
           close fd-teleport-data
           .

       main-procedure.
           
           perform until ws-quit   

      *         move function current-date to ws-current-date-data
      *         move ws-current-millisecond to ws-start-frame
                               
               perform draw-playfield                              
               perform get-input                              
               perform move-player  
               perform move-enemy                       

      *> TODO: Decide if want actual FPS figured out or more like a rouge-like
      *>       game where there's a steady "tick" unless player has input.         
      *         move function current-date to ws-current-date-data 
      *         move ws-current-millisecond to ws-end-frame
      *         compute ws-frame-diff = ws-end-frame - ws-start-frame 

      
      *         compute ws-sleep-time =  50 - ws-frame-diff 

      *         display ws-current-millisecond at 0265
      *         display ws-frame-diff at 0275  
      *         display ws-sleep-time at 0375                                  

      *         call "CBL_GC_NANOSLEEP" using 025000000 
               
           end-perform

           goback.

       draw-playfield.

      *> only redraw if needed.
      *> Badguy always moves... there will always be a refresh.
      *>     if ws-scr-no-refresh then 
      *>         exit paragraph 
      *>     end-if 

      *> TODO : UPDATE DRAW ROUTINE TO MATCH EDITOR! This is outdated and missing features.

           move zeros to ws-temp-map-pos

           display "pscrpos: " at 1950 ws-player-scr-pos at 1960
      *     display "enemyHP: " at 0150 ws-enemy-hp-current at 0160

           perform varying ws-counter-1 
           from 1 by 1 until ws-counter-1 > ws-max-view-height
               perform varying ws-counter-2 
               from 1 by 1 until ws-counter-2 > ws-max-view-width

                   compute ws-scr-draw-y =  ws-counter-1 
                   compute ws-scr-draw-x = ws-counter-2

                   compute ws-map-pos-y = ws-player-y + ws-counter-1 
                   compute ws-map-pos-x = ws-player-x + ws-counter-2 
                   
                   
      *>  draw world tile:
              
                   if ws-map-pos-y < ws-max-map-height
                       and ws-map-pos-x < ws-max-map-width
                       and ws-map-pos-y > 0 and ws-map-pos-x > 0 
                       then 
                       display 
                           ws-tile-char(ws-map-pos-y, ws-map-pos-x) 
                           at ws-scr-draw-pos 
                           background-color
                               ws-tile-bg(ws-map-pos-y, ws-map-pos-x) 
                           foreground-color
                               ws-tile-fg(ws-map-pos-y, ws-map-pos-x) 
                           end-display
                   else 
      *                 display "♥" 
                       display space                      
                           at ws-scr-draw-pos
                           background-color black
                           foreground-color red 
                       end-display
                   end-if

      *> draw player
                   if ws-scr-draw-pos = ws-player-scr-pos then

                       display ws-player-char 
                           at ws-player-scr-pos 
                           background-color 
                           ws-tile-bg(ws-map-pos-y, ws-map-pos-x) 
                           foreground-color yellow highlight
                       end-display  
                   end-if  

                end-perform
           end-perform.

      *> Draw enemies if they exist and are visible.
           if ws-cur-num-enemies > 0 then 
               perform varying ws-enemy-idx from 1 by 1 
               until ws-enemy-idx > ws-cur-num-enemies

                   if ws-enemy-y(ws-enemy-idx) > ws-player-y then                    
                       compute ws-enemy-draw-y(ws-enemy-idx) = 
                           ws-enemy-y(ws-enemy-idx) - ws-player-y
                       end-compute 
                    end-if 

                   if ws-enemy-x(ws-enemy-idx) > ws-player-x then                    
                       compute ws-enemy-draw-x(ws-enemy-idx) = 
                           ws-enemy-x(ws-enemy-idx) - ws-player-x
                       end-compute 
                   end-if   

      *>       Draw enemy if in visible view area.
                   if ws-enemy-draw-y(ws-enemy-idx) > 0 and 
                   ws-enemy-draw-y(ws-enemy-idx) <= ws-max-view-height
                   and ws-enemy-draw-x(ws-enemy-idx) > 0 and 
                   ws-enemy-draw-x(ws-enemy-idx) <= ws-max-view-width
                   then 
                       display 
                           ws-enemy-char(ws-enemy-idx) 
                           at ws-enemy-draw-pos(ws-enemy-idx)
                           foreground-color ws-enemy-color(ws-enemy-idx)
                           background-color ws-tile-bg(
                               ws-enemy-y(ws-enemy-idx), 
                               ws-enemy-x(ws-enemy-idx))
                       end-display
                   end-if                   

               end-perform 
           end-if  

           set ws-scr-no-refresh to true

           exit paragraph.



       get-input.

           accept ws-kb-input at 2401 
               with auto-skip no-echo 
               time-out after 250
           end-accept 

      *> For debug speed check:
      *     add 1 to ws-player-pos-delta-x

      *> Check special keys being pressed.
           evaluate ws-crt-status 

               when COB-SCR-KEY-DOWN 
                   add 1 to ws-player-pos-delta-y

               when COB-SCR-KEY-UP
                   subtract 1 from ws-player-pos-delta-y

               when COB-SCR-KEY-LEFT
                   subtract 1 from ws-player-pos-delta-x

               when COB-SCR-KEY-RIGHT
                   add 1 to ws-player-pos-delta-x

               when COB-SCR-ESC
                   display "QUITING" at 0917 
                   set ws-quit to true 

               when other 
                   display "KB INPUT" at 1750 ws-crt-status at 1765

           end-evaluate
           
      *> Check when key pressed is not a special key.     
           evaluate true

               when ws-kb-input = 'q'
                   display "QUITING" at 0917 
                   set ws-quit to true 

               when ws-kb-input = 's' 
                   add 1 to ws-player-pos-delta-y

               when ws-kb-input = 'w' 
                   subtract 1 from ws-player-pos-delta-y

               when ws-kb-input = 'd'
                   add 1 to ws-player-pos-delta-x

               when ws-kb-input = 'a'
                   subtract 1 from ws-player-pos-delta-x

               when ws-kb-input = space 
                  *> space is assumed input on timeout. have to check if it's not space becuase of timeout
                   if ws-crt-status not = COB-SCR-TIME-OUT 
                       and ws-player-pos-delta = zeros then 
                       perform player-attack                       
                   end-if 

      *>         when other   
      *>             display "KB INPUT: " at 0101 ws-kb-input at 0110

           end-evaluate

           exit paragraph.



       move-player.
           
           if ws-player-pos-delta <> 0 then 

      *> only move player if tile is not blocking and inside map.
               move ws-player-pos to ws-temp-map-pos
               add ws-player-scr-y to ws-temp-map-pos-y
               add ws-player-scr-x to ws-temp-map-pos-x
               add ws-player-pos-delta-y to ws-temp-map-pos-y
               add ws-player-pos-delta-x to ws-temp-map-pos-x               
            

               if ws-temp-map-pos-y >= ws-max-map-height 
                  or ws-temp-map-pos-x >= ws-max-map-width
                  or ws-temp-map-pos-y <= 0 or ws-temp-map-pos-x <= 0 
               then
                   display     
                       "Caught out of bounds: " at 0147 
                       ws-temp-map-pos-y at 0170
                       ws-temp-map-pos-x at 0172
                   end-display
                   move zeros to ws-player-pos-delta
                   exit paragraph
               end-if 

               if 
              ws-tile-not-blocking(ws-temp-map-pos-y, ws-temp-map-pos-x) 
               then 
      *             move ws-temp-map-pos to ws-player-pos
                   display "pos-before: " at 0355 ws-player-pos at 0366
                   add ws-player-pos-delta-x to ws-player-x
                   add ws-player-pos-delta-y to ws-player-y 
                   display "pos-after: " at 0455 ws-player-pos at 0465
                   display "delta: " at 0555 ws-player-pos-delta at 0561
                   set ws-scr-refresh to true 
               else 
                   display "Blocking: " at 2132 ws-temp-map-pos at 2145                   
               end-if

               perform check-teleport

           end-if
           display "Pyx: " at 2101 ws-player-pos at 2105
           display "MAPyx: " at 2240 ws-temp-map-pos at 2246
           move zeros to ws-player-pos-delta
           exit paragraph.

      ******************************************************************
      * Checks if player steps on a teleport tile. If so, they are 
      * moved to the teleport destination.
      ******************************************************************
       check-teleport.

           if ws-cur-num-teleports = 0 then 
               exit paragraph
           end-if 

           perform varying ws-tele-idx 
           from 1 by 1 until ws-tele-idx > ws-cur-num-teleports
               if ws-teleport-pos(ws-tele-idx) = ws-temp-map-pos then 

                   compute ws-player-y = 
                       ws-teleport-dest-y(ws-tele-idx) - ws-player-scr-y
                   end-compute 

                   compute ws-player-x = 
                       ws-teleport-dest-x(ws-tele-idx) - ws-player-scr-x
                   end-compute 

                   display "Teleport at: " at 2301  
                       ws-teleport-pos(ws-tele-idx) at 2317
                       ws-player-pos at 2325
                   end-display  

                   if ws-teleport-dest-map(ws-tele-idx) 
                   not = ws-map-name then
                       move ws-teleport-dest-map(ws-tele-idx) 
                           to ws-map-name-temp                        
                   end-if 
                   exit perform 
               else 
                   display "No teleport:" at 2201 ws-player-pos at 2216
               end-if 

           end-perform 
           
           display 
               ws-map-name at 0750 "->" at 0765  
               ws-map-name-temp at 0770
               ws-map-dat-file at 0960 
           end-display

           if ws-map-name-temp not = ws-map-name then                
               move ws-map-name-temp to ws-map-name
               display "New map!" at 1060 ws-map-name at 1070               
               perform load-tile-map                 
           end-if 

           exit paragraph.



       move-enemy.

      *> TODO : Add some type of movement randomization or basic pathfinding.

           perform varying ws-enemy-idx 
           from 1 by 1 until ws-enemy-idx > ws-cur-num-enemies

               if not ws-enemy-status-dead(ws-enemy-idx) then 

               *> magic numbers!
                   add 20 to ws-enemy-current-ticks(ws-enemy-idx)

                   if ws-enemy-current-ticks(ws-enemy-idx) >= 
                   ws-enemy-max-ticks(ws-enemy-idx) then 

                       move 0 to ws-enemy-current-ticks(ws-enemy-idx)
                       
                       if ws-enemy-char-hurt(ws-enemy-idx) 
                       then 
                           set ws-enemy-char-alive(ws-enemy-idx) to true 
                       end-if 

                       *> Reset temp positions.
                       move ws-enemy-pos(ws-enemy-idx) 
                           to ws-enemy-temp-pos 

                       
                       *>move temp enemy position to where they "want" to go.
                       if ws-enemy-y(ws-enemy-idx) not = 
                       ws-player-y + ws-player-scr-y then 

                           if ws-enemy-y(ws-enemy-idx) < 
                           ws-player-y + ws-player-scr-y then                                                          
                               add 1 to ws-enemy-temp-y       
                           else 
                               subtract 1 from ws-enemy-temp-y
                           end-if  

                           *>If new location not blocking, update y pos
                           if ws-tile-not-blocking(
                           ws-enemy-temp-y, ws-enemy-x(ws-enemy-idx)) 
                           then 
                               move ws-enemy-temp-y 
                                   to ws-enemy-y(ws-enemy-idx)
                           end-if 
                       end-if 

                       if ws-enemy-x(ws-enemy-idx) not = 
                       ws-player-x + ws-player-scr-x then 
                       
                           if ws-enemy-x(ws-enemy-idx) < 
                           ws-player-x + ws-player-scr-x then                
                               add 1 to ws-enemy-temp-x                                                              
                           else                            
                               subtract 1 from ws-enemy-temp-x 
                           end-if 

                           *> if new location not blocking, update x pos.
                           if ws-tile-not-blocking(
                           ws-enemy-y(ws-enemy-idx), ws-enemy-temp-x) 
                           then 
                               move ws-enemy-temp-x 
                                   to ws-enemy-x(ws-enemy-idx)
                           end-if     
                       end-if                        
                   end-if 
               end-if 
           end-perform 

           exit paragraph.
               
           

       player-attack.

      *> TODO : filler paragraph attacks bad guy regardless where he is.           
           if ws-enemy-hp-current(ws-enemy-idx) > 0 then 
               subtract 1 from ws-enemy-hp-current(ws-enemy-idx)
               set ws-enemy-char-hurt(ws-enemy-idx) to true
           else 
               set ws-enemy-char-dead(ws-enemy-idx) to true 
               set ws-enemy-status-dead(ws-enemy-idx) to true 
           end-if 

           exit paragraph.
           

       generate-fake-world-data.
      *> generate temp world tile data.

           open output fd-tile-data

           perform varying ws-counter-1 
           from 1 by 1 until ws-counter-1 > ws-max-map-height
               perform varying ws-counter-2 
               from 1 by 1 until ws-counter-2 > ws-max-map-width

                  compute ws-temp-color = function random * 7
                   move ws-temp-color to f-tile-fg 
                   
                   compute ws-temp-color = function random * 7
                   move ws-temp-color to f-tile-bg                       

                   compute ws-filler = function random * 10 + 1
                   if ws-filler > 8 then  
                       move 'Y' to f-tile-blocking                       
                       move "B" to f-tile-char
                       move zero to f-tile-fg
                   else
                       move 'N' to f-tile-blocking
                       move space to f-tile-char
                   end-if 

                   write f-tile-data-record                                                                      

               end-perform
           end-perform

           close fd-tile-data
           exit paragraph.       

       end program cobol-roguelike-engine.