      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-07-18
      *> Last Updated: 2021-07-21
      *> Purpose: Module for engine to parse the command line parameters
      *>          and set values as needed.
      *> Tectonics:
      *>     ./build_engine.sh
      *>*****************************************************************
       identification division.
       program-id. command-line-parser.

       environment division.

       data division.

       working-storage section.
       
       78  ws-log-param                  value "--LOG=".
       78  ws-map-param                  value "--MAP=".
       78  ws-map-short-param            value "-M=".
       78  ws-help-param                 value "--HELP".
       78  ws-help-short-param           value "-H".   

       78  ws-enabled-str                value "ENABLED".    

       78  ws-new-line                   value x"0a".


       local-storage section.
       
       01  ls-found-param-counts.
           05  ls-log-param-count        pic 9.
           05  ls-map-param-count        pic 9.
           05  ls-help-param-count       pic 9.

       01  ls-param-count                pic 9 comp.      

       01  ls-key-val-pair.
           05  ls-key                    pic x(16).
           05  ls-value                  pic x(32).
            
       01  ls-parameter                  pic x(1024).    

       01  ls-param-idx                  pic 9 comp value 1. 
       01  ls-param-pointer              pic 9(5) comp value 1.       

       linkage section.

       01  l-command-args                pic x any length.
       01  l-map-name                    pic x(15).
       01  l-map-name-temp               pic x(15).



       procedure division using 
           l-command-args l-map-name l-map-name-temp.

       main-procedure.

           inspect function trim(l-command-args) tallying 
               ls-param-count for all "--", "-"          


           if ls-param-count = 0 then 
               goback
           end-if 

           perform varying ls-param-idx 
           from 1 by 1 until ls-param-idx > ls-param-count
           
               unstring l-command-args delimited by all spaces
                   into ls-parameter
                   with pointer ls-param-pointer     

      *    TODO : overflow gets triggered on success, needs additional
      *           investigation as to why.
      *       
      *             on overflow
      *                 display 
      *                     "Error parsing command line args: " 
      *                     function trim(l-command-args)
      *                 end-display 
      *                 display
      *                     " idx: " ls-param-idx " cnt: " ls-param-count
      *                     " pointer: " ls-param-pointer 
      *                 end-display 
      *                 display "param-val=" ls-parameter
      *                 stop run 
      *             not on overflow
      *                 display "Parsed command line successfully."
               end-unstring
               
               *> DEBUG
      *         display
      *             " idx: " ls-param-idx " cnt: " ls-param-count
      *             " pointer: " ls-param-pointer 
      *         end-display                              
      *         display "param-val=" function trim(ls-parameter)

               move zeros to ls-found-param-counts               

               inspect function upper-case(ls-parameter) tallying 
                   ls-log-param-count 
                       for all ws-log-param
                   ls-map-param-count 
                       for all ws-map-param, ws-map-short-param
                   ls-help-param-count 
                       for all ws-help-param, ws-help-short-param


               if ls-help-param-count > 0 then 
                   perform display-help-and-quit
               end-if 

               if ls-log-param-count > 0 then 
                   perform process-key-val-pair
                   if ls-value not = spaces 
                   and ls-value = ws-enabled-str then 
                       call "action-history-log-start"
                   end-if 
               end-if 

               if ls-map-param-count > 0 then                
                   perform process-key-val-pair

                   if ls-value not = spaces then 
                       move ls-value to l-map-name
                       move l-map-name to l-map-name-temp
                   else 
                       display "ERROR: Unable to parse map name."
                       stop run 
                   end-if 
               end-if 

               if ls-found-param-counts = zeros then 
                   display space 
                   display 
                       "ERROR: Invalid command line argument: " 
                       function trim(ls-parameter)
                   end-display                      
                   perform display-help-and-quit                                        
               end-if

           end-perform          
                      
           goback.


       process-key-val-pair.
           move spaces to ls-key
           move spaces to ls-value 
           
           unstring function upper-case(ls-parameter) 
               delimited by "=" into ls-key, ls-value                   
           end-unstring

           exit paragraph.

       display-help-and-quit.           

           display space
           display            
           "COBOL Roguelike" ws-new-line 
           "-------------------------------" ws-new-line 
           "By: Erik Eriksen" ws-new-line 
           "Web: https://github.com/shamrice/COBOL-Roguelike" 
               ws-new-line 
           "__BUILD_DATE__" ws-new-line ws-new-line 
           "Command line parameters:" ws-new-line 
           " -h                     Display this help message."
                ws-new-line 
           "--help                  Display this help message."
                ws-new-line 
           "--log=enabled/disabled  Toggle logging (Default: disabled)" 
                ws-new-line 
           " -m=MAP_NAME            Load specified map."
                ws-new-line 
           "--map=MAP_NAME          Load specified map."
                ws-new-line  ws-new-line 
           end-display 
           
      *> In case other param set logging to true before help was called.     
           call "action-history-log-end"
               
           stop run. 

       end program command-line-parser.
