      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-07
      *> Last Updated: 2021-06-02
      *> Purpose: Shared copy book with linkage section definition of
      *>          action history data record and related variables.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_engine.sh
      *>****************************************************************

       01  l-action-history.
           05  l-action-history-item     occurs 10 times.
               10  l-action-history-text pic x(75).

