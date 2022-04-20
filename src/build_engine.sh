#!/bin/bash 

echo ------------------------------------------------------
echo  COBOL Roguelike Engine Build Script
echo  By: Erik Eriksen 
echo  https://github.com/shamrice/COBOL-Roguelike
echo ------------------------------------------------------
echo 

CUR_BUILD_DATE_VALUE=$(date +%Y-%m-%d)
CUR_BUILD_DATE="Build Date: $CUR_BUILD_DATE_VALUE"
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
        echo Cleaning CRL Engine project...
        rm -v ./bin/crl_engine
    else 
        echo No bin directory to clean. Nothing to do.
    fi     

else 
    if [[ $BIN_EXISTS == false ]] 
    then 
        echo Creating ./bin directory...
        mkdir ./bin 
    fi 

    echo Building CRL Engine...
    sed -i "s/__BUILD_DATE__/$CUR_BUILD_DATE/" ./engine/command_line_parser.cbl 
    cobc -Wall -x -O2 -fstatic-call -o ./bin/crl_engine ./engine/crl_engine.cbl ./shared/draw_tile_character.cbl ./engine/draw_dynamic_screen_data.cbl ./shared/load_map_data.cbl ./engine/display_action_history.cbl ./engine/add_action_history_item.cbl ./engine/set_map_exploration.cbl ./engine/tile_effect_handler.cbl ./engine/display_debug.cbl ./engine/command_line_parser.cbl
    sed -i "s/$CUR_BUILD_DATE/__BUILD_DATE__/" ./engine/command_line_parser.cbl 
fi 
echo 
echo WARNING: This build script is deprecated. Please use \'make\' instead.
echo 
echo Done.