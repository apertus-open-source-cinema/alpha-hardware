#!/bin/sh

echo lm75 0x4b >/sys/class/i2c-adapter/i2c-1/new_device
echo lm75 0x4f >/sys/class/i2c-adapter/i2c-1/new_device
echo lm80 0x28 >/sys/class/i2c-adapter/i2c-1/new_device
echo pca9537 0x49 >/sys/class/i2c-adapter/i2c-1/new_device

echo 0 >/sys/class/gpio/export
echo out >/sys/class/gpio/gpio0/direction
echo 1 >/sys/class/gpio/gpio0/value

echo 1 >/sys/class/gpio/export
echo out >/sys/class/gpio/gpio1/direction
echo 0 >/sys/class/gpio/gpio1/value

