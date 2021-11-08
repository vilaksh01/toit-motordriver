// quiic motor driver
import binary
import serial.device as serial
import serial.registers as serial
// import math

/**
Quiic Motor Driver.
*/

DEFAULT_NAME ::= "Quiic Serial Control Motor Driver"
I2C_ADDRESS ::= 0x5D
I2C_ADDRESS_ALT ::= 0x58

class SCMDDiagnostics:
  numberOfSlaves := 0
  U_I2C_RD_ERR := 0
  U_I2C_WR_ERR := 0
  U_BUF_DUMPED := 0
  E_I2C_RD_ERR := 0
  E_I2C_WR_ERR := 0
  LOOP_TIME := 0
  SLV_POLL_CNT := 0
  MST_E_ERR := 0
  MST_E_STATUS := 0
  FSAFE_FAULTS := 0
  REG_OOR_CNT := 0
  REG_RO_WRITE_CNT := 0

class QuiicScmd:
  static REG_DEFAULT_ADDRESS_ ::= 0x00
  static ID_WORD_ ::= 0xA9
  static START_SLAVE_ADDR_ ::= 0x50
  static MAX_SLAVE_ADDR_ ::= 0x5F
  static MASTER_LOCk_KEY_ ::= 0x9B
  static USER_LOCK_KEY_ ::= 0x5C
  static FIRMWARE_VERSION_ ::= 0x07
  static POLL_ADDRESS_ ::= 0x4A
  static MAX_POLL_LIMIT_ ::= 0xC8

  // SCMD_STATUS_1 bits
  static ENUMERATION_BIT_  ::= 0x01
  static BUSY_BIT_  ::= 0x02
  static REM_READ_BIT_ ::= 0x04
  static REM_WRITE_BIT_ ::= 0x08
  static HW_EN_BIT_  ::= 0x10

  // SCMD_CONTROL_1 bits
  static FULL_RESET_BIT_  ::= 0x01
  static RE_ENUMERATE_BIT_  ::= 0x02

  // SCMD_FSAFE_CTRL bits and masks
  static FSAFE_DRIVE_KILL_ ::= 0x01
  static FSAFE_RESTART_MASK_  ::= 0x06
  static FSAFE_REBOOT_  ::= 0x02
  static FSAFE_RE_ENUM_ ::= 0x04
  static FSAFE_CYCLE_USER_  ::= 0x08
  static FSAFE_CYCLE_EXP_ ::= 0x10

  // SCMD_MST_E_IN_FN bits and masks
  static M_IN_RESTART_MASK_    ::= 0x03
  static M_IN_REBOOT_          ::= 0x01
  static M_IN_RE_ENUM_         ::= 0x02
  static M_IN_CYCLE_USER_      ::= 0x04
  static M_IN_CYCLE_EXP_       ::= 0x08

  // Address map
  static FID_  ::= 0x00
  static REGISTER_ID_ ::= 0x01
  static SLAVE_ADDR_     ::= 0x02
  static CONFIG_BITS_   ::= 0x03
  static U_I2C_RD_ERR_  ::= 0x04
  static U_I2C_WR_ERR_   ::= 0x05
  static U_BUF_DUMPED_   ::= 0x06
  static E_I2C_RD_ERR_   ::= 0x07
  static E_I2C_WR_ERR_      ::= 0x08
  static LOOP_TIME_     ::= 0x09
  static SLV_POLL_CNT_   ::= 0x0A
  static SLV_TOP_ADDR_    ::= 0x0B
  static MST_E_ERR_       ::= 0x0C
  static MST_E_STATUS_     ::= 0x0D
  static FSAFE_FAULTS_     ::= 0x0E
  static REG_OOR_CNT_      ::= 0x0F
  static REG_RO_WRITE_CNT_   ::= 0x10
  static GEN_TEST_WORD_         ::= 0x11
  static MOTOR_A_INVERT_        ::= 0x12
  static MOTOR_B_INVERT_        ::= 0x13
  static BRIDGE_                ::= 0x14
  static LOCAL_MASTER_LOCK_     ::= 0x15
  static LOCAL_USER_LOCK_       ::= 0x16
  static MST_E_IN_FN_           ::= 0x17
  static U_PORT_CLKDIV_U_       ::= 0x18
  static U_PORT_CLKDIV_L_       ::= 0x19
  static U_PORT_CLKDIV_CTRL_    ::= 0x1A
  static E_PORT_CLKDIV_U_       ::= 0x1B
  static E_PORT_CLKDIV_L_       ::= 0x1C
  static E_PORT_CLKDIV_CTRL_    ::= 0x1D
  static U_BUS_UART_BAUD_       ::= 0x1E
  static FSAFE_CTRL_            ::= 0x1F
  static MA_DRIVE_              ::= 0x20
  static MB_DRIVE_              ::= 0x21
  static S1A_DRIVE_             ::= 0x22
  static S1B_DRIVE_             ::= 0x23
  static S2A_DRIVE_             ::= 0x24
  static S2B_DRIVE_             ::= 0x25
  static S3A_DRIVE_             ::= 0x26
  static S3B_DRIVE_             ::= 0x27
  static S4A_DRIVE_             ::= 0x28
  static S4B_DRIVE_             ::= 0x29
  static S5A_DRIVE_             ::= 0x2A
  static S5B_DRIVE_             ::= 0x2B
  static S6A_DRIVE_             ::= 0x2C
  static S6B_DRIVE_             ::= 0x2D
  static S7A_DRIVE_             ::= 0x2E
  static S7B_DRIVE_             ::= 0x2F
  static S8A_DRIVE_             ::= 0x30
  static S8B_DRIVE_             ::= 0x31
  static S9A_DRIVE_             ::= 0x32
  static S9B_DRIVE_             ::= 0x33
  static S10A_DRIVE_            ::= 0x34
  static S10B_DRIVE_            ::= 0x35
  static S11A_DRIVE_            ::= 0x36
  static S11B_DRIVE_            ::= 0x37
  static S12A_DRIVE_            ::= 0x38
  static S12B_DRIVE_            ::= 0x39
  static S13A_DRIVE_            ::= 0x3A
  static S13B_DRIVE_            ::= 0x3B
  static S14A_DRIVE_            ::= 0x3C
  static S14B_DRIVE_            ::= 0x3D
  static S15A_DRIVE_            ::= 0x3E
  static S15B_DRIVE_            ::= 0x3F
  static S16A_DRIVE_            ::= 0x40
  static S16B_DRIVE_            ::= 0x41

  static INV_2_9_           ::= 0x50
  static INV_10_17_         ::= 0x51
  static INV_18_25          ::= 0x52
  static INV_26_33          ::= 0x53
  static BRIDGE_SLV_L       ::= 0x54
  static BRIDGE_SLV_H       ::= 0x55

  // static PAGE_SELECT_          ::= 0x6F
  static DRIVER_ENABLE_        ::= 0x70
  static UPDATE_RATE_      ::= 0x71
  static FORCE_UPDATE_         ::= 0x72
  static E_BUS_SPEED_           ::= 0x73
  static MASTER_LOCK_           ::= 0x74
  static USER_LOCK_           ::= 0x75
  static FSAFE_TIME_            ::= 0x76
  static STATUS_1_              ::= 0x77
  static CONTROL_1_             ::= 0x78

  static REM_ADDR_         ::= 0x79
  static REM_OFFSET_       ::= 0x7A
  static REM_DATA_WR_      ::= 0x7B
  static REM_DATA_RD_      ::= 0x7C
  static REM_WRITE_        ::= 0x7D
  static REM_READ_         ::= 0x7E


  reg_/serial.Registers ::= ?

  constructor dev/serial.Device:
    reg_ = dev.registers   

  on:
    reg := reg_.read_u8 REG_DEFAULT_ADDRESS_
    if reg != I2C_ADDRESS: throw "INAVLID_CHIP"

  begin:
    // dummy read
    reg_.read_u8 REGISTER_ID_
    return reg_.read_u8 REGISTER_ID_

  ready -> bool:
    // returns if driver is ready
    // return type- bool
    statusByte := reg_.read_u8 STATUS_1_
    return statusByte & ENUMERATION_BIT_ and statusByte != 0xFF

  busy -> bool:
    // returns if driver is busy
    // return type- bool
    statusByte := reg_.read_u8 STATUS_1_
    return statusByte & (BUSY_BIT_ or REM_READ_BIT_ or REM_WRITE_BIT_) != 0

  enable:
    // enable driver functions for H bridges
    reg_.write_u8 DRIVER_ENABLE_ 0x01

  disable:
    // disable driver functions for H bridges
    reg_.write_u8 DRIVER_ENABLE_ 0x00

  reset_:
    // reset driver functions for H bridges

  set_drive motorNum/int level/int direction/int:
    // drive a motor at given level
    // param motorNum/int: motor number from 0 to 33
    // param level/int: level from 0 to 255
    // param direction/int: direction from 0 (forward) or 1(backward)
    // no return value

    level = round_up (level + 1 - direction/2) 10.to_int
    //level = level >> 1
    driveValue := 0

    if motorNum < 34:
        driveValue = (level * direction) + (level * (direction - 1))
        driveValue += 128
        reg_.write_u8 (MA_DRIVE_ + motorNum) driveValue

  inversion_mode motorNum/int polarity/int:
    // set inversion mode for H bridges
    // param polarity/int: inversion mode from 0 (normal) to 1 (inverted)
    // param motorNum/int: motor number from 0 to 33
    // no return value

    regTemp := 0
    // selection of target resistor
    if motorNum < 2:
      if motorNum == 0: 
        reg_.write_u8 MOTOR_A_INVERT_ polarity & 0x01
      if motorNum == 1: 
        reg_.write_u8 MOTOR_B_INVERT_ polarity & 0x01

      else:
        if motorNum < 10:
          regTemp = INV_2_9_
          motorNum -= 2

        else if motorNum < 18:
          regTemp = INV_10_17_
          motorNum -= 10

        else if motorNum < 26:
          regTemp = INV_18_25
          motorNum -= 18

        else if motorNum < 34:
          regTemp = INV_26_33
          motorNum -= 26
        
        else:
          return

        // convert motorNum to one-hot mask
        data/int := reg_.read_u8 regTemp & (~(1 << motorNum) & 0xFF)
        reg_.write_u8 regTemp (data | ((polarity & 0x01) << motorNum))
  

  // Bridge mode for configuring device bridging state
  bridging_mode driverNum/int bridged/int:
    // param driverNum/int: number of driver. Master 0, slave 1, 0 to 16
    // param bridged/int: bridged state 0 (forward) to 1 (backward)
    // no return value

    regTemp := 0

    // selection of target resistor
    if driverNum < 1:
      reg_.write_u8 BRIDGE_ bridged & 0x01
    
    else:
      if driverNum < 9:
        regTemp = BRIDGE_SLV_L
        driverNum -= 1

      else if driverNum < 17:
        regTemp = BRIDGE_SLV_H
        driverNum -= 9
      
      else:
        return
      
      data := reg_.read_u8 regTemp & (~(1 << driverNum) & 0xFF)
      reg_.write_u8 regTemp (data | ((bridged & 0x01) << driverNum))

  // get_diagnostics address:
  //   myDiag := SCMDDiagnostics

  //   myDiag.numberOfSlaves = 0
  //   myDiag.U_I2C_RD_ERR = 0
  //   myDiag.U_I2C_WR_ERR = 0
  //   myDiag.U_BUF_DUMPED = 0
  //   myDiag.E_I2C_RD_ERR = read_remote_register()








        



    



    




    


