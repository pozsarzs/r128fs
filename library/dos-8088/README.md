# R128

## Routine collection

|Key         |Value                                           |
|------------|------------------------------------------------|
|version     |v0.1                                            |
|licence     |MIT                                             |
|architecture|8088                                            |
|OS          |DOS                                             |
|compiler    |Microsoft Macro Assembler v3.0 (1984)           |
|linker      |Microsoft 8086 Object Linker v3.0 (1985)        |
|author      |[Pozsar Zsolt](mailto:pozsarzs@gmail.com) (2026)|
|web         |[Pozsi's homepage](https://www.pozsarzs.hu)     |
|            |[on Github](https://github.com/pozsarzs/r128fs) |

This is a collection of routines for managing R128 file systems on disk, image,
and memory.

### Modules

 - _R128lib_: interface between the application and hardware-handling modules
 - _Rdsclib_: handler routines for on-disc filesystem
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

 - _RIINIT_: initialize Rimglib module 
 - _RISTRD_: read a logical sector from disc image (128 Byte) 
 - _RIDONE_: close module

 - _RMINIT_: initialize Rmemlib module
 - _RMSTRD_: read a logical sector from memory (128 Byte) 

### Module I/O register specification

|name   |AL |BX     |CH  |CL     |DX      |function|ret. AL|ret. BX |
|-------|:-:|:-----:|:--:|:-----:|:------:|--------|:-----:|:------:|
|r128lib|00h|bufaddr|    |discid |        |R128IN  |errcode|bufaddr |
|r128lib|01h|       |    |       |maskaddr|R128FF  |errcode|entryptr|
|r128lib|02h|       |    |       |        |R128FN  |errcode|entryptr|
|r128lib|03h|       |    |       |nameaddr|R128OP  |errcode|        |
|r128lib|04h|       |    |       |count   |R128RD  |errcode|bytesrd |
|r128lib|05h|       |    |       |pos     |R128SK  |errcode|        |
|r128lib|06h|       |    |       |        |R128CL  |errcode|        |
|r128lib|07h|       |    |       |        |R128NF  |errcode|infoptr |
|       |   |       |    |       |        |        |       |        |
|rdsclib|00h|bufaddr|    |       |        |RDINIT  |0      |bufaddr |
|rdsclib|01h|sector |head|discid |track   |RDSTRD  |errcode|bufaddr |
|       |   |       |    |       |        |        |       |        |
|rimglib|00h|bufaddr|    |onlyfop|fcbaddr |RIINIT  |errcode|bufaddr |
|rimglib|01h|       |    |       |sectnum |RISTRD  |errcode|bufaddr |
|rimglib|02h|       |    |onlyfcl|        |RIDONE  |errcode|        |
|       |   |       |    |       |        |        |       |        |
|rmemlib|00h|bufaddr|    |       |romaddr |RMINIT  |0      |bufaddr |
|rmemlib|01h|       |    |       |sectnum |RMSTRD  |errcode|bufaddr |

**Notes:**

- _bufaddr:_ start address of the buffer area
- _bytesrd:_ number of bytes actually read into the buffer
- _count:_ number of bytes to read from the file
- _discid:_  disc identity number
- _entryptr:_ pointer to the current 16-byte file entry structure
- _errcode:_
  - AL = 00h: no error          (CF = 0)
  - AL = 01h: bad function      (CF = 1)
  - AL = 02h: shift overflow    (CF = 1)
  - AL = 03h: address overflow  (CF = 1)
  - AL = 04h: file open error   (CF = 1)
  - AL = 05h: file read error   (CF = 1)
  - AL = 06h: file close error  (CF = 1)
  - AL = 07h: sector read error (CF = 1)
- _fcbaddr:_ pointer to 36 bytes file control block
- _infoptr:_ pointer to a structure containing filesystem header information
- _maskaddr:_ pointer to a filename mask in 8.3 format
- _nameaddr:_ pointer to a filename in 8.3 format
- _onlyfop:_
  - CL = 00h: initialize and open image file
  - CL > 00h: file open only
- _onlyfcl:_
  - CL = 00h: close image file and clean up
  - CL > 00h: file close only
- _pos:_ file position (byte offset from the beginning of the file)
- _romaddr:_ start address of ROM with R128 filesystem
- _sectnum:_ the number of the sector to be read
- _track:_ number of the track 
