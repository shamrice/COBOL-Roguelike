      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-11
      *> Last Updated: 2021-05-14
      *> Purpose: Writes current map data to disk.
      *> Tectonics:
      *>     ./build_editor.sh
      *>*****************************************************************
       identification division.
       program-id. write-map-data.

       environment division.

       configuration section.

       input-output section.

       file-control.

           select optional fd-tile-data 
               assign to dynamic l-map-dat-file 
               organization is record sequential
               file status is ls-map-file-status.

           select optional fd-teleport-data
               assign to dynamic l-map-tel-file
               organization is record sequential
               file status is ls-teleport-file-status.            

           select optional fd-enemy-data
               assign to dynamic l-map-enemy-file
               organization is record sequential
               file status is ls-enemy-file-status.

           select optional fd-item-data
               assign to dynamic l-map-item-file
               organization is record sequential
               file status is ls-item-file-status.

       data division.

       file section.

       copy "shared/copybooks/fd-tile-data.cpy".

       copy "shared/copybooks/fd-teleport-data.cpy".

       copy "shared/copybooks/fd-enemy-data.cpy".

       copy "shared/copybooks/fd-item-data.cpy".


       working-storage section.

       copy "shared/copybooks/ws-constants.cpy".

       01  ws-counter-1                 pic 999 comp.
       01  ws-counter-2                 pic 999 comp.


       local-storage section.

       01  ls-map-file-statuses.
           05  ls-map-file-status      pic xx.
           05  ls-teleport-file-status pic xx.
           05  ls-enemy-file-status    pic xx.
           05  ls-item-file-status     pic xx.

       linkage section.

       01  l-map-files.  
           05  l-map-name             pic x(15).
           05  l-map-name-temp        pic x(15). 
           05  l-map-dat-file         pic x(15).               
           05  l-map-tel-file         pic x(15).
           05  l-map-enemy-file       pic x(15).   
           05  l-map-item-file        pic x(15).

       copy "shared/copybooks/l-tile-map-table-matrix.cpy".

       copy "shared/copybooks/l-enemy-data.cpy".

       copy "shared/copybooks/l-teleport-data.cpy".

       copy "shared/copybooks/l-item-data.cpy".



       01  l-return-code                   pic 9 value 0.         

       procedure division using 
           l-map-files l-tile-map-table-matrix 
           l-enemy-data l-teleport-data l-item-data
           l-return-code. 

       main-procedure.

           move ws-save-status-fail to l-return-code 

           open output fd-tile-data

           perform varying ws-counter-1 
           from 1 by 1 until ws-counter-1 > ws-max-map-height
               perform varying ws-counter-2 
               from 1 by 1 until ws-counter-2 > ws-max-map-width

                   move l-tile-map-data(ws-counter-1, ws-counter-2) 
                       to f-tile-data-record

                   write f-tile-data-record                                                                      

               end-perform
           end-perform

           close fd-tile-data

           open output fd-enemy-data
               perform varying ws-counter-1 
               from 1 by 1 until ws-counter-1 > l-cur-num-enemies
                   move l-enemy(ws-counter-1) to f-enemy
                   write f-enemy 
               end-perform 
           close fd-enemy-data


           open output fd-teleport-data
               perform varying ws-counter-1 
               from 1 by 1 until ws-counter-1 > l-cur-num-teleports
                   move l-teleport-data-record(ws-counter-1) 
                       to f-teleport-data-record
                   write f-teleport-data-record
               end-perform 
           close fd-teleport-data

           open output fd-item-data
               perform varying ws-counter-1 
               from 1 by 1 until ws-counter-1 > l-cur-num-items
                   move l-item-data-record(ws-counter-1) 
                       to f-item-data-record
                   write f-item-data-record
               end-perform 
           close fd-item-data

           move ws-save-status-success to l-return-code

           goback.

       end program write-map-data.
