#!/bin/bash

echo ------------------------------------------------------
echo  COBOL Roguelike Editor Build Script
echo  By: Erik Eriksen 
echo  https://github.com/shamrice/COBOL-Roguelike
echo ------------------------------------------------------
echo 

BIN_EXISTS=false
BIN_DIR=./bin

if [[ -e $BIN_DIR ]]
then 
    BIN_EXISTS=true
fi 

if [[ ! -d $BIN_DIR && $BIN_EXISTS == true ]]
then 
    echo Output directory bin is not a directory. Please either delete or rename this existing file and try again.
    exit 
fi 

if [[ $1 == "clean" ]]
then
    if [[ $BIN_EXISTS == true ]]
    then 
        echo Cleaning CRL Editor project...
        rm -v ./bin/crl_editor
    else 
        echo No bin directory to clean. Nothing to do.
    fi 

else 
    if [[ $BIN_EXISTS == false ]] 
    then 
        echo Creating ./bin directory...
        mkdir ./bin 
    fi 

    echo Building CRL Editor...
    cobc -Wall -x -O2 -o ./bin/crl_editor ./editor/crl_editor.cbl ./editor/draw_dynamic_screen_data.cbl ./shared/draw_tile_character.cbl ./shared/load_map_data.cbl ./editor/setup-tile-effect.cbl ./editor/set-tile-effect.cbl ./editor/write_map_data.cbl ./editor/display_help.cbl
    
fi 
echo Done.

