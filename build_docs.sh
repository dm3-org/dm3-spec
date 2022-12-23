#!/bin/bash
cp -r ./docs ./_temp
cd _temp

#fix_mermaid.sh

make html
make singlehtml
#make latexpdf
#make epub

cd ..
rm -R _temp
