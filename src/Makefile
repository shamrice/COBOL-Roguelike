# Last updated: 2022-04-20

CBL=cobc
CBLFLAGS=-Wall -O2 -fstatic-call # -lncurses
CBL_DEBUG_FLAG=--debug 

CRL_EDITOR_MAIN=./editor/crl_editor.cbl
CRL_EDITOR_SOURCES=$(shell find ./editor -type f -name '*.cbl'  | grep -v '${CRL_EDITOR_MAIN}')

CRL_ENGINE_MAIN=./engine/crl_engine.cbl
CRL_ENGINE_SOURCES=$(shell find ./engine -type f -name '*.cbl'  | grep -v '${CRL_ENGINE_MAIN}')

CRL_ITEM_CREATOR_MAIN=./item_creator/crl_item_creator.cbl
CRL_ITEM_CREATOR_SOURCES=$(shell find ./item_creator -type f -name '*.cbl'  | grep -v '${CRL_ITEM_CREATOR_MAIN}')

CRL_SHARED_SOURCES=$(shell find ./shared -type f -name '*.cbl')


all: build	

build: crl_engine crl_editor crl_item_creator
	@echo 
	@echo Done building. Compiled sources can be found in the ../bin directory.
	@echo 

clean:
	rm -rfv ../bin
	@echo 
	@echo "Done cleaning project."
	@echo 

crl_engine: ${CRL_ENGINE_MAIN} ${CRL_ENGINE_SOURCES} ${CRL_SHARED_SOURCES}
	@echo 
	@echo Building CRL Engine... 
	mkdir -p -v ../bin
	${CBL} ${CBLFLAGS} ${CBL_DEBUG_FLAG} -x -o ../bin/$@ $^


crl_editor: ${CRL_EDITOR_MAIN} ${CRL_EDITOR_SOURCES} ${CRL_SHARED_SOURCES}
	@echo 
	@echo Building CRL Editor... 
	mkdir -p -v ../bin
	${CBL} ${CBLFLAGS} ${CBL_DEBUG_FLAG} -x -o ../bin/$@ $^


crl_item_creator: ${CRL_ITEM_CREATOR_MAIN} ${CRL_ITEM_CREATOR_SOURCES} ${CRL_SHARED_SOURCES}
	@echo 
	@echo Building CRL Item Creator...
	mkdir -p -v ../bin
	${CBL} ${CBLFLAGS} ${CBL_DEBUG_FLAG} -x -o ../bin/$@ $^





 