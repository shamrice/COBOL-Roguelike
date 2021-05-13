#!/bin/bash

echo ------------------------------------------------------
echo  COBOL Roguelike Item Creator Build Script
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
        echo Cleaning CRL Item Creator project...
        rm -v ./bin/crl_item_creator
    else 
        echo No bin directory to clean. Nothing to do.
    fi 

else 
    if [[ $BIN_EXISTS == false ]] 
    then 
        echo Creating ./bin directory...
        mkdir ./bin 
    fi 

    echo Building CRL Item Creator...
    cobc -Wall -x -O2 -o ./bin/crl_item_creator ./item_creator/crl_item_creator.cbl  ./item_creator/add_edit_item.cbl 
    
fi 
echo Done.

