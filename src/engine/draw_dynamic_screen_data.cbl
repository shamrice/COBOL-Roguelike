      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-10
      *> Last Updated: 2021-04-20
      *> Purpose: Module for engine to draw data passed to the screen.
      *> Tectonics:
      *>     ./build_editor.sh
      *>*****************************************************************

      *> TODO: Probably rename this sub program so it's not the same name the 
      *>       editor uses to avoid accidential mixing up of the two source files.

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

           01  ws-line-mask                 pic x(80) value spaces. 

           01  ls-enemy-draw-pos    occurs 0 to ws-max-num-enemies times
                                    depending on l-cur-num-enemies.
               05  ls-enemy-draw-y          pic 99.
               05  ls-enemy-draw-x          pic 99.

           01  ws-char-to-draw              pic x.               

       linkage section.

           01  l-player.
               05  l-player-pos.
                   10  l-player-y             pic S99.
                   10  l-player-x             pic S99.
               05  l-player-pos-delta.    
                   10  l-player-pos-delta-y   pic S99.
                   10  l-player-pos-delta-x   pic S99.
               05  l-player-scr-pos.  
                   10  l-player-scr-y         pic 99 value 10.
                   10  l-player-scr-x         pic 99 value 20.    
               78  l-player-char              value "@".


       *> TODO : Copy book!!
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
               05  l-cur-num-enemies           pic 99.
               05  l-enemy       occurs 0 to unbounded times
                                  depending on l-cur-num-enemies.
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
                       15  l-enemy-current-ticks   pic 999.
                       15  l-enemy-max-ticks       pic 999 value 3.           

       procedure division using 
               l-player l-tile-map-table-matrix l-enemy-data.

       main-procedure.

           perform varying ws-counter-1 
           from 1 by 1 until ws-counter-1 > ws-max-view-height
               perform varying ws-counter-2 
               from 1 by 1 until ws-counter-2 > ws-max-view-width

                   move ws-counter-1 to ws-scr-draw-y
                   move ws-counter-2 to ws-scr-draw-x 

                   compute ws-map-pos-y = l-player-y + ws-counter-1 
                   compute ws-map-pos-x = l-player-x + ws-counter-2 
                                  
      *>  draw world tile:              
                   if ws-map-pos-y < ws-max-map-height
                       and ws-map-pos-x < ws-max-map-width
                       and ws-map-pos-y > 0 and ws-map-pos-x > 0 
                       then 
                           
                           move l-tile-char(ws-map-pos-y, ws-map-pos-x) 
                               to ws-char-to-draw                           

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

                   *> draw player
                   if ws-scr-draw-pos = l-player-scr-pos then

                       display l-player-char 
                           at l-player-scr-pos 
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
    
      *>     display ws-line-mask at 2101                          

           goback.

       end program draw-dynamic-screen-data.
       
