      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-23
      *> Last Updated: 2021-05-03
      *> Purpose: Module for engine to load the level data passed into
      *>          the related record structures.
      *> Tectonics:
      *>     ./build_engine.sh or ./build_editor.sh
      *>*****************************************************************
       identification division.
       program-id. load-map-data.

       environment division.

       input-output section.

       file-control.
           select optional fd-tile-data 
               assign to dynamic l-map-dat-file 
               organization is record sequential
               file status is ls-map-file-status.

           select optional fd-teleport-data
               assign to dynamic l-map-tel-file
               organization is record sequential
               file status is ls-teleport-file-status.            

           select optional fd-enemy-data
               assign to dynamic l-map-enemy-file
               organization is record sequential
               file status is ls-enemy-file-status.


       data division.

       file section.

           fd  fd-tile-data.
           01  f-tile-data-record.
               05  f-tile-fg               pic 9.   
               05  f-tile-bg               pic 9.
               05  f-tile-char             pic x.
               05  f-tile-highlight        pic a.
               05  f-tile-blocking         pic a.
               05  f-tile-blinking         pic a.
               05  f-tile-effect-id        pic 99.


       fd  fd-teleport-data.
           01  f-teleport-data-record.
               05  f-teleport-pos.
                   10  f-teleport-y        pic S99.
                   10  f-teleport-x        pic S99.
               05  f-teleport-dest-pos.
                   10  f-teleport-dest-y   pic S99.
                   10  f-teleport-dest-x   pic S99.
               05  f-teleport-dest-map     pic x(15).

           fd  fd-enemy-data.           
           01  f-enemy.
               05  f-enemy-name                 pic x(16).
               05  f-enemy-hp.
                   10  f-enemy-hp-total         pic 999.
                   10  f-enemy-hp-current       pic 999.
               05  f-enemy-attack-damage        pic 999.
               05  f-enemy-pos.
                   10  f-enemy-y                pic 99.
                   10  f-enemy-x                pic 99.
               05  f-enemy-color                pic 9. 
               05  f-enemy-char                 pic x. 
               05  f-enemy-status               pic 9.
               05  f-enemy-movement-ticks.
                   10  f-enemy-current-ticks    pic 999.
                   10  f-enemy-max-ticks        pic 999.
               10  l-cursor-enemy-exp-worth     pic 9(4).                    


       working-storage section.


           78  ws-file-status-ok           value "00".
           78  ws-file-status-eof          value "10".

           78  ws-data-file-ext            value ".DAT".
           78  ws-teleport-file-ext        value ".TEL".
           78  ws-enemy-file-ext           value ".BGS".

           78  ws-max-map-height              value 25.
           78  ws-max-map-width               value 80.
           78  ws-max-num-enemies             value 99.
           78  ws-max-num-teleports           value 999.           

           78  ws-load-status-fail        value 9.
           78  ws-load-status-read-fail   value 8.
           78  ws-load-status-bad-data    value 7.
           78  ws-load-status-success     value 0.

       local-storage section.

           01  ls-counter-1                 pic 999.
           01  ls-counter-2                 pic 999.           

           01  ls-map-file-statuses.
               05  ls-map-file-status      pic xx.
               05  ls-teleport-file-status pic xx.
               05  ls-enemy-file-status    pic xx.

           01  ls-eof-sw                    pic a value 'N'.
               88 ls-is-eof                 value 'Y'.
               88 ls-not-eof                value 'N'.
                     
       linkage section.

           01  l-map-files.  
               05  l-map-name             pic x(15) value "WORLD0".
               05  l-map-name-temp        pic x(15) value "WORLD0".           
               05  l-map-dat-file         pic x(15).               
               05  l-map-tel-file         pic x(15).
               05  l-map-enemy-file       pic x(15).   


       *> TODO : Copy book!!
           01  l-tile-map-table-matrix.
               05  l-tile-map           occurs ws-max-map-height times.
                   10  l-tile-map-data  occurs ws-max-map-width times.
                       15  l-tile-fg                   pic 9.   
                       15  l-tile-bg                   pic 9.
                       15  l-tile-char                 pic x.
                       15  l-tile-highlight            pic a value 'N'.
                           88 l-tile-is-highlight      value 'Y'.
                           88 l-tile-not-highlight     value 'N'.
                       15  l-tile-blocking             pic a value 'N'.
                           88  l-tile-is-blocking      value 'Y'.
                           88  l-tile-not-blocking     value 'N'.  
                       15  l-tile-blinking             pic a value 'N'.
                           88  l-tile-is-blinking      value 'Y'.
                           88  l-tile-not-blinking     value 'N'.
                       15  l-tile-effect-id            pic 99.       


           01  l-enemy-data.
               05  l-cur-num-enemies           pic 99.
               05  l-enemy       occurs 0 to unbounded times
                                  depending on l-cur-num-enemies.
                   10  l-enemy-name            pic x(16).
                   10  l-enemy-hp.
                       15  l-enemy-hp-total    pic 999 value 10.
                       15  l-enemy-hp-current  pic 999 value 10.
                   10  l-enemy-attack-damage   pic 999 value 1.
                   10  l-enemy-pos.
                       15  l-enemy-y           pic 99.
                       15  l-enemy-x           pic 99.
                   10  l-enemy-color           pic 9 value 4.                                     
      *>TODO: this isn't configurable once enemy is hit.
                   10  l-enemy-char            pic x value "&". 
                       88  l-enemy-char-alive  value "&".
                       88  l-enemy-char-dead   value "X".
                       88  l-enemy-char-hurt   value "#".
                   10  l-enemy-status              pic 9 value 0.
                       88  l-enemy-status-alive    value 0.
                       88  l-enemy-status-dead     value 1.
                       88  l-enemy-status-attacked value 2.
                       88  l-enemy-status-other    value 3.
                   10  l-enemy-movement-ticks.
                       15  l-enemy-current-ticks   pic 999.
                       15  l-enemy-max-ticks       pic 999 value 3. 
                   10  l-enemy-exp-worth           pic 9(4).                                  

           01  l-teleport-data.
               05  l-cur-num-teleports        pic 999.
               05  l-teleport-data-record     occurs 0 
                                               to ws-max-num-teleports
                                      depending on l-cur-num-teleports.
                   10  l-teleport-pos.
                       15  l-teleport-y        pic S99.
                       15  l-teleport-x        pic S99.
                   10  l-teleport-dest-pos.
                       15  l-teleport-dest-y   pic S99.
                       15  l-teleport-dest-x   pic S99.
                   10  l-teleport-dest-map     pic x(15).

           01  l-return-code                   pic 9 value 0.

       procedure division using 
               l-map-files l-tile-map-table-matrix 
               l-enemy-data l-teleport-data
               l-return-code.

       main-procedure.


      *> Set file names based on map name
           move function concatenate(
               function trim(l-map-name), ws-data-file-ext)
               to l-map-dat-file

           move function concatenate(
               function trim(l-map-name), ws-teleport-file-ext)
               to l-map-tel-file

           move function concatenate(
               function trim(l-map-name), ws-enemy-file-ext)
               to l-map-enemy-file               

      *> Load data from files.

           open input fd-tile-data

           if ls-map-file-status not = ws-file-status-ok then
               close fd-tile-data  
               display 
                   "Failed to open tile data: " at 0101
                   l-map-dat-file at 0130
               end-display 
               move ws-load-status-fail to l-return-code
               goback                
           end-if     
                     
           
           perform varying ls-counter-1 
           from 1 by 1 until ls-counter-1 > ws-max-map-height
               perform varying ls-counter-2 
               from 1 by 1 until ls-counter-2 > ws-max-map-width

                   read fd-tile-data 
                       into l-tile-map-data(ls-counter-1, ls-counter-2)
                   end-read 
                   if ls-map-file-status not = ws-file-status-ok then 
                       display "Error reading tile map data." at 0101
                       display ls-map-file-status at 0201
                       close fd-tile-data
                       
                       move ws-load-status-read-fail 
                           to l-return-code
                       goback 
                   end-if 
               end-perform
           end-perform
           close fd-tile-data
 
      *> Reset and load enemy file info.
           move 0 to l-cur-num-enemies
           set ls-not-eof to true             

           open input fd-enemy-data      
               perform until ls-is-eof 
                   add 1 to l-cur-num-enemies        
                   if l-cur-num-enemies < ws-max-num-enemies then  

                       initialize l-enemy(l-cur-num-enemies)  
      *                 initialize l-enemy-draw-pos(l-cur-num-enemies)

                       read fd-enemy-data 
                           into l-enemy(l-cur-num-enemies)    
                           at end set ls-is-eof to true 
                       end-read

                       if ls-enemy-file-status not = 
                       ws-file-status-ok and ls-enemy-file-status not = 
                       ws-file-status-eof then 
                           display "Error reading enemy data." at 0101
                           display ls-enemy-file-status at 0201
                           close fd-enemy-data
                           
                           move ws-load-status-read-fail 
                               to l-return-code
                           goback 
                       end-if  

                   else 
                       set ls-is-eof to true 
                   end-if 
   
               end-perform 
           close fd-enemy-data


      *> Reset and load teleport file info.
           move 0 to l-cur-num-teleports
           set ls-not-eof to true             

           open input fd-teleport-data      
               perform until ls-is-eof 
                   add 1 to l-cur-num-teleports        
                   if l-cur-num-teleports < ws-max-num-teleports then  

                       initialize 
                           l-teleport-data-record(l-cur-num-teleports)  
                                              
                       read fd-teleport-data 
                           into l-teleport-data-record(
                               l-cur-num-teleports)
                           at end set ls-is-eof to true 
                       end-read

                       if ls-teleport-file-status not = 
                       ws-file-status-ok and ls-teleport-file-status 
                       not = ws-file-status-eof then 
                           display "Error reading tele data." at 0101
                           display ls-teleport-file-status at 0201
                           close fd-teleport-data
                           
                           move ws-load-status-read-fail 
                               to l-return-code
                           goback 
                       end-if  

                   else 
                       set ls-is-eof to true 
                   end-if                    
               end-perform 
           close fd-teleport-data

           move ws-load-status-success to l-return-code               
           goback.

       end program load-map-data.
