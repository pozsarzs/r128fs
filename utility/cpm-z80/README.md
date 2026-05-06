# R128

## Utility collection

|Key         |Value                                           |
|------------|------------------------------------------------|
|version     |v0.1                                            |
|licence     |MIT                                             |
|architecture|Z80                                             |
|OS          |CP/M-80                                         |
|compiler    |SLR Systems Z80ASM v1.32 (1986)                 |
|author      |[Pozsar Zsolt](mailto:pozsarzs@gmail.com) (2026)|
|web         |[Pozsi's homepage](https://www.pozsarzs.hu)     |
|            |[on Github](https://github.com/pozsarzs/r128fs) |

This is a collection of utilities for managing R128 file systems on disk, image,
and memory.

## Programs and their use

`RCOPY dsc=drive|bank=bank emx=port|img=file|mem=addr source_file [target_file]`  
Copies a file from the R128 filesystem to the host filesystem. If target_file is
not specified, the original filename is used.

`RDIR dsc=drive|bank=bank emx=port|img=file|mem=addr [filename]`  
Lists files in the R128 filesystem. If filename is specified, only matching
entries are shown.

`RSTAT dsc=drive|bank=bank emx=port|img=file|mem=addr [filename]`  
Displays filesystem information and validates structure. If filename is
specified, shows detailed information for that file.

`RTYPE dsc=drive|bank=bank emx=port|img=file|mem=addr filename`  
Outputs the contents of a file from the R128 filesystem to the console.
