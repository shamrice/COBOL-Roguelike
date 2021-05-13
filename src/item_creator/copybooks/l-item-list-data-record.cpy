      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-13
      *> Last Updated: 2021-05-13
      *> Purpose: Shared copy book with linkage section definition of
      *>          item list data record.
      *> Tectonics:
      *>     ./build_item_creator.sh 
      *>****************************************************************

       01  l-item-list-data-record.               
           10  l-item-list-id                 pic 9(6).
           10  l-item-list-name               pic x(16).                                          
           10  l-item-list-effect-id          pic 99.
           10  l-item-list-worth              pic 999.
           10  l-item-list-color              pic 9. 
           10  l-item-list-char               pic x.
           10  l-item-list-highlight-sw       pic a value 'N'.
               88  l-item-list-is-highlight   value 'Y'.
               88  l-item-lsit-not-highlight  value 'N'.
           10  l-item-list-blink-sw           pic a value 'N'.    
                88  l-item-list-is-blink       value 'Y'.
                88  l-item-list-not-blink      value 'N'.   
