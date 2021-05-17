#!/bin/bash

echo ------------------------------------------------------
echo  COBOL Roguelike Main Build Script
echo  By: Erik Eriksen 
echo  https://github.com/shamrice/COBOL-Roguelike
echo ------------------------------------------------------
echo 
echo Calling all project build scripts...
echo 

./build_item_creator.sh
./build_editor.sh
./build_engine.sh


