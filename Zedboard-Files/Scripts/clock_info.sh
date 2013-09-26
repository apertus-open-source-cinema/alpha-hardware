#!/bin/sh

cnt_0=$(( `devmem 0x60000000` + 0 ))
cnt_1=$(( `devmem 0x60000004` + 0 ))
cnt_2=$(( `devmem 0x60000008` + 0 ))
cnt_3=$(( `devmem 0x6000000C` + 0 ))

int_0=$(( 1000000000 / ( `devmem 0x60000010` - 1 ) ))
int_1=$(( 1000000000 / ( `devmem 0x60000014` - 1 ) ))
int_2=$(( 1000000000 / ( `devmem 0x60000018` - 1 ) ))
int_3=$(( 1000000000 / ( `devmem 0x6000001C` - 1 ) ))

fmt_mhz() {
    mhz=$(( $1 / 10000 ))
    rmd=$(( $1 % 10000 ))
    printf "%3d.%04d MHz" $mhz $rmd
}

printf "fclk[0]\t%s\t%s\n" "`fmt_mhz $cnt_0`" "`fmt_mhz $int_0`"
printf "fclk[1]\t%s\t%s\n" "`fmt_mhz $cnt_1`" "`fmt_mhz $int_1`"
printf "fclk[2]\t%s\t%s\n" "`fmt_mhz $cnt_2`" "`fmt_mhz $int_2`"
printf "fclk[3]\t%s\t%s\n" "`fmt_mhz $cnt_3`" "`fmt_mhz $int_3`"



