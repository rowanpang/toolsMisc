#!/usr/bin/bash
buildDir=`mktemp --directory /tmp/ycm-build-XXXXXX`

cd $buildDir

cmake -G "Unix Makefiles" -DUSE_SYSTEM_LIBCLANG=ON . ~/.vim/plugged/youcompleteme/third_party/ycmd/cpp
make -j 4 ycm_core

cd -
rm -rf $buildDir
