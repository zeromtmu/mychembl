#!/bin/bash

export HOME=/home/chembl
export RDBASE=$HOME/rdkit
export LD_LIBRARY_PATH=$RDBASE/lib:$LD_LIBRARY_PATH
export PYTHONPATH=$RDBASE:$PYTHONPATH
[[ "$AUX_OS_NAME" = "Ubuntu" ]] && export PATH=$PATH || export PATH=$PATH:/usr/pgsql-9.3/bin/

cd $HOME
git clone $RDKIT_REPO
cd rdkit/
git checkout tags/$RDKIT_RELEASE
cd $RDBASE/External/INCHI-API
sed -i 's/sites\/default\/files\/inchi-1.04\/INCHI-1-API\.ZIP/wp\/wp-content\/uploads\/2014\/06\/INCHI-1-API\.zip/g' download-inchi.sh
bash download-inchi.sh

cd $RDBASE
mkdir build
cd build
cmake -DRDK_BUILD_INCHI_SUPPORT=ON -DBoost_USE_STATIC_LIBS=OFF ..
make -j4 install
ctest

cd $RDBASE/Code/PgSQL/rdkit
make
python -mplatform | grep Ubuntu && echo "chemblvm" | sudo -S make install || echo "chemblvm" | sudo -S PATH=$PATH:/usr/pgsql-9.3/bin/ make install
make installcheck
