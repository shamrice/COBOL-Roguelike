      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-11
      *> Last Updated: 2021-05-18
      *> Purpose: Shared copy book with file descriptor definition of
      *>          item list data file.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_item_creator.sh
      *>****************************************************************

       fd  fd-item-list-data.
       01  f-item-list-data-record.
           05  f-item-id              pic 999.
           05  f-item-name            pic x(16).
           05  f-item-effect-id       pic 99.
           05  f-item-worth           pic 999.
           05  f-item-color           pic 9. 
           05  f-item-char            pic x.
           05  f-item-highlight       pic a.
           05  f-item-blink           pic a.
               
