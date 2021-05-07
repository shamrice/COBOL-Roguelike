      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-07
      *> Last Updated: 2021-05-07
      *> Purpose: Shared copy book with linkage section definition of
      *>          map explored data record and related variables.
      *> Tectonics:      
      *>     ./build_engine.sh
      *>****************************************************************

       01  l-map-explored-data.
           05  l-map-explored-y         occurs ws-max-map-height times.
               10  l-map-explored-x     occurs ws-max-map-width times.
                   15  l-map-explored        pic a value 'N'.
                       88  l-is-explored     value 'Y'.
                       88  l-is-not-explored value 'N'.
                             