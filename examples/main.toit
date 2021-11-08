import quiicScmd as scmd

import i2c
import gpio

main:
  bus := i2c.Bus
    --sda=gpio.Pin 21
    --scl=gpio.Pin 22
  
  device := bus.device scmd.I2C_ADDRESS

  motor := scmd.Scmd device

  print "motor test"
  R_MTR := 0
  L_MTR := 1
  FWD := 0
  BWD := 1

  motor.on
  print "motor on"
  motor.begin
  print "motor initialized"
  sleep --ms=100

  motor.set_drive 0 0 0
  motor.set_drive 1 0 0

  motor.enable

  print "motor enabled"
  sleep --ms=100

  while true:
    speed := 20
    for i := speed; i < 255; i++:
      print "speed: $i"
      motor.set_drive R_MTR FWD i
      motor.set_drive L_MTR FWD i
      sleep --ms=1
    for i := 254; i > speed; i--:
      print "speed: $i"
      motor.set_drive R_MTR FWD i
      motor.set_drive L_MTR FWD i
      sleep --ms=1









  






