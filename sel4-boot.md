# Building and Running seL4 on CVA6 on the Genesys 2

## Building a Bitfile

First, build a bitfile according to the instructions given in [the CVA6 VM from Scratch notes](https://github.com/Capabilities-Limited/cva6-build-notes/blob/main/cva6-vm-from-scratch-notes.md).

Second, program the FPGA with your bitfile according to [the instructions in the CVA6 repository](https://github.com/Capabilities-Limited/cva6?tab=readme-ov-file#programming-the-memory-configuration-file).


## Running on FPGA

1. Then, in a terminal, launch **OpenOCD**:
```
$ openocd -f corev_apu/fpga/ariane.cfg
```
If it is successful, you should see something like:
```
Open On-Chip Debugger 0.10.0+dev (SiFive OpenOCD 0.10.0-2019.08.2)
Licensed under GNU GPL v2
For bug reports:
        https://github.com/sifive/freedom-tools/issues
adapter speed: 1000 kHz
Info : auto-selecting first available session transport "jtag". To override use 'transport select <transport>'.
Info : clock speed 1000 kHz
Info : JTAG tap: riscv.cpu tap/device found: 0x00000001 (mfg: 0x000 (<invalid>), part: 0x0000, ver: 0x0)
Info : datacount=2 progbufsize=8
Info : Examined RISC-V core; found 1 harts
Info :  hart 0: XLEN=64, misa=0x800000000014112f
Info : Listening on port 3333 for gdb connections
Ready for Remote Connections
Info : Listening on port 6666 for tcl connections
Info : Listening on port 4444 for telnet connections
Info : accepting 'gdb' connection on tcp/3333

```
2. In a separate terminal, launch **gdb**, and run it with the seL4 binary (an example is available [here](https://drive.google.com/drive/folders/1azphw9wquPcjpqhVg4aqD5IMktSmnicW?usp=sharing)):
```
$ riscv64-unknown-elf-gdb <path>/sel4test-driver-image-riscv-ariane
```
You must use gdb from the RISC-V toolchain. If it is successful, you should see:
```
GNU gdb (SiFive GDB 8.3.0-2019.08.0) 8.3
Copyright (C) 2019 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "--host=x86_64-apple-darwin17.7.0 --target=riscv64-unknown-elf".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<https://github.com/sifive/freedom-tools/issues>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from sel4test-driver-image-riscv-ariane...
(gdb) 
```
3. In gdb, you need to connect gdb to OpenOCD:
```
(gdb) target remote :3333
```
if it is successful, you should see the gdb connection in OpenOCD:
```
Info : accepting 'gdb' connection on tcp/3333
```
4. In gdb, load the binary to CV64A6 FPGA platform (takes about two minutes):
```
(gdb) load
Loading section .text, size 0xe2d0 lma 0x80000000
Loading section .rodata, size 0x1738 lma 0x8000f000
Loading section .eh_frame, size 0x4998 lma 0x80010738
Loading section .eh_frame_hdr, size 0x9ac lma 0x800150d0
Loading section .data, size 0x358 lma 0x80016000
Loading section .payload, size 0x45de58 lma 0x80200000
Start address 0x80000000, load size 4665084
Transfer rate: 58 KB/sec, 15921 bytes/write..
```

5. At last, in gdb, you can run the application by command `c`:
```
(gdb) c
Continuing.
(gdb) 
```

6. On a serial monitor configured on /dev/ttyUSB0 115200-8-N-1, you should see the following as OpenSBI starts:
```

OpenSBI v0.9
   ____                    _____ ____ _____
  / __ \                  / ____|  _ \_   _|
 | |  | |_ __   ___ _ __ | (___ | |_) || |
 | |  | | '_ \ / _ \ '_ \ \___ \|  _ < | |
 | |__| | |_) |  __/ | | |____) | |_) || |_
  \____/| .__/ \___|_| |_|_____/|____/_____|
        | |
        |_|

Platform Name             : ARIANE RISC-V
Platform Features         : timer,mfdeleg
```
This is followed by more OpenSBI output, and then the seL4 kernel itself boots:
```
Init local IRQ
Bootstrapping kernel
Initializing PLIC...
available phys memory regions: 1
  [80200000..c0000000]
```
This is followed by further output as tests are run, taking around an hour. Note that various "error" messages are expected as internal diagnostics are printed when the tests probe various edge-cases.

The run should finish with the reassuring:
```
Test suite passed. 121 tests passed. 42 tests disabled.
All is well in the universe
```
