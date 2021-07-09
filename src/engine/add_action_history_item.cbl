      *>*****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-04-25
      *> Last Updated: 2021-07-09
      *> Purpose: Module for engine to add action history text to action 
      *>          history items. Oldest entries will be bumped off list.
      *> Tectonics:
      *>     ./build_engine.sh
      *>*****************************************************************
       identification division.
       program-id. add-action-history-item.

       environment division.

       input-output section.

       file-control.

           select optional fd-action-history-log
           assign to dynamic ws-ah-log-file-name
           organization is line sequential
           file status is ws-ah-file-status.

       data division.

       file section.

       fd  fd-action-history-log.
       01  f-ah-log-entry.
           05  f-ah-log-timestamp             pic x(23).
           05  f-ah-log-text                  pic x(80).


       working-storage section.
       
       01  ws-ah-log-file-name           pic x(16) value "DEFAULT.LOG".

       01  ws-ah-file-status             pic xx.

       78  ws-max-entries               value 150.                      

       01  ws-counter                    pic 999 comp.

       01  ws-current-idx                pic 999 comp value 1.

       01  ws-logging-enabled-sw         pic a value 'N'.
           88  ws-logging-enabled        value 'Y'.
           88  ws-logging-disabled       value 'N'.

       01 ws-current-date-data.
           05  ws-current-date.
               10  ws-current-year         pic 9(4).               
               10  ws-current-month        pic 9(2).
               10  ws-current-day          pic 9(2).
           05  ws-current-time.
               10  ws-current-hour         pic 9(2).
               10  ws-current-minute       pic 9(2).
               10  ws-current-second       pic 9(2).
               10  ws-current-millisecond  pic 9(2).

       78  ws-file-success                 value "00".
       78  ws-file-missing-optional        value "05".

       linkage section.

       01  l-new-history-text            pic x(75).

       copy "engine/copybooks/l-action-history.cpy".

       procedure division using 
               l-new-history-text l-action-history.

       main-procedure.

           if ws-current-idx < ws-max-entries then 
               move l-new-history-text to 
                   l-action-history-text(ws-current-idx) 
               add 1 to ws-current-idx

           else 
               perform varying ws-counter 
               from 1 by 1 until ws-counter = ws-max-entries 
                   move l-action-history-item(ws-counter + 1) to 
                       l-action-history-item(ws-counter) 
               end-perform 
               
               move l-new-history-text to 
                   l-action-history-text(ws-current-idx)      
           end-if 

           if ws-logging-enabled then 
               perform log-entry           
           end-if 
               
           goback.


       log-entry.
           move function current-date to ws-current-date-data           

           move function concatenate(ws-current-year, '-', 
               ws-current-month, '-', ws-current-day, 'T', 
               ws-current-hour, ':', ws-current-minute, ':', 
               ws-current-second, '.', ws-current-millisecond)
               to f-ah-log-timestamp

           move l-new-history-text to f-ah-log-text

           write f-ah-log-entry

           exit paragraph.


       start-history-loggging.
           entry "action-history-log-start"           

           move function current-date to ws-current-date-data
           move function concatenate(ws-current-date, "-CRL.LOG")
               to ws-ah-log-file-name

           open extend fd-action-history-log 

           if ws-ah-file-status = ws-file-success 
               or ws-file-missing-optional then 
               set ws-logging-enabled to true                
           end-if 

           goback. 

       
       end-history-logging.
           entry "action-history-log-end"

           if ws-logging-enabled then 
               set ws-logging-disabled to true 
               close fd-action-history-log
           end-if 

           goback.

       end program add-action-history-item.
