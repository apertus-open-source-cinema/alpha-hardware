#!/bin/sh

cmv_reg() {
    addr=$(( 0x60000000 + ($1 * 4) ))
    [ $# -gt 1 ] && devmem $addr 32 $2
    devmem $addr 32
}                                                                                                                                                                                                       

cmv_reg  69      2
cmv_reg  98  39705
cmv_reg 102   8312
cmv_reg 107   9814
cmv_reg 108  12381
cmv_reg 112      5
cmv_reg 124     15

cmv_reg 127

