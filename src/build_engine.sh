#!/bin/bash 

if [[ $1 == "clean" ]]
then
    echo Cleaning CRL Engine project...
    rm -v ./crl_engine
    exit 
fi 

echo Building CRL Engine...
cobc -Wall -x ./engine/crl_engine.cbl 

echo Done 