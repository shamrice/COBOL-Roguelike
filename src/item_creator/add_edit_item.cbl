      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-12
      *> Last Updated: 2021-05-20
      *> Purpose: Create or edit item passed via the linkage section.
      *> Tectonics:
      *>     ./build_item_creator.sh
      *>*****************************************************************
       identification division.
       program-id. add-edit-item.

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


       01  ws-selected-idx              pic 999 comp value 0.

       01  ws-record-pos.
           05  ws-record-pos-y          pic 99.
           05  ws-record-pos-x          pic 99.

       01  ws-load-return-code          pic 9.
       01  ws-save-return-code          pic 9.

       linkage section.

       copy "item_creator/copybooks/l-item-list-data-record.cpy".

       01  l-return-code               pic 9.

       screen section.

       01  s-add-edit-item-screen.
           05  s-title-line foreground-color 7 background-color 1.
               10  line 4 column 15 pic x(50) value spaces. 
               10  line 4 column 20 value "Add/Edit Item".
           05  s-space-line foreground-color 0 background-color 7.
               10  line 5 column 15 pic x(50) value spaces.
           05  s-id-line foreground-color 0 background-color 7.
               10  line 6 column 15 pic x(50) value spaces. 
               10  line 6 column 16 value "         ID:".
               10  line 6 column 29 pic 9(6) using l-item-list-id.
           05  s-name-line foreground-color 0 background-color 7.
               10  line 7 column 15 pic x(50) value spaces. 
               10  line 7 column 16 value "       NAME:".
               10  line 7 column 29 pic x(16) using l-item-list-name.
           05  s-effect-id-line foreground-color 0 background-color 7.
               10  line 8 column 15 pic x(50) value spaces. 
               10  line 8 column 16 value "  EFFECT ID:".
               10  line 8 column 29 pic 99 using l-item-list-effect-id.
           05  s-worth-line foreground-color 0 background-color 7.
               10  line 9 column 15 pic x(50) value spaces. 
               10  line 9 column 16 value "WORTH/VALUE:".
               10  line 9 column 29 pic 999 using l-item-list-worth.
           05  s-color-line foreground-color 0 background-color 7.
               10  line 10 column 15 pic x(50) value spaces. 
               10  line 10 column 16 value "      COLOR:".
               10  line 10 column 29 pic 9 using l-item-list-color.
           05  s-char-line foreground-color 0 background-color 7.
               10  line 11 column 15 pic x(50) value spaces. 
               10  line 11 column 16 value "  CHARACTER:".
               10  line 11 column 29 pic x using l-item-list-char.
           05  s-highlight-line foreground-color 0 background-color 7.
               10  line 12 column 15 pic x(50) value spaces. 
               10  line 12 column 16 value "  HIGHLIGHT:".
               10  line 12 column 29 pic x 
                   using l-item-list-highlight-sw.
           05  s-blink-line foreground-color 0 background-color 7.
               10  line 13 column 15 pic x(50) value spaces. 
               10  line 13 column 16 value "      BLINK:".
               10  line 13 column 29 pic x using l-item-list-blink-sw.
           05  s-space-line foreground-color 0 background-color 7.
               10  line 14 column 15 pic x(50) value spaces.
           05  s-info-line foreground-color 0 background-color 7.
               10  line 15 column 15 pic x(50) value spaces. 
               10  line 15 column 16 
                   value "Arrow keys between fields ESC to cancel.".
           05  s-space-line foreground-color 0 background-color 7.
               10  line 16 column 15 pic x(50) value spaces.

       procedure division using 
           l-item-list-data-record l-return-code.

           set environment "COB_SCREEN_EXCEPTIONS" to 'Y'.
           set environment "COB_SCREEN_ESC" to 'Y'.

       main-procedure. 

           accept s-add-edit-item-screen
           
                     *> Check special keys being pressed.
           evaluate ws-crt-status 

      *         when COB-SCR-OK 
      *             move 1 to l-return-code 

               when COB-SCR-ESC
                   move 9 to l-return-code
                   display space blank screen 
                   goback 

           end-evaluate

           if l-item-list-name not = spaces and l-item-list-id > zero 
           then 

           *>There is a weird bug where if the name has a "?" the data
           *>gets corrupted.

           *> Input sanitization...
               if l-item-list-color > 7 then 
                   move 7 to l-item-list-color
               end-if 
               
               move function upper-case(l-item-list-highlight-sw)
                   to l-item-list-highlight-sw

               move function upper-case(l-item-list-blink-sw)
                   to l-item-list-blink-sw
               
               if 'Y' not = l-item-list-highlight-sw then 
                   move 'N' to l-item-list-highlight-sw
               end-if
               
               if 'Y' not = l-item-list-blink-sw then 
                   move 'N' to l-item-list-blink-sw
               end-if 

               move 0 to l-return-code 
           else 
               move 1 to l-return-code 
           end-if 

           display space blank screen 
           goback.


       end program add-edit-item.
