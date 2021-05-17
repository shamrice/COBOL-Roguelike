      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-23
      *> Last Updated: 2021-05-14
      *> Purpose: Module for engine to load the level data passed into
      *>          the related record structures.
      *> Tectonics:
      *>     ./build_engine.sh or ./build_editor.sh
      *>*****************************************************************
       identification division.
       program-id. load-map-data.

       environment division.

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

       01  ws-test-data                 pic 99.

       local-storage section.

       01  ls-counter-1                 pic 999 comp.
       01  ls-counter-2                 pic 999 comp.

       01  ls-map-file-statuses.
           05  ls-map-file-status      pic xx.
           05  ls-teleport-file-status pic xx.
           05  ls-enemy-file-status    pic xx.
           05  ls-item-file-status     pic xx.

       01  ls-eof-sw                    pic a value 'N'.
           88 ls-is-eof                 value 'Y'.
           88 ls-not-eof                value 'N'.
       
                     
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
               l-enemy-data l-teleport-data
               l-item-data
               l-return-code.

       main-procedure.


      *> Set file names based on map name
           move function concatenate(
               function trim(l-map-name), ws-data-file-ext)
               to l-map-dat-file

           move function concatenate(
               function trim(l-map-name), ws-teleport-file-ext)
               to l-map-tel-file

           move function concatenate(
               function trim(l-map-name), ws-enemy-file-ext)
               to l-map-enemy-file    

           move function concatenate(
               function trim(l-map-name), ws-item-file-ext)
               to l-map-item-file    
               

      *> Load data from files.

           open input fd-tile-data

           if ls-map-file-status not = ws-file-status-ok then
               close fd-tile-data  
               display 
                   "Failed to open tile data: " at 0101
                   l-map-dat-file at 0130
               end-display 
               move ws-load-status-fail to l-return-code
               goback                
           end-if     
                     
           
           perform varying ls-counter-1 
           from 1 by 1 until ls-counter-1 > ws-max-map-height
               perform varying ls-counter-2 
               from 1 by 1 until ls-counter-2 > ws-max-map-width

                   read fd-tile-data 
                       into l-tile-map-data(ls-counter-1, ls-counter-2)
                   end-read 
                   if ls-map-file-status not = ws-file-status-ok then 
                       display "Error reading tile map data." at 0101
                       display ls-map-file-status at 0201
                       close fd-tile-data
                       
                       move ws-load-status-read-fail 
                           to l-return-code
                       goback 
                   end-if 
               end-perform
           end-perform
           close fd-tile-data
 
      *> Reset and load enemy file info.
           move 0 to l-cur-num-enemies
           set ls-not-eof to true             

           open input fd-enemy-data      
               perform until ls-is-eof 
                   
                   if l-cur-num-enemies < ws-max-num-enemies then  
                                              
                       add 1 to l-cur-num-enemies           
                       initialize l-enemy(l-cur-num-enemies) 

                       read fd-enemy-data 
                           into l-enemy(l-cur-num-enemies)    
                           at end 
                               set ls-is-eof to true 
                        *>Not pretty, but count goes one too high at EOF
                               subtract 1 from l-cur-num-enemies                              
                       end-read
                   
                       if ls-enemy-file-status not = 
                       ws-file-status-ok and ls-enemy-file-status not = 
                       ws-file-status-eof then 
                           display "Error reading enemy data." at 0101
                           display ls-enemy-file-status at 0201
                           close fd-enemy-data
                           
                           move ws-load-status-read-fail 
                               to l-return-code
                           goback 
                       end-if  

                   else 
                       set ls-is-eof to true 
                   end-if 
                          
               end-perform 
           close fd-enemy-data

      *     move l-cur-num-enemies to ws-test-data
      *     display ws-test-data at 0101 
      *     accept omitted

      *> Reset and load teleport file info.
           move 0 to l-cur-num-teleports
           set ls-not-eof to true             

           open input fd-teleport-data      
               perform until ls-is-eof                    
                   if l-cur-num-teleports < ws-max-num-teleports then  
                       add 1 to l-cur-num-teleports 
                       initialize 
                           l-teleport-data-record(l-cur-num-teleports)  
                                              
                       read fd-teleport-data 
                           into l-teleport-data-record(
                               l-cur-num-teleports)
                           at end set ls-is-eof to true 
                       end-read

                       if ls-teleport-file-status not = 
                       ws-file-status-ok and ls-teleport-file-status 
                       not = ws-file-status-eof then 
                           display "Error reading tele data." at 0101
                           display ls-teleport-file-status at 0201
                           close fd-teleport-data
                           
                           move ws-load-status-read-fail 
                               to l-return-code
                           goback 
                       end-if  
                   else 
                       set ls-is-eof to true 
                   end-if      
                                        
               end-perform 
           close fd-teleport-data


      *> Reset and load item file info.
           move 0 to l-cur-num-items
           set ls-not-eof to true             

           open input fd-item-data      
               perform until ls-is-eof                    
                   if l-cur-num-items < ws-max-num-items then  
                       add 1 to l-cur-num-items
                       initialize 
                           l-item-data-record(l-cur-num-items)  
                                              
                       read fd-item-data 
                           into l-item-data-record(
                               l-cur-num-items)
                           at end set ls-is-eof to true 
                       end-read

                       if ls-item-file-status not = 
                       ws-file-status-ok and ls-item-file-status 
                       not = ws-file-status-eof then 
                           display "Error reading item data." at 0101
                           display ls-item-file-status at 0201
                           close fd-item-data
                           
                           move ws-load-status-read-fail 
                               to l-return-code
                           goback 
                       end-if  

                   else 
                       set ls-is-eof to true 
                   end-if                    
                   
               end-perform 
           close fd-item-data

           move ws-load-status-success to l-return-code               
           goback.

       end program load-map-data.
