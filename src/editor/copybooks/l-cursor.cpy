      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-07
      *> Last Updated: 2021-05-12
      *> Purpose: Shared copy book with linkage section definition of
      *>          cursor data record and related variables.
      *> Tectonics:
      *>     ./build_editor.sh 
      *>****************************************************************


       01  l-cursor.
           05  l-cursor-pos.
               10  l-cursor-pos-y         pic S99.
               10  l-cursor-pos-x         pic S99.
           05  l-cursor-pos-delta.               
               10  l-cursor-pos-delta-y   pic S99. 
               10  l-cursor-pos-delta-x   pic S99.
           05  l-cursor-scr-pos.  
               10  l-cursor-scr-y         pic 99 value 10.
               10  l-cursor-scr-x         pic 99 value 20.                      
           05  l-cursor-color             pic 9.
           05  l-cursor-draw-color-fg     pic 9.
           05  l-cursor-draw-color-bg     pic 9.
           05  l-cursor-draw-char         pic x value space.
           05  l-cursor-draw-highlight    pic a.
               88  l-cursor-highlight     value 'Y'.
               88  l-cursor-no-highlight  value 'N'.
           05  l-cursor-draw-blocking     pic a.
               88  l-cursor-blocking      value 'Y'.
               88  l-cursor-not-block     value 'N'.
           05  l-cursor-draw-blinking     pic a.
               88  l-cursor-blink         value 'Y'.
               88  l-cursor-not-blink     value 'N'. 
           05  l-cursor-draw-visibility   pic 999.
           05  l-cursor-enemy-settings.
               10  l-cursor-enemy-name            pic x(16).
               10  l-cursor-enemy-hp              pic 999.
               10  l-cursor-enemy-attack-damage   pic 999.
               10  l-cursor-enemy-color           pic 9.   
               10  l-cursor-enemy-char            pic x.
               10  l-cursor-enemy-movement-ticks  pic 999.    
               10  l-cursor-enemy-exp-worth       pic 9(4). 
           05  l-cursor-teleport-settings.
               10  l-cursor-tel-dest-y            pic 99.
               10  l-cursor-tel-dest-x            pic 99.
               10  l-cursor-tel-dest-map          pic x(15).                       
           05  l-cursor-draw-effect       pic 99.
           05  l-cursor-type              pic a.
               88  l-cursor-type-tile     value 'T'.
               88  l-cursor-type-enemy    value 'E'.                     
           78  l-cursor-char              value "+".

