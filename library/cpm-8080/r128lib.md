# R128

## Routine collection

|Key         |Value                                           |
|------------|------------------------------------------------|
|version     |v0.1                                            |
|licence     |MIT                                             |
|architecture|8080                                            |
|OS          |CP/M-80                                         |
|compiler    |Digital Research CP/M RMAC Assembler v1.1 (1980)|
|author      |[Pozsar Zsolt](mailto:pozsarzs@gmail.com) (2026)|
|web         |[Pozsi's homepage](https://www.pozsarzs.hu)     |
|            |[on Github](https://github.com/pozsarzs/r128fs) |

This is a collection of routines for managing R128 file systems on disk, image,
and memory.

### Available functions

|name   |A  |B  |C       |DE     |HL      |function|return A|return HL|
|-------|:-:|:-:|:------:|:-----:|:------:|--------|:------:|:--------|
|r128lib|00h|   |        |       |        |        |        |         |
|rdsclib|00h|   |        |       |bufaddr |RDINIT  |        |         |
|rdsclib|01h|   |        |sectnum|discid  |RDSTRD  |        |         |
|rimglib|00h|   |        |       |bufaddr |RIINIT  |        |         |
|rimglib|01h|   |        |sectnum|FCB     |RISTRD  |        |         |
|rmemlib|00h|   |        |       |bufaddr |RMINIT  |        |         |
|rmemlib|01h|   |        |sectnum|romaddr |RMSTRD  |        |         |

**Notes:**  
  - _bufaddr.:_ start address of the buffer area [0000..FFFFh]
  - _discid:_ disc identity number [00-FFh]
  - _FCB:_ pointer to 36 bits file control block [0000..FFFFh]
  - _romaddr:_ start address of ROM with R128 filesystem [0000..FFFFh]
  - _sectnum:_ the number of the sector to be read [0000..FFFFh]
