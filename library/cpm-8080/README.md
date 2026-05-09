# R128

## Routine collection

|Key         |Value                                           |
|------------|------------------------------------------------|
|version     |v0.1                                            |
|licence     |MIT                                             |
|architecture|8080                                            |
|OS          |CP/M-80                                         |
|compiler    |Digital Research CP/M RMAC Assembler v1.1 (1980)|
|linker      |Microsoft Link-80 v3.44 (1981)                  |
|author      |[Pozsar Zsolt](mailto:pozsarzs@gmail.com) (2026)|
|web         |[Pozsi's homepage](https://www.pozsarzs.hu)     |
|            |[on Github](https://github.com/pozsarzs/r128fs) |

This is a collection of routines for managing R128 file systems on disk, image,
and memory.

### Available functions

|name   |A  |B      |C     |DE      |HL     |function|ret. A |ret. HL |
|-------|:-:|:-----:|:----:|:------:|:-----:|--------|:-----:|:-------|
|r128lib|00h|discid |      |        |bufaddr|R128IN  |errcode|bufaddr |
|r128lib|01h|       |      |maskaddr|       |R128FF  |errcode|entryptr|
|r128lib|02h|       |      |        |       |R128FN  |errcode|entryptr|
|r128lib|03h|       |      |nameaddr|       |R128OP  |errcode|        |
|r128lib|04h|       |      |count   |bufaddr|R128RD  |errcode|bytesrd |
|r128lib|05h|       |      |pos     |       |R128SK  |errcode|        |
|r128lib|06h|       |      |        |       |R128CL  |errcode|        |
|r128lib|07h|       |      |        |       |R128NF  |errcode|infoptr |
|       |   |       |      |        |       |        |       |        |
|rdsclib|00h|secttrk|discid|        |bufaddr|RDINIT  |0      |bufaddr |
|rdsclib|01h|       |      |sectnum |       |RDSTRD  |errcode|bufaddr |
|       |   |       |      |        |       |        |       |        |
|remxlib|00h|       |      |pioaddr |bufaddr|RMINIT  |0      |bufaddr |
|remxlib|01h|banknum|      |sectnum |       |RMSTRD  |errcode|bufaddr |
|       |   |       |      |        |       |        |       |        |
|rimglib|00h|       |      |fcbaddr |bufaddr|RIINIT  |errcode|bufaddr |
|rimglib|01h|       |      |sectnum |       |RISTRD  |errcode|bufaddr |
|rimglib|02h|       |      |        |       |RISTCL  |errcode|        |
|       |   |       |      |        |       |        |       |        |
|rmemlib|00h|       |      |romaddr |bufaddr|RMINIT  |0      |bufaddr |
|rmemlib|01h|       |      |sectnum |       |RMSTRD  |errcode|bufaddr |

**Notes:**

- _banknum:_ bank number of PEMX device
- _bufaddr:_ start address of the buffer area
- _bytesrd:_ number of bytes actually read into the buffer
- _count:_ number of bytes to read from the file
- _discid:_  disc identity number
- _entryptr:_ pointer to the current 16-byte file entry structure
- _errcode:_
  - A = 00h: no error         (CF = 0)
  - A = 01h: bad function     (CF = 1)
  - A = 02h: shift overflow   (CF = 1)
  - A = 03h: address overflow (CF = 1)
  - A = 04h: file open error  (CF = 1)
  - A = 05h: file read error  (CF = 1)
  - A = 06h: file close error (CF = 1)
- _fcbaddr:_ pointer to 36 bytes file control block
- _infoptr:_ pointer to a structure containing filesystem header information
- _maskaddr:_ pointer to a filename mask in 8.3 format
- _nameaddr:_ pointer to a filename in 8.3 format
- _pioaddr:_ i/o address of Z80PIO circuit
- _pos:_ file position (byte offset from the beginning of the file)
- _romaddr:_ start address of ROM with R128 filesystem
- _sectnum:_ the number of the sector to be read
- _secttrk:_ sector/track
