#!/bin/sh

ADDR=$(( $1 + 0 ))
AMAX=$(( ${2:-$1} + 0 ))

for a in `seq $ADDR 4 $AMAX`; do
    [ $(( a % 0x40 )) -eq 0 ] && \
	printf "\n%08X: " $a

    m=`devmem $a`
    printf "%8X " $m
done
printf "\n"
