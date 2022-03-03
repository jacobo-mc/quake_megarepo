#!/bin/bash

echo "Type the name of the map you would like to compile without extensions:"

read map

echo "-----------QBSP-----------"
qbsp $map.map $map.bsp
echo "-----------LIGHT-----------"
light -extra4 -dirt -dirtdebug -dirtdepth 128 $map.bsp
echo "-----------VIS-----------"
vis $map.bsp

echo "Done!"
