      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-03-14
      *> Last Updated: 2021-07-09
      *> Purpose: COBOL Rogulike engine main entry point.
      *> Tectonics:
      *>     ./build_engine.sh
      *>*****************************************************************
       identification division.
       program-id. cobol-roguelike-engine.

       environment division.

       configuration section.

       special-names.
           crt status is ws-crt-status.
          

       input-output section.

       file-control.

       data division.

       file section.

        working-storage section.

       copy screenio.

       copy "shared/copybooks/ws-constants.cpy".

       copy "shared/copybooks/ws-teleport-data.cpy".

       copy "shared/copybooks/ws-file-info.cpy".

       copy "shared/copybooks/ws-enemy-data.cpy".

       copy "shared/copybooks/ws-tile-map-table-matrix.cpy".

       copy "engine/copybooks/ws-action-history.cpy".

       copy "shared/copybooks/ws-item-data.cpy".

       01  ws-crt-status.
           05  ws-crt-status-key-1     pic 99.
           05  ws-crt-status-key-2     pic 99.


       01  ws-temp-time                pic 9(9).

      
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
               10  ws-player-scr-y         pic 99 value 12. *> TODO : This should be configurable on map level
               10  ws-player-scr-x         pic 99 value 20. 
           05  ws-player-status              pic 9 value 0.
               88  ws-player-status-alive    value 0.
               88  ws-player-status-dead     value 1.
               88  ws-player-status-attacked value 2.
               88  ws-player-status-other    value 3.
           05  ws-player-attack-damage.    
               10  ws-player-atk-cur       pic 999 value 1.
               10  ws-player-atk-base      pic 999 value 1.
           05  ws-player-defense-power.
               10  ws-player-def-cur       pic 999 value 1.
               10  ws-player-def-base      pic 999 value 1.
           05  ws-player-level             pic 999 value 1.
           05  ws-player-experience.
               10  ws-player-exp-total     pic 9(7) value 0.
               10  ws-player-exp-next-lvl  pic 9(7) value 75.
           78  ws-player-char               value "@". *> TODO : Make configurable.
           
       
       01  ws-equiped-items.
           05  ws-equiped-weapon.
               10  ws-equip-weapon-name        pic x(16) value "None".
               10  ws-equip-weapon-atk         pic 999 value 0.
               10  ws-equip-weapon-status      pic x value "0".
                   88  ws-equip-weapon-curse   value "-".
                   88  ws-equip-weapon-normal  value "0".
                   88  ws-equip-weapon-bless   value "+".                   
           05  ws-equiped-armor.
               10  ws-equip-armor-name         pic x(16) value "None".
               10  ws-equip-armor-def          pic 999 value 0.
               10  ws-equip-armor-status       pic x value "0".
                   88  ws-equip-armor-curse    value "-".
                   88  ws-equip-armor-normal   value "0".
                   88  ws-equip-armor-bless    value "+".                   


           
       01  ws-map-explored-data.
           05  ws-map-explored-y         occurs ws-max-map-height times.
               10  ws-map-explored-x     occurs ws-max-map-width times.
                   15  ws-map-explored        pic a value 'N'.
                       88  ws-is-explored     value 'Y'.
                       88  ws-is-not-explored value 'N'.

           
       01  ws-temp-damage-delt            pic S999 value 0.

           
       01  ws-enemy-placed-found        pic a value 'N'.
           88  ws-enemy-found           value 'Y'.
           88  ws-enemy-not-found       value 'N'.
       
       01  ws-enemy-found-idx           pic 99 comp.

       01  ws-enemy-exp-disp            pic z(7).

       01  ws-enemy-temp-pos.
           05  ws-enemy-temp-y          pic 99.
           05  ws-enemy-temp-x          pic 99.


       01  ws-kb-input                  pic x.

       01  ws-is-quit                   pic a value 'N'.
           88  ws-quit                  value 'Y'.
           88  ws-not-quit              value 'N'.

 
       01  ws-counter-1                 pic 999 comp.
       01  ws-counter-2                 pic 999 comp.
       01  ws-enemy-idx                 pic 99 comp.
       01  ws-enemy-search-idx          pic 99 comp.
       01  ws-tele-idx                  pic 999 comp.

       01  ws-temp-color                pic 9.

       01  ws-temp-map-pos.
           05  ws-temp-map-pos-y        pic S99.
           05  ws-temp-map-pos-x        pic S99.    

       01  ws-filler                    pic 9(9).

       01  ws-attack-attempt            pic 9(9).

       01  ws-eof                       pic a value 'N'.
           88 ws-is-eof                 value 'Y'.
           88 ws-not-eof                value 'N'.

       01  ws-load-return-code          pic 9.

       01  ws-tile-effect-return-code   pic 99.

       01  ws-player-moved-sw           pic a value 'N'.
           88  ws-player-moved          value 'Y'.
           88  ws-player-not-moved      value 'N'.

       01  ws-teleport-used-sw          pic a value 'N'.
           88  ws-teleport-used         value 'Y'.
           88  ws-teleport-not-used     value 'N'.


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

       01  ws-command-line-buffer         pic x(2048).

       procedure division.
           set environment "COB_SCREEN_EXCEPTIONS" to 'Y'.
           set environment "COB_SCREEN_ESC" to 'Y'.
           set environment "COB_TIMEOUT_SCALE" to '3'.
      *     set environment "COB_EXIT_WAIT" to "NO".

       init-setup.                                     

           accept ws-temp-time from time 
           move function random(ws-temp-time) to ws-filler


      *> TODO : *** MOVE TO COMMAND LINE PARSER SUB PROGRAM *********

           *> evaluate command line args if present.
           accept ws-command-line-buffer from command-line 

           if ws-command-line-buffer not = spaces then 
               call "command-line-parser" using 
                   ws-command-line-buffer
                   ws-map-name
                   ws-map-name-temp 
               end-call 
           end-if 
               
           display space blank screen                
           .
           
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
               ws-item-data 
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

           if ws-teleport-not-used then 
               perform set-player-start-position
           end-if 

           *> Set teleport switch to false after map load.
           set ws-teleport-not-used to true 

           *> reset explored areas on loaded map.
           initialize ws-map-explored-data

           *>set start area as explored.           
           move ws-player-pos to ws-temp-map-pos
           add ws-player-scr-y to ws-temp-map-pos-y
           add ws-player-scr-x to ws-temp-map-pos-x  

           call "set-map-exploration" using 
               ws-map-explored-data, ws-temp-map-pos,
               ws-tile-visibility(
                   ws-temp-map-pos-y, ws-temp-map-pos-x)
           end-call 

           perform draw-playfield 
           .

       main-procedure.
           
           perform until ws-quit or ws-player-status-dead   

      *         move function current-date to ws-current-date-data
      *         move ws-current-millisecond to ws-start-frame
                                                                           
               perform get-input                           
               perform move-player                 
               perform move-enemy                       
               perform draw-playfield 

           end-perform

           if ws-player-status-dead then 
               display 
                   "You died. Game over. Press 'Q' to continue" at 1005
                   foreground-color 7 
                   background-color 0 
               end-display 
               *> TODO : Proper input checking so not to quit when 
               *> UP or DOWN is pressed. Also highscore, etc.
               perform  with test after until ws-kb-input = 'Q'
                   accept ws-kb-input  
                       with auto-skip no-echo upper at 1004
                   end-accept 
               end-perform
           end-if 

      *> Stop and close log if currently enabled and open.
           call "action-history-log-end" 
              
           goback.


       draw-playfield.           
           call "draw-dynamic-screen-data" using 
               ws-player ws-tile-map-table-matrix ws-enemy-data
               ws-action-history ws-map-explored-data 
               ws-equiped-items             
           end-call 
           exit paragraph.


       get-input.

           accept ws-kb-input at 2051 
               with auto-skip no-echo 
               time-out after 250
               upper 
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
      *             display "QUITING" at 0917 
                   set ws-quit to true 

               when COB-SCR-F1
                   call "display-debug" using 
                       ws-player ws-tile-map-table-matrix ws-enemy-data
                       ws-temp-map-pos   
                   end-call                        

               when COB-SCR-F9
                   perform debug-set-full-map-exploration

      *         when other 
      *             display "KB INPUT" at 1760 ws-crt-status at 1775

           end-evaluate
           
      *> Check when key pressed is not a special key.     
           evaluate true

               when ws-kb-input = 'Q'
      *             display "QUITING" at 0917 
                   set ws-quit to true 

               when ws-kb-input = 'S' 
                   add 1 to ws-player-pos-delta-y

               when ws-kb-input = 'W' 
                   subtract 1 from ws-player-pos-delta-y

               when ws-kb-input = 'D'
                   add 1 to ws-player-pos-delta-x

               when ws-kb-input = 'A'
                   subtract 1 from ws-player-pos-delta-x

               when ws-kb-input = 'R'
                   perform restart-level


           *> TODO : maybe this is for ranged attack (if they have it)
           *>        as moving the player into an enemy causes them to attack.
           *>   DISABLING FOR NOW...

      *         when ws-kb-input = space 
                  *> space is assumed input on timeout. have to check if it's not space becuase of timeout
      *             if ws-crt-status not = COB-SCR-TIME-OUT 
      *                 and ws-player-pos-delta = zeros then 
      *                 perform player-attack                       
      *             end-if 

      *>         when other   
      *>             display "KB INPUT: " at 0101 ws-kb-input at 0110

           end-evaluate

           exit paragraph.



       move-player.

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
               set ws-player-not-moved to true 
               exit paragraph
           end-if 

           move zero to ws-enemy-found-idx

           *>Check if enemy is there and not dead, if so attack it.
           perform varying ws-enemy-idx 
           from 1 by 1 until ws-enemy-idx > ws-cur-num-enemies
               if ws-enemy-y(ws-enemy-idx) = ws-temp-map-pos-y 
               and ws-enemy-x(ws-enemy-idx) = ws-temp-map-pos-x
               and not ws-enemy-status-dead(ws-enemy-idx) 
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

               *>set area as explored.
               call "set-map-exploration" using 
                   ws-map-explored-data, ws-temp-map-pos,
                   ws-tile-visibility(
                       ws-temp-map-pos-y, ws-temp-map-pos-x)
               end-call 

               if ws-player-pos-delta not zeros then
                   set ws-player-moved to true 
               else 
                   set ws-player-not-moved to true   
               end-if
           
               perform check-tile-effect

           end-if                            
           
           move zeros to ws-player-pos-delta

           exit paragraph.


       check-tile-effect.

           call "tile-effect-handler" using
               ws-tile-effect-id(ws-temp-map-pos-y, ws-temp-map-pos-x) 
               ws-tile-char(ws-temp-map-pos-y, ws-temp-map-pos-x)
               ws-player ws-temp-map-pos ws-teleport-data ws-map-files
               ws-tile-map-table-matrix
               ws-player-moved-sw 
               ws-action-history
               ws-tile-effect-return-code
           end-call

           evaluate ws-tile-effect-return-code
               when ws-load-map-tele-return-code
                   set ws-teleport-used to true  
                   perform load-tile-map
           end-evaluate

           exit paragraph.

  
       move-enemy.

      *> TODO : Add some type of movement randomization or basic pathfinding.
      *> TODO : move this to its own sub program as it is getting large.

           perform varying ws-enemy-idx 
           from 1 by 1 until ws-enemy-idx > ws-cur-num-enemies

               if not ws-enemy-status-dead(ws-enemy-idx) then 

               *> magic numbers!
                   add 15 to ws-enemy-current-ticks(ws-enemy-idx)

                   if ws-enemy-current-ticks(ws-enemy-idx) >= 
                   ws-enemy-max-ticks(ws-enemy-idx) then 

                       move 0 to ws-enemy-current-ticks(ws-enemy-idx)
                       
                       if ws-enemy-status-attacked(ws-enemy-idx) 
                       then 
                           set ws-enemy-status-alive(ws-enemy-idx) 
                               to true 
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
                       *>Check to make sure another enemy isn't already 
                       *>in that position.
                           move zero to ws-enemy-found-idx 
                           perform varying ws-enemy-search-idx
                           from 1 by 1 until 
                           ws-enemy-search-idx > ws-cur-num-enemies

                               if ws-enemy-search-idx not = ws-enemy-idx 
                               then 
                                   if ws-enemy-temp-x = 
                                   ws-enemy-x(ws-enemy-search-idx) and
                                   ws-enemy-temp-y = 
                                   ws-enemy-y(ws-enemy-search-idx) then
                                       move ws-enemy-search-idx
                                           to ws-enemy-found-idx 
                                       exit perform 
                                   end-if 
                               end-if
                           end-perform 
                                       
                           if ws-enemy-found-idx = 0 then 

                 *> otherwise check if not blocking tile and move there.
                               if ws-tile-not-blocking(
                               ws-enemy-y(ws-enemy-idx), 
                               ws-enemy-temp-x) then 
                                   move ws-enemy-temp-x
                                       to ws-enemy-x(ws-enemy-idx) 
                               end-if 

                               if ws-tile-not-blocking(
                               ws-enemy-temp-y, 
                               ws-enemy-x(ws-enemy-idx)) then 
                                   move ws-enemy-temp-y
                                       to ws-enemy-y(ws-enemy-idx) 
                               end-if 
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


          *> random roll to see if attack hits.
           compute ws-attack-attempt = function random * 100 + 1
      *     display function concatenate("Enemy attack roll: ", 
      *         ws-attack-attempt) at 2660      
      *     end-display
             
           *> if they miss, note it in the log and leave paragraph
           if ws-attack-attempt > 65 then *>magic numbers...
               move function concatenate(
                   function trim(ws-enemy-name(ws-enemy-idx)), 
                   " missed ", 
                   function trim(ws-player-name), "."
               ) to ws-action-history-temp

               call "add-action-history-item" using
                   ws-action-history-temp ws-action-history
               end-call 
               exit paragraph
           end-if 

           compute ws-temp-damage-delt = 
               ws-enemy-attack-damage(ws-enemy-idx) - ws-player-def-cur
           end-compute 

           *> if enemy is too weak to hurt player, log it and exit paragraph.
           if ws-temp-damage-delt <= 0 then 
               move function concatenate(
                   function trim(ws-enemy-name(ws-enemy-idx)), 
                   " attacks but does no damage to ", 
                   function trim(ws-player-name), "."
               ) to ws-action-history-temp

               call "add-action-history-item" using
                   ws-action-history-temp ws-action-history
               end-call 
               exit paragraph     
           end-if       

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

          *> random roll to see if attack hits.
               compute ws-attack-attempt = function random * 100 + 1      
      *         display function concatenate("Player attack roll: ",
      *             ws-attack-attempt) at 2560
      *         end-display

               *> for some reason this doesn't always roll high enough??

               *> if they miss, note it in the log and leave paragraph
               if ws-attack-attempt > 80 then *>magic numbers...
                   move function concatenate(
                       function trim(ws-player-name), " missed ", 
                       function trim(ws-enemy-name(ws-enemy-idx)), "."
                   ) to ws-action-history-temp

                   call "add-action-history-item" using
                       ws-action-history-temp ws-action-history
                   end-call 
                   exit paragraph
               end-if 
          
           *> proceed to attack enemy
               if ws-player-attack-damage <= 
               ws-enemy-hp-current(ws-enemy-idx) then 
                   subtract ws-player-atk-cur 
                       from ws-enemy-hp-current(ws-enemy-idx)
                   end-subtract
                   set ws-enemy-status-attacked(ws-enemy-idx) to true
               else 
                   move zero to ws-enemy-hp-current(ws-enemy-idx)
               end-if 

               move function concatenate(
                   function trim(ws-player-name), " attacks ", 
                   function trim(ws-enemy-name(ws-enemy-idx)), " for ",
                   ws-player-atk-cur, " damage."
               ) to ws-action-history-temp

               call "add-action-history-item" using
                   ws-action-history-temp ws-action-history
               end-call 

           *> If enemy dies from attack, set char and log it.
               if ws-enemy-hp-current(ws-enemy-idx) <= 0 then                     
                   set ws-enemy-status-dead(ws-enemy-idx) to true 

                   move ws-enemy-exp-worth(ws-enemy-idx) 
                       to ws-enemy-exp-disp

                   move function concatenate(                       
                       function trim(ws-enemy-name(ws-enemy-idx)), 
                       " expires giving ",
                       function trim(ws-enemy-exp-disp), 
                       " experience points."
                   ) to ws-action-history-temp

                   call "add-action-history-item" using
                       ws-action-history-temp ws-action-history
                   end-call 

           *>Add exp and level up as needed.
           *> TODO : Move this to its own thing...
           *> TODO : Keep track of kill total?

                   if ws-enemy-exp-worth(ws-enemy-idx) >= 
                   ws-player-exp-next-lvl then 
                       move zero to ws-player-exp-next-lvl
                   else
                       subtract ws-enemy-exp-worth(ws-enemy-idx) from 
                           ws-player-exp-next-lvl
                       end-subtract
                   end-if 

                   add ws-enemy-exp-worth(ws-enemy-idx) 
                       to ws-player-exp-total                   

               *>If leveled up, update stats and log it.
                   if ws-player-exp-next-lvl = 0 then 
                       compute ws-player-exp-next-lvl = 
                           (ws-player-level * 20) + 75
                       end-compute 
                       add 1 to ws-player-level 

                       compute ws-player-hp-max = 
                           ws-player-hp-max + (ws-player-level * 5)
                       end-compute 

                       move ws-player-hp-max to ws-player-hp-current

                       compute ws-player-atk-base = 
                           ws-player-level * 1.5
                       end-compute 

                       compute ws-player-atk-cur = 
                           ws-player-atk-base + ws-equip-weapon-atk
                       end-compute 

                       compute ws-player-def-base = 
                           ws-player-level * 1.25
                       end-compute 

                       compute ws-player-def-cur = 
                           ws-player-def-base + ws-equip-armor-def
                       end-compute 
                      
                       move function concatenate(                       
                           function trim(ws-player-name), 
                           " has leveled up to level ",
                           ws-player-level, "!"
                       ) to ws-action-history-temp

                       call "add-action-history-item" using
                           ws-action-history-temp ws-action-history
                       end-call 
                   end-if                        
               end-if 
           end-if   

           exit paragraph.
           

      *> Sets players start position at start position tile effect. If
      *> Not found, default start position of 1,1 will be used. 
       set-player-start-position.

      *> To set a 'actual' 1,1 need to subtract screen coords
           compute ws-player-y = 1 - ws-player-scr-y 
           compute ws-player-x = 1 - ws-player-scr-x 

           perform varying ws-counter-1 
           from 1 by 1 until ws-counter-1 > ws-max-map-height
               perform varying ws-counter-2 
               from 1 by 1 until ws-counter-2 > ws-max-map-width

                   if ws-tile-effect-id(ws-counter-1, ws-counter-2)
                   = ws-player-start-effect-id then
                       compute ws-player-y = 
                           ws-counter-1 - ws-player-scr-y
                       end-compute 
                       compute ws-player-x =
                           ws-counter-2 - ws-player-scr-x 
                       end-compute 
                       exit paragraph 
                   end-if 

               end-perform
           end-perform 

           exit paragraph.

       
      *> TODO : Should also handle when maps are teleported into and 
      *>        don't have a start pos tile effect in the map.
       restart-level.

           display "Restart level? [Y/N]: " 
               foreground-color 0
               background-color 7
               at 1010 
           end-display 
           accept ws-kb-input upper at 1032
           if ws-kb-input = 'Y' then 
               perform load-tile-map
           end-if         

           exit paragraph.


      *> Debug paragraph to set the full map as explored.
       debug-set-full-map-exploration.
           
           perform varying ws-counter-1 
           from 1 by 1 until ws-counter-1 > ws-max-map-height
               perform varying ws-counter-2 
               from 1 by 1 until ws-counter-2 > ws-max-map-width

                   set ws-is-explored(ws-counter-1, ws-counter-2) 
                       to true    

               end-perform 
           end-perform 

           exit paragraph.

       end program cobol-roguelike-engine.
