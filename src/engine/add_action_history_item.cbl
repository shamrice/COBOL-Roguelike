      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-25
      *> Last Updated: 2021-06-02
      *> Purpose: Module for engine to add action history text to action 
      *>          history items. Oldest entries will be bumped off list.
      *> Tectonics:
      *>     ./build_engine.sh
      *>*****************************************************************
       identification division.
       program-id. add-action-history-item.

       environment division.

       data division.

       working-storage section.
       
       78  ws-max-entries               value 10.               

       01  ws-counter                    pic 99 comp.

       01  ws-current-idx                pic 99 comp value 1.

       linkage section.

       01  l-new-history-text            pic x(75).

       copy "engine/copybooks/l-action-history.cpy".

       procedure division using 
               l-new-history-text l-action-history.

       main-procedure.

           if ws-current-idx < ws-max-entries then 
               move l-new-history-text to 
                   l-action-history-text(ws-current-idx) 
               add 1 to ws-current-idx

           else 
               perform varying ws-counter 
               from 1 by 1 until ws-counter = ws-max-entries 
                   move l-action-history-item(ws-counter + 1) to 
                       l-action-history-item(ws-counter) 
               end-perform 
               
               move l-new-history-text to 
                   l-action-history-text(ws-current-idx)      
           end-if 
               
           goback.

       end program add-action-history-item.
