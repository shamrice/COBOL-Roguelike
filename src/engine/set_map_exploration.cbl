      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-07
      *> Last Updated: 2021-05-07
      *> Purpose: Module for engine to set the explored portion of the 
      *>          map around the player.
      *> Tectonics:
      *>     ./build_engine.sh
      *>*****************************************************************
       identification division.
       program-id. set-map-exploration.

       environment division.

       data division.

       working-storage section.
       
       copy "shared/copybooks/ws-constants.cpy".

       *> TODO : this should be dynamic.
       78  ws-view-distance      value 3.


       local-storage section.

       01  ls-start-idx-y             pic S99.
       01  ls-end-idx-y               pic S99.

       01  ls-start-idx-x             pic S99.
       01  ls-end-idx-x               pic S99.

       01  ls-idx-y                   pic S99.
       01  ls-idx-x                   pic S99.
  
       linkage section.

       copy "engine/copybooks/l-map-explored-data.cpy".       

       01  l-cur-map-pos.
           05  l-cur-map-pos-y        pic S99.
           05  l-cur-map-pos-x        pic S99.

       procedure division using l-map-explored-data l-cur-map-pos.

       main-procedure.

           compute ls-start-idx-y = l-cur-map-pos-y - ws-view-distance
           compute ls-end-idx-y = l-cur-map-pos-y + ws-view-distance
           compute ls-start-idx-x = l-cur-map-pos-x - ws-view-distance
           compute ls-end-idx-x = l-cur-map-pos-x + ws-view-distance

           perform varying ls-idx-y from ls-start-idx-y by 1 
           until ls-idx-y > ls-end-idx-y
               perform varying ls-idx-x from ls-start-idx-x by 1 
               until ls-idx-x > ls-end-idx-x 

                   if ls-idx-y > 0 and ls-idx-x > 0 then 
                       set l-is-explored(
                           ls-idx-y, ls-idx-x) to true 
                   end-if 

               end-perform
           end-perform

           goback.

       end program set-map-exploration.
