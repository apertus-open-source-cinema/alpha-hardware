#!/bin/sh

cnt_0=$(( `devmem 0x60000000` + 0 ))
cnt_1=$(( `devmem 0x60000004` + 0 ))
cnt_2=$(( `devmem 0x60000008` + 0 ))
cnt_3=$(( `devmem 0x6000000C` + 0 ))
cnt_4=$(( `devmem 0x60000010` + 0 ))
cnt_5=$(( `devmem 0x60000014` + 0 ))

int_0=$(( 1000000000 / ( `devmem 0x60000020` - 1 ) ))
int_1=$(( 1000000000 / ( `devmem 0x60000024` - 1 ) ))
int_2=$(( 1000000000 / ( `devmem 0x60000028` - 1 ) ))
int_3=$(( 1000000000 / ( `devmem 0x6000002C` - 1 ) ))
int_4=$(( 1000000000 / ( `devmem 0x60000030` - 1 ) ))
int_5=$(( 1000000000 / ( `devmem 0x60000034` - 1 ) ))

fmt_mhz() {
    mhz=$(( $1 / 10000 ))
    rmd=$(( $1 % 10000 ))
    printf "%3d.%04d MHz" $mhz $rmd
}

printf "pll_clk[0]\t%s\t%s\n" "`fmt_mhz $cnt_0`" "`fmt_mhz $int_0`"
printf "pll_clk[1]\t%s\t%s\n" "`fmt_mhz $cnt_1`" "`fmt_mhz $int_1`"
printf "pll_clk[2]\t%s\t%s\n" "`fmt_mhz $cnt_2`" "`fmt_mhz $int_2`"
printf "pll_clk[3]\t%s\t%s\n" "`fmt_mhz $cnt_3`" "`fmt_mhz $int_3`"
printf "pll_clk[4]\t%s\t%s\n" "`fmt_mhz $cnt_4`" "`fmt_mhz $int_4`"
printf "pll_clk[5]\t%s\t%s\n" "`fmt_mhz $cnt_5`" "`fmt_mhz $int_5`"


