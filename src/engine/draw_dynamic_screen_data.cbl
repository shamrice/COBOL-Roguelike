      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-10
      *> Last Updated: 2021-05-14
      *> Purpose: Module for engine to draw data passed to the screen.
      *> Tectonics:
      *>     ./build_engine.sh
      *>*****************************************************************

      *> TODO: Probably rename this sub program so it's not the same name the 
      *>       editor uses to avoid accidential mixing up of the two source files.

       identification division.
       program-id. draw-dynamic-screen-data.

       environment division.

       data division.

       working-storage section.

       copy "shared/copybooks/ws-constants.cpy".

       *> Tile data to use when area is not explored.
       01  ws-unexplored-tile-map-data.
           05  ws-unexplored-tile-fg                 pic 9 value black.   
           05  ws-unexplored-tile-bg                 pic 9 value black.
           05  ws-unexplored-tile-char               pic x value space.
           05  ws-unexplored-tile-highlight          pic a value 'N'.
           05  ws-unexplored-tile-blocking           pic a value 'N'.
           05  ws-unexplored-tile-blinking           pic a value 'N'.
           05  ws-unexplored-tile-effect-id     pic 99 comp value zeros.
           05  ws-unexplored-visiblity          pic 999 comp value zero.       


       local-storage section.
       
       01  ls-counter-1                 pic 999 comp.
       01  ls-counter-2                 pic 999 comp.
       01  ls-enemy-idx                 pic 99 comp.
           
       01  ls-scr-draw-pos.
           05  ls-scr-draw-y            pic 99.
           05  ls-scr-draw-x            pic 99.

       01  ls-map-pos.           
           05  ls-map-pos-y             pic S999.
           05  ls-map-pos-x             pic S999.

       01  ls-line-mask                 pic x(80) value spaces. 

       01  ls-enemy-draw-pos        occurs 0 to ws-max-num-enemies times
                                    depending on l-cur-num-enemies.
           05  ls-enemy-draw-y          pic 99.
           05  ls-enemy-draw-x          pic 99.

       01  ls-char-to-draw              pic x value space.      

       01  ls-player-disp-stats.               
           05  ls-player-disp-hp.
               10  ls-player-disp-hp-cur     pic zz9 value 0.
               10  ls-player-disp-hp-max     pic zz9 value 0.
           05  ls-player-disp-attack-dmg.
               10  ls-player-disp-atk-cur    pic zz9 value 0.
               10  ls-player-disp-atk-base   pic zz9 value 0.
           05  ls-player-disp-defense.
               10  ls-player-disp-def-cur    pic zz9 value 0.
               10  ls-player-disp-def-base   pic zz9 value 0.
           05  ls-player-disp-level          pic zz9 value 0.
           05  ls-player-disp-exp.
               10  ls-player-disp-exp-cur    pic z(6)9 value 0.
               10  ls-player-disp-exp-nxt    pic z(6)9 value 0.

       linkage section.

       copy "engine/copybooks/l-player.cpy".

       copy "shared/copybooks/l-tile-map-table-matrix.cpy".

       copy "shared/copybooks/l-enemy-data.cpy".            

       copy "engine/copybooks/l-action-history.cpy".

       copy "engine/copybooks/l-map-explored-data.cpy".

       copy "engine/copybooks/l-equiped-items.cpy".


       procedure division using 
               l-player l-tile-map-table-matrix l-enemy-data
               l-action-history l-map-explored-data l-equiped-items.

       main-procedure.

           perform varying ls-counter-1 
           from 1 by 1 until ls-counter-1 > ws-max-view-height
               perform varying ls-counter-2 
               from 1 by 1 until ls-counter-2 > ws-max-view-width

                   move ls-counter-1 to ls-scr-draw-y
                   move ls-counter-2 to ls-scr-draw-x 

                   compute ls-map-pos-y = l-player-y + ls-counter-1 
                   compute ls-map-pos-x = l-player-x + ls-counter-2 
                                  
      *>  draw world tile:              
                   if ls-map-pos-y < ws-max-map-height
                       and ls-map-pos-x < ws-max-map-width
                       and ls-map-pos-y > 0 and ls-map-pos-x > 0 
                       then 

                       *> Only draw tile if it's been explored before.
                           if l-is-explored(ls-map-pos-y, ls-map-pos-x)
                           then 

                               move l-tile-char(
                                   ls-map-pos-y, ls-map-pos-x)                            
                                   to ls-char-to-draw                                                    
                               
                               call "draw-tile-character" using
                                   ls-scr-draw-pos, 
                                   l-tile-map-data(
                                          ls-map-pos-y, ls-map-pos-x) 
                                   ls-char-to-draw
                               end-call
                           else 
                               move l-tile-blocking(
                                   ls-map-pos-y, ls-map-pos-x)
                                   to ws-unexplored-tile-blocking

                               call "draw-tile-character" using
                                   ls-scr-draw-pos, 
                                   ws-unexplored-tile-map-data 
                                   ws-unexplored-tile-char
                               end-call
                           end-if   

                   else *> OOB void space
                       display ":"                   
                           at ls-scr-draw-pos
                           background-color black
                           foreground-color red
                       end-display
                   end-if

                   *> draw player
                   if ls-scr-draw-pos = l-player-scr-pos then

                       display l-player-char 
                           at l-player-scr-pos 
                           background-color 
                           l-tile-bg(ls-map-pos-y, ls-map-pos-x) 
                           foreground-color yellow highlight
                       end-display  
                   end-if   

               end-perform
           end-perform

      *> Draw enemies if they exist and are visible.
           if l-cur-num-enemies > 0 then 
               perform varying ls-enemy-idx from 1 by 1 
               until ls-enemy-idx > l-cur-num-enemies

                   if l-enemy-y(ls-enemy-idx) > l-player-y then                    
                       compute ls-enemy-draw-y(ls-enemy-idx) = 
                           l-enemy-y(ls-enemy-idx) - l-player-y
                       end-compute 
                    end-if 

                   if l-enemy-x(ls-enemy-idx) > l-player-x then                    
                       compute ls-enemy-draw-x(ls-enemy-idx) = 
                           l-enemy-x(ls-enemy-idx) - l-player-x
                       end-compute 
                   end-if   

      *>       Draw enemy if in visible view area that is explored
      *>       and not currently occupied by the player... oof.
                   if ls-enemy-draw-y(ls-enemy-idx) > 0 and 
                   ls-enemy-draw-y(ls-enemy-idx) <= ws-max-view-height
                   and ls-enemy-draw-x(ls-enemy-idx) > 0 and 
                   ls-enemy-draw-x(ls-enemy-idx) <= ws-max-view-width                   
                   and l-is-explored(l-enemy-y(ls-enemy-idx), 
                   l-enemy-x(ls-enemy-idx)) and 
                   ls-enemy-draw-pos(ls-enemy-idx) 
                   not = l-player-scr-pos 
                   then 

                       move l-enemy-char(ls-enemy-idx) 
                           to ls-char-to-draw

                       if l-enemy-status-attacked(ls-enemy-idx) then 
                           move "#" to ls-char-to-draw
                       end-if 
                       
                       if l-enemy-status-dead(ls-enemy-idx) then 
                           move "X" to ls-char-to-draw
                       end-if 

                       display 
                           ls-char-to-draw
                           at ls-enemy-draw-pos(ls-enemy-idx)
                           foreground-color l-enemy-color(ls-enemy-idx)
                           background-color l-tile-bg(
                               l-enemy-y(ls-enemy-idx), 
                               l-enemy-x(ls-enemy-idx))
                       end-display
                   end-if                   

               end-perform 
           end-if            
    
      *>     display ws-line-mask at 2101                          
           perform display-player-info

           call "display-action-history" using l-action-history

           goback.

       display-player-info.

           *> TODO : Expand upon this with extra player stats and score.

           move l-player-hp-current to ls-player-disp-hp-cur
           move l-player-hp-max to ls-player-disp-hp-max
           move l-player-atk-cur to ls-player-disp-atk-cur
           move l-player-atk-base to ls-player-disp-atk-base
           move l-player-def-cur to ls-player-disp-def-cur
           move l-player-def-base to ls-player-disp-def-base 
           move l-player-level to ls-player-disp-level
           move l-player-exp-total to ls-player-disp-exp-cur
           move l-player-exp-next-lvl to ls-player-disp-exp-nxt

           display 
               function trim(l-player-name) at 0160 underline highlight           
           end-display 
           display 
               function concatenate(
                   "Level: ", 
                   function trim(ls-player-disp-level)) at 0256
               function concatenate(
                   "HP: ",
                   function trim(ls-player-disp-hp-cur),
                   "/",function trim(ls-player-disp-hp-max)
                   , "    ") at 0359
               function concatenate(
                   "Attack: ",
                   function trim(ls-player-disp-atk-cur), "(",
                   function trim(ls-player-disp-atk-base), ")   ") 
                   at 0455     
               function concatenate(
                   "Defense: ",
                   function trim(ls-player-disp-def-cur), "(",
                   function trim(ls-player-disp-def-base), ")   ") 
                   at 0554                                                 
               function concatenate(
                   "Exp next: ",
                   function trim(ls-player-disp-exp-nxt),
                   "    ") at 0653
               function concatenate(
                   "Total Exp: "
                   function trim(ls-player-disp-exp-cur)) at 0752
           end-display  
          
           display "Equiped:" at 1060 with highlight underline 
           
           if not l-equip-weapon-normal then            
               display
                   function concatenate(
                       "Weapon: ",
                       function trim(l-equip-weapon-name), " (",
                       l-equip-weapon-status, ") ") at 1155
               end-display 
           else 
               display
                   function concatenate(
                       "Weapon: ",
                       function trim(l-equip-weapon-name)) at 1155
               end-display 
           end-if 

           if not l-equip-armor-normal then               
               display 
                   function concatenate(
                       " Armor: ",
                       function trim(l-equip-armor-name), " (",
                       l-equip-armor-status, ") ") at 1255
               end-display

           else 
               display 
                   function concatenate(
                       " Armor: ",
                       function trim(l-equip-armor-name)) at 1255
               end-display
           end-if            

           exit paragraph.

       end program draw-dynamic-screen-data.
       
