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
               organization is indexed
               access mode is dynamic 
               record key is f-item-id
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

       01  ws-selected-idx              pic 999 value 0.

       01  ws-idx                       pic 999.

       01  ws-record-pos.
           05  ws-record-pos-y          pic 99.
           05  ws-record-pos-x          pic 99.

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

           perform generate-test-data

           perform load-item-list.

       main-procedure.


           perform display-current-items           


           goback.



       display-current-items.
           
           display "Current Items" with highlight underline at 0135
           
           display "ID" with highlight underline at 0201 
           display "NAME" with highlight underline at 0208
           display "EFFECT ID" with highlight underline at 0225
           display "WORTH/VALUE" with highlight underline at 0235
           display "COLOR" with highlight underline at 0247
           display "CHAR" with highlight underline at 0253
           display "HIGHLIGHT" with highlight underline at 0258
           display "BLINK" with highlight underline at 0268

           move 3 to ws-record-pos-y
           move 1 to ws-record-pos-x 

           perform varying ws-idx from 1 by 1 
           until ws-idx >= ws-cur-num-list-items

      *         display ws-item-list-data-record(ws-idx) at ws-record-pos
               display ws-item-list-id(ws-idx) at ws-record-pos
               move 08 to ws-record-pos-x 
               display ws-item-list-name(ws-idx) at ws-record-pos 
               move 25 to ws-record-pos-x 
               display ws-item-list-effect-id(ws-idx) at ws-record-pos                
               move 35 to ws-record-pos-x 
               display ws-item-list-worth(ws-idx) at ws-record-pos 
               move 47 to ws-record-pos-x 
               display ws-item-list-color(ws-idx) at ws-record-pos 
               move 53 to ws-record-pos-x 

               evaluate true 
                   when ws-item-list-is-blink(ws-idx) 
                   and ws-item-list-is-highlight(ws-idx)                    
                       display ws-item-list-char(ws-idx) 
                           foreground-color ws-item-list-color(ws-idx) 
                           with blink highlight 
                           at ws-record-pos 
                       end-display 

                  when ws-item-list-is-blink(ws-idx) 
                       display ws-item-list-char(ws-idx) 
                           foreground-color ws-item-list-color(ws-idx) 
                           with blink 
                           at ws-record-pos
                       end-display 

                  when ws-item-list-is-highlight(ws-idx) 
                       display ws-item-list-char(ws-idx) 
                           foreground-color ws-item-list-color(ws-idx) 
                           with highlight 
                           at ws-record-pos 
                       end-display 

                  when other 
                      display ws-item-list-char(ws-idx) 
                          foreground-color ws-item-list-color(ws-idx) 
                          at ws-record-pos 
                      end-display 

               end-evaluate

               move 58 to ws-record-pos-x 
               display ws-item-list-highlight-sw(ws-idx) 
                   at ws-record-pos
               end-display 
               move 68 to ws-record-pos-x
               display ws-item-list-blink-sw(ws-idx) at ws-record-pos

               move 1 to ws-record-pos-x 
               add 1 to ws-record-pos-y 

           end-perform  

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

                       read fd-item-list-data next record 
                           into ws-item-list-data-record(
                               ws-cur-num-list-items)
                           at end set ws-is-eof to true 
                        end-read 

      *                 read fd-item-list-data 
      *                     into ws-item-list-data-record(
      *                         ws-cur-num-list-items)
      *                     key is ws-cur-num-list-items                           
      *                     at end set ws-is-eof to true 
      *                     invalid key 
      *                         display function concatenate(
      *                             "No id: " ws-cur-num-list-items)
      *                             at 2201
      *                         end-display 
      *                         set ws-is-eof to true 
      *                     not invalid key 

      *                 end-read

                       if ws-item-list-file-status not = 
                       ws-file-status-ok and ws-item-list-file-status 
                       not = ws-file-status-eof and 
                       ws-item-list-file-status not = 23 then  *> 23 record not found.
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


       save-list-item-record.

           if ws-selected-idx = zeros then 
               exit paragraph
           end-if 

           open i-o fd-item-list-data
               move ws-selected-idx to f-item-id 
               rewrite f-item-list-data-record 
                   from ws-item-list-data-record(ws-selected-idx)
                   invalid key 
                       write f-item-list-data-record 
                       from ws-item-list-data-record(ws-selected-idx)    
                       end-write 
                       display function concatenate("Key: ", f-item-id, 
                           " doesn't exist. Creating new record.")
                           at 1505
                       end-display 
                   not invalid key 
                       display function concatenate(
                           "Successfully updated record id ", f-item-id)
                           at 1605
                       end-display
               end-rewrite 

           close fd-item-list-data

           exit paragraph.    


       generate-test-data.

           move 1 to ws-selected-idx 
           
           move ws-selected-idx to ws-item-list-id(ws-selected-idx) 
           move "Gold" to ws-item-list-name(ws-selected-idx) 
           move 12 to ws-item-list-effect-id(ws-selected-idx)
           move 50 to ws-item-list-worth(ws-selected-idx)
           move 6 to ws-item-list-color(ws-selected-idx) 
           move '*' to ws-item-list-char(ws-selected-idx)
           set ws-item-list-is-highlight(ws-selected-idx) to true 
           set ws-item-list-is-blink(ws-selected-idx) to true 

           display ws-item-list-data-record(ws-selected-idx) at 2401

           perform save-list-item-record

           exit paragraph.

       end program cobol-roguelike-item-creator.
