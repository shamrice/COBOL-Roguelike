      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-25
      *> Last Updated: 2021-04-25
      *> Purpose: Module for engine to display action history to the 
      *>          screen. (Called from display-dynamic-screen-data)
      *> Tectonics:
      *>     ./build_engine.sh
      *>*****************************************************************
       identification division.
       program-id. display-action-history.

       environment division.

       data division.

       working-storage section.
       
           78  ws-max-entries               value 10.
           78  ws-draw-row-start            value 21.

       local-storage section.

           01  ls-counter                   pic 99.

           01  ls-draw-pos.
               05  ls-draw-y                pic 99.
               05  ls-draw-x                pic 99.

       linkage section.

           01  l-action-history.
               05  l-action-history-item    occurs ws-max-entries times.
                   10  l-action-history-text pic x(50).


       procedure division using l-action-history.

       main-procedure.

           move ws-draw-row-start to ls-draw-y
           move 01 to ls-draw-x 

           perform varying ls-counter 
           from ws-max-entries by -1 until ls-counter = 0
           
               if l-action-history-text(ls-counter) not = spaces then 
                   display l-action-history-text(ls-counter) 
                       at ls-draw-pos 
                   end-display 
                   add 1 to ls-draw-y 
               end-if                
           end-perform     
           goback.

       end program display-action-history.
