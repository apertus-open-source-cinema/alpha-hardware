#!/bin/sh

. ./i2c.func

eeval() {
    pre=$1; shift
    val=`$@`
    nfo=`eval echo \$\{${pre}_${val}\}`
    echo $val $nfo
}




hdmi_mode_0="DVI"
hdmi_mode_1="HDMI"

printf "Mode:\t\t%s PowerDown=%d\n"	\
	"`eeval hdmi_mode i2c_mbv 0x39 0xAF 1`" \
	`i2c_mbv 0x39 0x41 6`

printf "Sense:\t\t%d IE=%d IRQ=%d PowerDown=%d\n"  \
	`i2c_mbv 0x39 0x42 5`		\
	`i2c_mbv 0x39 0x94 6`		\
	`i2c_mbv 0x39 0x96 6`		\
	`i2c_mbv 0x39 0xA1 6`

hpd_ctrl_0="from both HPD pin or CDC HPD"
hpd_ctrl_1="from CDC HPD"
hpd_ctrl_2="from HPD pin"
hpd_ctrl_3="always high"

printf "HPD:\t\t%d IE=%d IRQ=%d CTRL=%s\n"  \
	`i2c_mbv 0x39 0x42 6`		\
	`i2c_mbv 0x39 0x94 7`		\
	`i2c_mbv 0x39 0x96 7`		\
	"`eeval hpd_ctrl i2c_mbv 0x39 0xD6 6 7`"

printf "EDID:\t\t%d IE=%d IRQ=%d CNT=%d SEG=%02X\n"  \
	`i2c_mbv 0x39 0xC9 4`		\
	`i2c_mbv 0x39 0x94 2`		\
	`i2c_mbv 0x39 0x96 2`		\
	`i2c_mbv 0x39 0xC9 0 3`		\
	`i2c_get 0x39 0xC4`

printf "HDCP:\t\t%d IE=%d IRQ=%d Enc=%d KeyErr=%d\n"  \
	`i2c_mbv 0x39 0xAF 7`		\
	`i2c_mbv 0x39 0x94 1`		\
	`i2c_mbv 0x39 0x96 1`		\
	`i2c_mbv 0x39 0xB8 6`		\
	`i2c_mbv 0x39 0xB8 4`

printf "CDC:\t\t%d CNT=%d SIG=%d\n"  \
	`i2c_mbv 0x39 0x7F 6`		\
	`i2c_get 0x39 0x82`		\
	`i2c_mbv 0x39 0x83 7`

cec_mode_0="Power Down"
cec_mode_1="Always Active"
cec_mode_2="Depend on HPD"
cec_mode_3="Depend on HPD"

printf "CEC:\t\t%d Addr=%02X%02X Mode=%s\n"  \
	`i2c_mbv 0x39 0xE2 0`		\
	`i2c_get 0x39 0x80`		\
	`i2c_get 0x39 0x81`		\
	"`eeval cec_mode i2c_mbv 0x39 0x4E 0 1`"

