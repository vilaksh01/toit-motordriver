// Copyright (C) 2021 vilaksh01.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import quiic_scmd as scmd

import i2c
import gpio

main:
  bus := i2c.Bus
    --sda=gpio.Pin 21
    --scl=gpio.Pin 22

  device := bus.device scmd.I2C_ADDRESS

  motor := scmd.Scmd device

  print "motor test"
  R_MTR ::= 0
  L_MTR ::= 1
  FWD ::= scmd.Scmd.FORWARD
  BWD ::= scmd.Scmd.BACKWARD

  motor.on
  print "motor on"
  sleep --ms=100

  motor.set_drive --motor=R_MTR --direction=FWD --level=0
  motor.set_drive --motor=L_MTR --direction=FWD --level=0

  motor.enable
  print "motor enabled"
  sleep --ms=100

  while true:
    speed := 20
    for i := speed; i < 255; i++:
      print "speed: $i"
      motor.set_drive --motor=R_MTR --direction=FWD --level=i
      motor.set_drive --motor=L_MTR --direction=FWD --level=i
      sleep --ms=1
    for i := 254; i > speed; i--:
      print "speed: $i"
      motor.set_drive --motor=R_MTR --direction=FWD --level=i
      motor.set_drive --motor=L_MTR --direction=FWD --level=i
      sleep --ms=1
















