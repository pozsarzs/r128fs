# R128

## Routine collection

|Key         |Value                                           |
|------------|------------------------------------------------|
|version     |v0.1                                            |
|licence     |MIT                                             |
|architecture|Z80                                             |
|OS          |CP/M-80                                         |
|compiler    |SLR Systems Z80ASM v1.32 (1986)                 |
|linker      |Microsoft Link-80 v3.44 (1981)                  |
|author      |[Pozsar Zsolt](mailto:pozsarzs@gmail.com) (2026)|
|web         |[Pozsi's homepage](https://www.pozsarzs.hu)     |
|            |[on Github](https://github.com/pozsarzs/r128fs) |

This is a collection of routines for managing R128 file systems on disk, image,
and memory.

### Modules

 - _R128lib_: interface between the application and hardware-handling modules
 - _Rdsclib_: handler routines for on-disc filesystem
 - _Remxlib_: handler routines for on-chip filesystem via PEMX device
 - _Rimglib_: handler routines for in-image filesystem
 - _Rmemlib_: handler routines for in-memory filesystem 

### Functions

 - _R128IN_: initialize R128lib module
 - _R128FF_: find first file
 - _R128FN_: find next file
 - _R128OP_: open file
 - _R128RD_: read file
 - _R128SK_: seek in file
 - _R128CL_: close file
 - _R128NF_: get media or file information

 - _RDINIT_: initialize Rdsclib module
 - _RDSTRD_: read a physical sector from disc (512 Byte)

 - _REINIT_: initialize Remxlib module 
 - _RESTRD_: read a logical sector from ROM via PEMX device (128 Byte) 


 - _RIINIT_: initialize Rimglib module 
 - _RISTRD_: read a logical sector from disc image (128 Byte) 
 - _RIDONE_: close module

 - _RMINIT_: initialize Rmemlib module
 - _RMSTRD_: read a logical sector from memory (128 Byte) 

### Module I/O register specification

|name   |A  |B      |C    |DE      |HL     |function|ret. A |ret. HL |
|-------|:-:|:-----:|:---:|:------:|:-----:|--------|:-----:|:-------|
|r128lib|00h|discid |     |        |bufaddr|R128IN  |errcode|bufaddr |
|r128lib|01h|       |     |maskaddr|       |R128FF  |errcode|entryptr|
|r128lib|02h|       |     |        |       |R128FN  |errcode|entryptr|
|r128lib|03h|       |     |nameaddr|       |R128OP  |errcode|        |
|r128lib|04h|       |     |count   |bufaddr|R128RD  |errcode|bytesrd |
|r128lib|05h|       |     |pos     |       |R128SK  |errcode|        |
|r128lib|06h|       |     |        |       |R128CL  |errcode|        |
|r128lib|07h|       |     |        |       |R128NF  |errcode|infoptr |
|       |   |       |     |        |       |        |       |        |
|rdsclib|00h|       |     |        |bufaddr|RDINIT  |0      |bufaddr |
|rdsclib|01h|discid |     |track   |sector |RDSTRD  |errcode|bufaddr |
|       |   |       |     |        |       |        |       |        |
|remxlib|00h|       |     |pioaddr |bufaddr|REINIT  |0      |bufaddr |
|remxlib|01h|banknum|     |sectnum |       |RESTRD  |errcode|bufaddr |
|       |   |       |     |        |       |        |       |        |
|rimglib|00h|onlyfop|     |fcbaddr |bufaddr|RIINIT  |errcode|bufaddr |
|rimglib|01h|       |     |sectnum |       |RISTRD  |errcode|bufaddr |
|rimglib|02h|onlyfcl|     |        |       |RIDONE  |       |        |
|       |   |       |     |        |       |        |       |        |
|rmemlib|00h|       |     |romaddr |bufaddr|RMINIT  |0      |bufaddr |
|rmemlib|01h|       |     |sectnum |       |RMSTRD  |errcode|bufaddr |

**Notes:**

- _banknum:_ bank number of PEMX device
- _bufaddr:_ start address of the buffer area
- _bytesrd:_ number of bytes actually read into the buffer
- _count:_ number of bytes to read from the file
- _discid:_  disc identity number
- _entryptr:_ pointer to the current 16-byte file entry structure
- _errcode:_
  - A = 00h: no error          (CF = 0)
  - A = 01h: bad function      (CF = 1)
  - A = 02h: shift overflow    (CF = 1)
  - A = 03h: address overflow  (CF = 1)
  - A = 04h: file open error   (CF = 1)
  - A = 05h: file read error   (CF = 1)
  - A = 06h: file close error  (CF = 1)
  - A = 07h: sector read error (CF = 1)
- _fcbaddr:_ pointer to 36 bytes file control block
- _infoptr:_ pointer to a structure containing filesystem header information
- _maskaddr:_ pointer to a filename mask in 8.3 format
- _nameaddr:_ pointer to a filename in 8.3 format
- _onlyfop:_
  - B = 00h: initialize and open image file
  - B > 00h: file open only
- _onlyfcl:_
  - B = 00h: close image file and clean up
  - B > 00h: file close only
- _pioaddr:_ i/o address of Z80PIO circuit
- _pos:_ file position (byte offset from the beginning of the file)
- _romaddr:_ start address of ROM with R128 filesystem
- _sectnum:_ the number of the sector to be read
- _track:_ number of the track 
