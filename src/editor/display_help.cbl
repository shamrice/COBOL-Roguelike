      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-17
      *> Last Updated: 2021-05-28
      *> Purpose: Displays the editor help screen
      *> Tectonics:
      *>     ./build_editor.sh
      *>*****************************************************************
       identification division.
       program-id. display-help.

       environment division.

       configuration section.

       input-output section.

       file-control.
  
       data division.

       file section.

       working-storage section.      

  
       procedure division.
       main-procedure.

           display space blank screen 

           display "Keyboard Commands:" at 0107 underline highlight           
           display 
               " arrows - move cursor" at 0201
               "      b - toggle blocking tiles" at 0301
               "      c - set tile character" at 0401
               "      d - set enemy attributes" at 0501
               "    f/g - set fore/background tile color" at 0601
               "      h - toggle fg tile highlight" at 0701
               "      k - toggle blinking tiles" at 0801
               "  esc/q - quit editor" at 0901
               "  space - place tile or enemy" at 1001
               "    tab - toggle tile/enemy placement mode" at 1101
               "     F1 - display this help screen." at 1201
               "   o/F2 - save map data" at 1301               
               "   l/F3 - load map data" at 1401               
               "     F6 - toggle tile effect view on/off." at 1501
           end-display 

           display "Press [enter] for next page." at 1901
           accept omitted at 1950

           display space blank screen 

           display "Mouse Commands" at 0107 underline highlight 
           display 
               "left click - place tile/enemy at mouse cursor position."
               at 0207
               "hold left click - continuous tile/enemy draw at cursor."
               at 0302
           end-display 

           display "Press [enter] to return to editor." at 1901
           accept omitted at 1950
           display space blank screen

           goback.


       end program display-help.
