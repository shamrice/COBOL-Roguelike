      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-07
      *> Last Updated: 2021-06-02
      *> Purpose: Shared copy book with working storage definition of
      *>          action history data record and related variables.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_engine.sh
      *>****************************************************************

       01  ws-action-history.
           05  ws-action-history-item      occurs 10 times.
               10  ws-action-history-text  pic x(75).

       01  ws-action-history-temp          pic x(75).      
       