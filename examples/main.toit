import quiicScmd as scmd

import i2c
import gpio

main:
  bus := i2c.Bus
    --sda=gpio.Pin 21
    --scl=gpio.Pin 22
  
  device := bus.device scmd.I2C_ADDRESS_ALT

  motor := scmd.Scmd device

  print "motor test"
  R_MTR := 0
  L_MTR := 1
  FWD := 0
  BWD := 1

  motor.on
  motor.begin
  print "motor on"




  






