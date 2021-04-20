#!/bin/bash

if [[ $1 == "clean" ]]
then
    echo Cleaning CRL Editor project...
    rm -v ./crl_editor
    exit 
fi 

echo Building CRL Editor...

cobc -Wall -x ./editor/crl_editor.cbl ./editor/draw_dynamic_screen_data.cbl ./shared/draw_tile_character.cbl ./editor/setup-tile-effect.cbl ./editor/set-tile-effect.cbl

echo Done.
