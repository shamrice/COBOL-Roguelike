      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-03-14
      *> Last Updated: 2021-04-29
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

           78  ws-max-map-height              value 25.
           78  ws-max-map-width               value 80.
           78  ws-max-num-enemies             value 99.
           78  ws-max-num-teleports           value 999.

           01  ws-player.
               05  ws-player-name          pic x(16) value "Adventurer".
               05  ws-player-hp.
                   10  ws-player-hp-current        pic 999 value 100.
                   10  ws-player-hp-max            pic 999 value 100.
               05  ws-player-pos.
                   10  ws-player-y             pic S99.
                   10  ws-player-x             pic S99.
               05  ws-player-pos-delta.    
                   10  ws-player-pos-delta-y   pic S99.
                   10  ws-player-pos-delta-x   pic S99.
               05  ws-player-scr-pos.  
                   10  ws-player-scr-y         pic 99 value 10.
                   10  ws-player-scr-x         pic 99 value 20. 
               05  ws-player-status              pic 9 value 0.
                   88  ws-player-status-alive    value 0.
                   88  ws-player-status-dead     value 1.
                   88  ws-player-status-attacked value 2.
                   88  ws-player-status-other    value 3.
               05  ws-player-attack-damage     pic 999 value 1.                      
               78  ws-player-char              value "@". *> TODO : Make configurable.

           
           01  ws-temp-damage-delt            pic 999 value 0.

           
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
                   10  ws-enemy-color           pic 9 value 4.                                     
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

           01  ws-load-return-code          pic 9.


           01  ws-action-history.
               05  ws-action-history-item     occurs 10 times.
                   10  ws-action-history-text pic x(50).

           01  ws-action-history-temp       pic x(50).

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
           move function concatenate("Entering ",
               function trim(ws-map-name), "...")
               to ws-action-history-temp
           
           call "add-action-history-item" using 
               ws-action-history-temp ws-action-history
           end-call 

           call "load-map-data" using 
               ws-map-files ws-tile-map-table-matrix 
               ws-enemy-data ws-teleport-data
               ws-load-return-code
           end-call 

           if ws-load-return-code > 0 then 
               display space blank screen 
               display 
                   "FATAL ERROR :: Failed to load area data: " at 0101
                   ws-map-name at 0143 
                   "Please make sure related DAT, BGS, TEL files exist"
                   & " in level data directory." at 0201
               end-display 
               stop run 
           end-if
           .

       main-procedure.
           
           perform until ws-quit or ws-player-status-dead   

      *         move function current-date to ws-current-date-data
      *         move ws-current-millisecond to ws-start-frame
                               
               perform draw-playfield                              
               perform get-input                              
               perform move-player  
               perform move-enemy                       
               
           end-perform

           if ws-player-status-dead then 
               display 
                   "You died. Game over." at 1015
                   foreground-color 7 
                   background-color 0 
               end-display 
               *> TODO : Proper input checking so not to quit when 
               *> UP or DOWN is pressed. Also highscore, etc.
               accept ws-kb-input at 1014 no-echo                    
           end-if 
              
           goback.


       draw-playfield.           
           call "draw-dynamic-screen-data" using 
               ws-player ws-tile-map-table-matrix ws-enemy-data
               ws-action-history               
           end-call 
           exit paragraph.


       get-input.

           accept ws-kb-input at 2051 
               with auto-skip no-echo 
               time-out after 250
           end-accept 

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

               when COB-SCR-F1
                   call "display-debug" using 
                       ws-player ws-tile-map-table-matrix ws-enemy-data
                       ws-temp-map-pos   
                   end-call                        

      *         when other 
      *             display "KB INPUT" at 1760 ws-crt-status at 1775

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
                   *> Catch out of bounds.
                   move zeros to ws-player-pos-delta
                   exit paragraph
               end-if 

               move zero to ws-enemy-found-idx

           *>Check if enemy is there, if so attack it.
               perform varying ws-enemy-idx 
               from 1 by 1 until ws-enemy-idx > ws-cur-num-enemies
                   if ws-enemy-y(ws-enemy-idx) = ws-temp-map-pos-y 
                   and ws-enemy-x(ws-enemy-idx) = ws-temp-map-pos-x 
                   then 
                       move ws-enemy-idx to ws-enemy-found-idx
                       perform player-attack
                       exit perform
                   end-if 
               end-perform 

           *>If no enemy and tile isn't blocking. move player there.
               if ws-enemy-found-idx = 0 and ws-tile-not-blocking(
                   ws-temp-map-pos-y, ws-temp-map-pos-x)                
               then                          
                   add ws-player-pos-delta-x to ws-player-x
                   add ws-player-pos-delta-y to ws-player-y                                                      
               end-if

               perform check-teleport

           end-if
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

      *             display "Teleport at: " at 2301  
      *                 ws-teleport-pos(ws-tele-idx) at 2317
      *                 ws-player-pos at 2325
      *             end-display  

                   if ws-teleport-dest-map(ws-tele-idx) 
                   not = ws-map-name then
                       move ws-teleport-dest-map(ws-tele-idx) 
                           to ws-map-name-temp                        
                   end-if 
                   exit perform 
               
               end-if 

           end-perform 
           
      *     display 
      *         function concatenate(
      *             function trim(ws-map-name), 
      *             " -> ",
      *             function trim(ws-map-name-temp)
      *         ) at 0760
      *         ws-map-dat-file at 0960 
      *     end-display

           *> Load new map if destination map does not match
           if ws-map-name-temp not = ws-map-name then                
               move ws-map-name-temp to ws-map-name
      *         display "New map!" at 1060 ws-map-name at 1070               
               perform load-tile-map                 
           end-if 

           exit paragraph.



       move-enemy.

      *> TODO : Add some type of movement randomization or basic pathfinding.
      *> TODO : keep enemies from walking on top of eachother!

           perform varying ws-enemy-idx 
           from 1 by 1 until ws-enemy-idx > ws-cur-num-enemies

               if not ws-enemy-status-dead(ws-enemy-idx) then 

               *> magic numbers!
                   add 15 to ws-enemy-current-ticks(ws-enemy-idx)

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
  
                       end-if 

                       if ws-enemy-x(ws-enemy-idx) not = 
                       ws-player-x + ws-player-scr-x then 
                             
                           if ws-enemy-x(ws-enemy-idx) < 
                           ws-player-x + ws-player-scr-x then                
                               add 1 to ws-enemy-temp-x                                                              
                           else                            
                               subtract 1 from ws-enemy-temp-x 
                           end-if 
                       end-if 

                   *> If new temp location is player location, attack                   
                       if ws-enemy-temp-x = 
                       ws-player-x + ws-player-scr-x 
                       and ws-enemy-temp-y = 
                       ws-player-y + ws-player-scr-y then 

                           perform enemy-attack

                       else 
                 *> otherwise check if not blocking tile and move there.
                           if ws-tile-not-blocking(
                              ws-enemy-y(ws-enemy-idx), ws-enemy-temp-x)
                           then 
                               move ws-enemy-temp-x
                                   to ws-enemy-x(ws-enemy-idx) 
                           end-if 

                           if ws-tile-not-blocking(
                              ws-enemy-temp-y, ws-enemy-x(ws-enemy-idx))
                           then 
                               move ws-enemy-temp-y
                                   to ws-enemy-y(ws-enemy-idx) 
                           end-if 

                       end-if                        
                   end-if 
               end-if 
           end-perform 

           exit paragraph.



      *> This is called from inside the enemy move loop, therefore the 
      *> enemy index is already set there.
       enemy-attack.

          *> TODO: Eventually take in player level and defense into this 
          *>       calculation.
           compute ws-temp-damage-delt = 
               ws-enemy-attack-damage(ws-enemy-idx)
           end-compute 

           if ws-temp-damage-delt > ws-player-hp-current then 
               set ws-player-status-dead to true 
               move zero to ws-player-hp-current
           else        
               subtract ws-temp-damage-delt from ws-player-hp-current
           end-if 
           
           move 
               function concatenate(
                   function trim(ws-player-name), 
                   " is attacked by a ",
                   function trim(ws-enemy-name(ws-enemy-idx)),
                   " for ",
                   ws-temp-damage-delt,
                   " damange.")
               to ws-action-history-temp
           
           call "add-action-history-item" using 
               ws-action-history-temp
               ws-action-history
           end-call 
               
           exit paragraph.


       *> Called from player-move paragraph. Enemy IDX is set when 
       *> collision is found.
       player-attack.
                   
           if ws-enemy-hp-current(ws-enemy-idx) > 0
           and not ws-enemy-status-dead(ws-enemy-idx) then 
               subtract ws-player-attack-damage 
                   from ws-enemy-hp-current(ws-enemy-idx)
               end-subtract
               set ws-enemy-char-hurt(ws-enemy-idx) to true

               move function concatenate(
                   function trim(ws-player-name), " attacks ", 
                   function trim(ws-enemy-name(ws-enemy-idx)), " for ",
                   ws-player-attack-damage, " damage."
               ) to ws-action-history-temp

               call "add-action-history-item" using
                   ws-action-history-temp ws-action-history
               end-call 

           *> If enemy dies from attack, set char and log it.
               if ws-enemy-hp-current(ws-enemy-idx) <= 0 then  
                   set ws-enemy-char-dead(ws-enemy-idx) to true 
                   set ws-enemy-status-dead(ws-enemy-idx) to true 

                   move function concatenate(                       
                       function trim(ws-enemy-name(ws-enemy-idx)), 
                       " expires."                   
                   ) to ws-action-history-temp

                   call "add-action-history-item" using
                       ws-action-history-temp ws-action-history
                   end-call 
               end-if 
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
