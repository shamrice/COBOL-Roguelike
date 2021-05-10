      *>****************************************************************
      *> Author: Erik Eriksen
      *> Create Date: 2021-05-10
      *> Last Updated: 2021-05-10
      *> Purpose: Shared copy book with linkage section definition of
      *>          equiped items data record and related variables.
      *> Tectonics:
      *>     ./build_engine.sh
      *>****************************************************************

       01  l-equiped-items.
           05  l-equiped-weapon.
               10  l-equip-weapon-name        pic x(16).
               10  l-equip-weapon-atk         pic 999.
               10  l-equip-weapon-status      pic x.
                   88  l-equip-weapon-curse   value "-".
                   88  l-equip-weapon-normal  value "0".
                   88  l-equip-weapon-bless   value "+".                        
           05  l-equiped-armor.
               10  l-equip-armor-name         pic x(16).
               10  l-equip-armor-def          pic 999.
               10  l-equip-armor-status       pic x.
                   88  l-equip-armor-curse    value "-".
                   88  l-equip-armor-normal   value "0".
                   88  l-equip-armor-bless    value "+".      
