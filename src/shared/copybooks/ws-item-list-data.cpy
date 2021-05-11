      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-11
      *> Last Updated: 2021-05-11
      *> Purpose: Shared copy book with working storage definition of
      *>          item list data record and related variables.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_item_creator.sh
      *>****************************************************************

       01  ws-item-list-data.
           05  ws-cur-num-list-items       pic 999.
           05  ws-item-list-data-record    occurs 0 to 999 depending 
                                           on ws-cur-num-list-items.
               
               10  ws-item-list-id         pic 9(6).
               10  ws-item-list-name       pic x(16).                                          
               10  ws-item-list-effect-id  pic 99.
               10  ws-item-list-worth      pic 999.
               10  ws-item-list-color      pic 9. 
               10  ws-item-list-char       pic x.
               