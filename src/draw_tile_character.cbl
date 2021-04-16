      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-11
      *> Last Updated: 2021-04-16
      *> Purpose: Module to draw individual character with correct display 
      *>          attributes.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_game.sh
      *>*****************************************************************

      *> NOTE: This should be shared between editor and main game program.

       identification division.
       program-id. draw-tile-character.

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

       linkage section.
           01  l-scr-draw-pos.
               05  l-scr-draw-y            pic 99.
               05  l-scr-draw-x            pic 99.

           01  l-tile-map-data.
               10  l-tile-fg                   pic 9.   
               10  l-tile-bg                   pic 9.
               10  l-tile-char                 pic x.
               10  l-tile-highlight            pic a value 'N'.
                   88  l-tile-is-highlight      value 'Y'.
                   88  l-tile-not-highlight     value 'N'.
               10  l-tile-blocking             pic a value 'N'.
                   88  l-tile-is-blocking      value 'Y'.
                   88  l-tile-not-blocking     value 'N'.  
               10  l-tile-blinking             pic a value 'N'.
                   88  l-tile-is-blinking      value 'Y'.
                   88  l-tile-not-blinking     value 'N'.
               10  l-tile-effect-id            pic 99.            
            

           01  l-char-to-draw                  pic x.

       procedure division using  
           l-scr-draw-pos l-tile-map-data l-char-to-draw.


       main-procedure.

           evaluate true 

               when l-tile-is-highlight and l-tile-not-blinking
                   display 
                       l-char-to-draw 
                       at l-scr-draw-pos 
                       background-color l-tile-bg 
                       foreground-color l-tile-fg
                       highlight
                   end-display
               
               when l-tile-is-highlight and l-tile-is-blinking
                   display 
                       l-char-to-draw
                       at l-scr-draw-pos 
                       background-color l-tile-bg 
                       foreground-color l-tile-fg
                       highlight blink 
                   end-display 

               when l-tile-not-highlight and l-tile-is-blinking
                   display 
                       l-char-to-draw
                       at l-scr-draw-pos 
                       background-color l-tile-bg 
                       foreground-color l-tile-fg
                       blink
                   end-display 
                                               
               when other  
                   display 
                       l-char-to-draw at l-scr-draw-pos 
                       background-color l-tile-bg 
                       foreground-color l-tile-fg 
                   end-display

           end-evaluate

           goback.


       end program draw-tile-character.
