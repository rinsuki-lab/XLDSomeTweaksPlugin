#!/bin/bash
set -xe

mkdir -p third_party
cd third_party

# XLD
svn checkout -r 651 --depth files https://svn.code.sf.net/p/xld/code/trunk/XLD XLD

# licddb
rm -rf libcddb* cddb
wget -O libcddb.tar.bz2 http://prdownloads.sourceforge.net/libcddb/libcddb-1.3.0.tar.bz2
tar xf libcddb.tar.bz2
mv libcddb-1.3.0/include/cddb ./cddb
rm -rf libcddb*