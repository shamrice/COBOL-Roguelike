      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-11
      *> Last Updated: 2021-05-11
      *> Purpose: Item editor for the game
      *> Tectonics:
      *>     ./build_item_creator.sh
      *>*****************************************************************
       identification division.
       program-id. cobol-roguelike-item-creator.

       environment division.

       configuration section.
           special-names.
               crt status is ws-crt-status.
               cursor is ws-mouse-position.

       input-output section.

       file-control.

           select optional fd-item-list-data
               assign to dynamic ws-item-list-file-name
               organization is record sequential
               file status is ws-item-list-file-status.

       data division.

       file section.

       copy "shared/copybooks/fd-item-list-data.cpy".

       working-storage section.

       copy screenio.

       copy "shared/copybooks/ws-constants.cpy".      

       copy "shared/copybooks/ws-item-data.cpy".

       copy "shared/copybooks/ws-item-list-file.cpy".

       copy "shared/copybooks/ws-item-list-data.cpy".


       01  ws-mouse-flags              pic 9(4).

       01  ws-crt-status.
           05  ws-crt-status-key-1     pic 99.
           05  ws-crt-status-key-2     pic 99.

       01  ws-mouse-position.
           05  ws-mouse-row            pic 99.
           05  ws-mouse-col            pic 99.

       01  ws-mouse-click-status       pic a value 'N'.
           88  ws-mouse-clicked        value 'Y'.
           88  ws-mouse-not-clicked    value 'N'.

       01  ws-line-mask                   pic x(50) value spaces.

       01  ws-kb-input                    pic x.

       01  ws-eof                         pic a value 'N'.
           88  ws-is-eof                  value 'Y'.
           88  ws-not-eof                 value 'N'.

       01  ws-is-quit                     pic a value 'N'.
           88  ws-quit                    value 'Y'.
           88  ws-not-quit                value 'N'.


       01  ws-load-return-code          pic 9.
       01  ws-save-return-code          pic 9.

       procedure division.
       
       init-setup. 
           set environment "COB_SCREEN_EXCEPTIONS" to 'Y'.
           set environment "COB_SCREEN_ESC" to 'Y'.
           set environment "COB_SCREEN_TAB" to 'Y'.
           set environment "COB_TIMEOUT_SCALE" to '3'.       
      
      *> make mouse active
           compute ws-mouse-flags = COB-AUTO-MOUSE-HANDLING
                   + COB-ALLOW-LEFT-DOWN 
      *             + COB-ALLOW-MIDDLE-DOWN   
      *             + COB-ALLOW-RIGHT-DOWN
                   + COB-ALLOW-LEFT-UP 
      *             + COB-ALLOW-MIDDLE-UP     
      *             + COB-ALLOW-RIGHT-UP
      *             + COB-ALLOW-LEFT-DOUBLE + COB-ALLOW-MIDDLE-DOUBLE 
      *             + COB-ALLOW-RIGHT-DOUBLE
                   + COB-ALLOW-MOUSE-MOVE
           set environment "COB_MOUSE_FLAGS" to ws-mouse-flags
                     
           display space blank screen

           perform load-item-list.

       main-procedure.

           perform display-current-items           


           goback.



       display-current-items.
           
           display "Current Items" with highlight underline at 0135
           
           display "ID" with highlight underline at 0201 
           display "NAME" with highlight underline at 0210
           display "EFFECT ID" with highlight underline at 0225
           display "WORTH/VALUE" with highlight underline at 0245
           display "COLOR" with highlight underline at 0260
           display "CHARACTER" with highlight underline at 0270


           exit paragraph.


       load-item-list.

          move 0 to ws-cur-num-list-items
           set ws-not-eof to true             

           open input fd-item-list-data      
               perform until ws-is-eof                    
                   if ws-cur-num-list-items < 999 then  
                       add 1 to ws-cur-num-list-items
                       initialize 
                         ws-item-list-data-record(ws-cur-num-list-items)  
                                              
                       read fd-item-list-data
                           into ws-item-list-data-record(
                               ws-cur-num-list-items)
                           at end set ws-is-eof to true 
                       end-read

                       if ws-item-list-file-status not = 
                       ws-file-status-ok and ws-item-list-file-status 
                       not = ws-file-status-eof then 
                         display "Error reading item list data." at 0101
                           display ws-item-list-file-status at 0201
                           close fd-item-list-data
                    
                           goback 
                       end-if  

                   else 
                       set ws-is-eof to true 
                   end-if                    
                   
               end-perform 
           close fd-item-list-data       

           exit paragraph.

       end program cobol-roguelike-item-creator.
