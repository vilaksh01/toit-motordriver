// Copyright (C) 2021 Sumit Kumar. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be found
// in the LICENSE file.

import binary
import serial.device as serial
import serial.registers as serial

/**
Quiic Motor Driver.
*/

DEFAULT_NAME ::= "Quiic Serial Control Motor Driver"
I2C_ADDRESS ::= 0x5D
I2C_ADDRESS_ALT ::= 0x58

class Scmd:
  static FORWARD ::= 1
  static BACKWARD ::= -1

  static POLARITY_NORMAL ::= 0
  static POLARITY_INVERTED ::= 1

  static DEFAULT_ID_ ::= 0xA9

  // SCMD_STATUS_1 bits
  static ENUMERATION_BIT_  ::= 0x01
  static BUSY_BIT_  ::= 0x02
  static REM_READ_BIT_ ::= 0x04
  static REM_WRITE_BIT_ ::= 0x08

  // Address map
  static REG_ID_ADDRESS_ ::= 0x01
  static MOTOR_A_INVERT_        ::= 0x12
  static MOTOR_B_INVERT_        ::= 0x13
  static BRIDGE_                ::= 0x14
  static MA_DRIVE_              ::= 0x20

  static INV_2_9_           ::= 0x50
  static INV_10_17_         ::= 0x51
  static INV_18_25          ::= 0x52
  static INV_26_33          ::= 0x53
  static BRIDGE_SLV_L       ::= 0x54
  static BRIDGE_SLV_H       ::= 0x55

  static DRIVER_ENABLE_        ::= 0x70
  static STATUS_1_              ::= 0x77

  reg_/serial.Registers

  constructor device/serial.Device:
    reg_ = device.registers

  on:
    reg := reg_.read_u8 REG_ID_ADDRESS_
    if reg != DEFAULT_ID_ : throw "INVALID_CHIP"

  /**
  Whether the motor driver is ready.

  Returns false when the firmware is booting.
  The driver must be ready before starting to configure it.
  */
  ready -> bool:
    statusByte := reg_.read_u8 STATUS_1_
    return statusByte & ENUMERATION_BIT_ and statusByte != 0xFF

  /**
  Whether the motor driver is busy with another task.

  The driver is busy 30us after a triggering register is written.
  When writing a command while the driver is still busy, the earlier
    command could be overwritten.
  */
  busy -> bool:
    statusByte := reg_.read_u8 STATUS_1_
    return statusByte & (BUSY_BIT_ or REM_READ_BIT_ or REM_WRITE_BIT_) != 0

  enable:
    // enable driver functions for H bridges
    reg_.write_u8 DRIVER_ENABLE_ 0x01

  disable:
    reg_.write_u8 DRIVER_ENABLE_ 0x00

  /**
  Sends a command to a motor.

  The $motor number selects the motor (in range 0 to 33).
  The $direction must be $FORWARD or $BACKWARD.
  The $level must be a byte in range 0 to 255.
  */
  set_drive --motor/int --direction/int --level/int:
    if not 0 <= motor <= 33: throw "INVALID MOTOR NUMBER"
    if direction != FORWARD and direction != BACKWARD: throw "INVALID DIRECTION"
    if not 0 <= level <= 255: throw "INVALID LEVEL"
    assert: FORWARD == 1 and BACKWARD == -1

    half_level := level / 2
    reg_value /int := 128 + (direction * half_level)
    reg_.write_u8 (MA_DRIVE_ + motor) reg_value

  /**
  Sets a motor's direction inversion.

  The $motor number selects the motor (in range 0 to 33).
  The $polarity must be $POLARITY_NORMAL or $POLARITY_INVERTED.
  */
  set_inversion_mode --motor/int polarity/int:
    if not 0 <= motor <= 33: throw "INVALID MOTOR NUMBER"
    if polarity != POLARITY_NORMAL and polarity != POLARITY_INVERTED: throw "INVALID POLARITY"

    // We are using the polarity variable directly as bit value.
    // Make sure it's set correctly.
    assert: POLARITY_NORMAL == 0 and POLARITY_INVERTED == 1

    if motor == 0:
      reg_.write_u8 MOTOR_A_INVERT_ polarity
    if motor == 1:
      reg_.write_u8 MOTOR_B_INVERT_ polarity
    else:
      register := 0
      if motor < 10:
        register = INV_2_9_
        motor -= 2
      else if motor < 18:
        register = INV_10_17_
        motor -= 10
      else if motor < 26:
        register = INV_18_25
        motor -= 18
      else:
        register = INV_26_33
        motor -= 26

      mask := 1 << motor
      old := reg_.read_u8 register
      // Clear the motor's bit.
      cleared := old & ~mask
      // Set the bit to the new value. If the polarity is 0, doesn't do anything.
      new := cleared | mask

      reg_.write_u8 register new

  /**
  Sets the bridging mode.

  Connects outputs together, controlling both from what was the 'A' position.

  The $driver must be in range 0 (master) to 16.

  It is an error to use $on and $off at the same time.
  */
  set_bridging_mode --driver/int --off/bool=false --on/bool=(not off):
    if (on and off) or (not on and not off): throw "INVALID ARGUMENTS"
    if not 0 <= driver <= 16: throw "INVALID DRIVER"


    bridged := on ? 1 : 0

    if driver == 0:
      reg_.write_u8 BRIDGE_ bridged & 0x01
      return

    register := 0
    if driver < 9:
      register = BRIDGE_SLV_L
      driver -= 1

    else:
      register = BRIDGE_SLV_H
      driver -= 9

    mask := 1 << driver
    old := reg_.read_u8 register
    cleared := old & ~mask
    new := cleared | mask
    reg_.write_u8 register new























