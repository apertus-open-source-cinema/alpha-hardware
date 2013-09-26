#!/bin/sh

. ./i2c.func

EDID=$(( `i2c_get 0x39 0x43` >> 1 ))
PAGE=0

while true; do
    i2c_set 0x39 0xC4 $PAGE

    
    
    
