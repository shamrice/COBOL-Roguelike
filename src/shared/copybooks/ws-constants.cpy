      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-07
      *> Last Updated: 2021-05-08
      *> Purpose: Shared copy book with working storage definition of
      *>          variable constants.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>     ./build_game.sh
      *>****************************************************************

      *> Color constants:    
       01  black                          constant as 0.
       01  blue                           constant as 1.
       01  green                          constant as 2.
       01  cyan                           constant as 3.
       01  red                            constant as 4.
       01  magenta                        constant as 5.
       01  yellow                         constant as 6.  
       01  white                          constant as 7.

      *> Tile effect ids           
       01  ws-teleport-effect-id          constant as 01.

       78  ws-load-map-return-code        value 1.

       78  ws-max-view-height             value 20.
       78  ws-max-view-width              value 50.
       
       78  ws-max-map-height              value 25.
       78  ws-max-map-width               value 80.

       78  ws-max-num-enemies             value 99.      

       78  ws-max-num-teleports           value 999.

       78  ws-file-status-ok              value "00".
       78  ws-file-status-eof             value "10".

       78  ws-load-status-fail        value 9.
       78  ws-load-status-read-fail   value 8.
       78  ws-load-status-bad-data    value 7.
       78  ws-load-status-success     value 0.       

       78  ws-data-file-ext               value ".DAT".
       78  ws-teleport-file-ext           value ".TEL".
       78  ws-enemy-file-ext              value ".BGS".       

