..
   Copyright 2024 Thales DIS France SAS
   Licensed under the Solderpad Hardware License, Version 2.1 (the "License");
   you may not use this file except in compliance with the License.
   SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
   You may obtain a copy of the License at https://solderpad.org/licenses/

   Original Author: Jean-Roch COULON - Thales
   Survey of parameters: Jonathan Woodruff - Capabilities Limited

.. _cva6_user_cfg_doc:

These are notes on parameterising both the cv32a65x ("cv32") and the cv64a6_imafdc_sv39 ("cv64") configurations.
For each parameter, we tested whether it could build with a change, and how performance
was affected in Dhrystone.
We tested the master branch of github.com/openhwgroup/cva6 from about 1 November 2024.
The repository was seeing frequent updates, so the current version is likely to be somewhat different from the snapshot in this study.

.. list-table:: ``cva6_user_cfg_t`` parameters
   :widths: 10 10 12 28
   :header-rows: 1

   * - Name
     - Type
     - Description
     - Notes

   * - ``XLEN``
     - ``int unsigned``
     - General Purpose Register Size (in bits)
     - Both cv64 and cv32 configurations built with opposite XLEN.

   * - ``RVA``
     - ``bit``
     - Atomic RISC-V extension
     - cv64 built and ran with this feature disabled.

   * - ``RVB``
     - ``bit``
     - Bit manipulation RISC-V extension
     - 

   * - ``RVV``
     - ``bit``
     - Vector RISC-V extension
     - I was not able to build with this extension enabled on cv64. I copied a configuration that claimed to support it, notably disabling the cvxif interface example, which is required for the vector extension, but it still failed to build at this time.

   * - ``RVC``
     - ``bit``
     - Compress RISC-V extension
     - cv64 built without compressed instructions, but Dhrystone failed to run, as it still used compressed instructions.

   * - ``RVH``
     - ``bit``
     - Hypervisor RISC-V extension
     - 

   * - ``RVZCB``
     - ``bit``
     - Zcb RISC-V extension
     - cv64 built and ran with Zcp disabled.

   * - ``RVZCMP``
     - ``bit``
     - Zcmp RISC-V extension
     - cv64 built and ran with Zcmp enabled (it was disabled by default).

   * - ``RVZiCond``
     - ``bit``
     - Zicond RISC-V extension
     - 

   * - ``RVZicntr``
     - ``bit``
     - Zicntr RISC-V extension
     - 

   * - ``RVZihpm``
     - ``bit``
     - Zihpm RISC-V extension
     - 

   * - ``RVF``
     - ``bit``
     - Floating Point
     - cv64 built and ran without RVF.  Performance was equivalant for Dhrystone, so no performance cost for enabling floating point.

   * - ``RVD``
     - ``bit``
     - Floating Point
     - cv64 built and ran without RVD. Performance was equivalant for Dhrystone.  RVF is required for RVD; RVD didn't build with RVD disabled.

   * - ``XF16``
     - ``bit``
     - Non standard 16bits Floating Point extension
     - 

   * - ``XF16ALT``
     - ``bit``
     - Non standard 16bits Floating Point Alt extension
     - 

   * - ``XF8``
     - ``bit``
     - Non standard 8bits Floating Point extension
     - 

   * - ``XFVec``
     - ``bit``
     - Non standard Vector Floating Point extension
     - 

   * - ``PerfCounterEn``
     - ``bit``
     - Perf counters
     - rv32 and rv64 built and ran without PerfCounterEn, and got equivalant performance.

   * - ``MmuPresent``
     - ``bit``
     - MMU
     - rv32 worked with enabled MMU, and rv64 worked with disabled MMU, and both ran Dhrystone with no change in performance.

   * - ``RVS``
     - ``bit``
     - Supervisor mode
     - 

   * - ``RVU``
     - ``bit``
     - User mode
     - 

   * - ``DebugEn``
     - ``bit``
     - Debug support
     - Enabling debug in cv32 slowed down performance by about 10\%.

   * - ``DmBaseAddress``
     - ``logic [63:0]``
     - Base address of the debug module
     - 

   * - ``HaltAddress``
     - ``logic [63:0]``
     - Address to jump when halt request
     - 

   * - ``ExceptionAddress``
     - ``logic [63:0]``
     - Address to jump when exception
     - 

   * - ``TvalEn``
     - ``bit``
     - Tval Support Enable
     - cv64 built and ran without TvalEn.  No change in performance.

   * - ``DirectVecOnly``
     - ``bit``
     - MTVEC CSR supports only direct mode
     - 

   * - ``NrPMPEntries``
     - ``int unsigned``
     - PMP entries number
     - Both cv32 and cv64 successfully built with 0 PMP entries (from 8) with no change in performance.

   * - ``PMPCfgRstVal``
     - ``logic [63:0][63:0]``
     - PMP CSR configuration reset values
     - 

   * - ``PMPAddrRstVal``
     - ``logic [63:0][63:0]``
     - PMP CSR address reset values
     - 

   * - ``PMPEntryReadOnly``
     - ``bit [63:0]``
     - PMP CSR read-only bits
     - 

   * - ``NrNonIdempotentRules``
     - ``int unsigned``
     - PMA non idempotent rules number
     - 

   * - ``NonIdempotentAddrBase``
     - ``logic [NrMaxRules-1:0][63:0]``
     - PMA NonIdempotent region base address
     - 

   * - ``NonIdempotentLength``
     - ``logic [NrMaxRules-1:0][63:0]``
     - PMA NonIdempotent region length
     - 

   * - ``NrExecuteRegionRules``
     - ``int unsigned``
     - PMA regions with execute rules number
     - 

   * - ``ExecuteRegionAddrBase``
     - ``logic [NrMaxRules-1:0][63:0]``
     - PMA Execute region base address
     - 

   * - ``ExecuteRegionLength``
     - ``logic [NrMaxRules-1:0][63:0]``
     - PMA Execute region address base
     - 

   * - ``NrCachedRegionRules``
     - ``int unsigned``
     - PMA regions with cache rules number
     - 

   * - ``CachedRegionAddrBase``
     - ``logic [NrMaxRules-1:0][63:0]``
     - PMA cache region base address
     - 

   * - ``CachedRegionLength``
     - ``logic [NrMaxRules-1:0][63:0]``
     - PMA cache region rules
     - 

   * - ``CvxifEn``
     - ``bit``
     - CV-X-IF coprocessor interface enable
     - cv64 built and ran with Cvxif disabled.  Performance was unchanged.

   * - ``NOCType``
     - ``noc_type_e``
     - NOC bus type
     - 

   * - ``AxiAddrWidth``
     - ``int unsigned``
     - AXI address width
     - 

   * - ``AxiDataWidth``
     - ``int unsigned``
     - AXI data width
     - cv32 did not build with AxiDataWidth changed from 64 to 128. This may be due to the simulation infrastructure rather than the core itself.

   * - ``AxiIdWidth``
     - ``int unsigned``
     - AXI ID width
     - 

   * - ``AxiUserWidth``
     - ``int unsigned``
     - AXI User width
     - 

   * - ``AxiBurstWriteEn``
     - ``bit``
     - AXI burst in write
     - cv32 worked with AxiBurstWriteEn turned on, but performance did not change.

   * - ``MemTidWidth``
     - ``int unsigned``
     - TODO
     - 

   * - ``IcacheByteSize``
     - ``int unsigned``
     - Instruction cache size (in bytes)
     - Both cv32 and cv64 built and ran with a range of ICacheSizes. Non-power-of-two sizes behave like the next biggest power-of-two. It's unknown why larger than 2048 slows down on cv64 for Dhrystone.

       .. image:: img/Cycles_vs_Instruction_Cache_Size_in_cv32a65x.png
         :width: 400
       .. image:: img/Cycles_vs_Instruction_Cache_Size_in_cv64a6_imafdc_sv39.png
         :width: 400

   * - ``IcacheSetAssoc``
     - ``int unsigned``
     - Instruction cache associativity (number of ways)
     - Both cv32 and cv64 built and ran with a range of ICacheSizes. Non-power-of-two sizes appear to work as expected.

       .. image:: img/Cycles_vs_Instruction_Cache_Set_Associativity_in_cv32a65x.png
         :width: 400
       .. image:: img/Cycles_vs_Instruction_Cache_Associativity_cv64a6_imafdc_sv39.png
         :width: 400

   * - ``IcacheLineWidth``
     - ``int unsigned``
     - Instruction cache line width
     - Instruction cache line width was parameterisable in both cv32 and cv64 with surprising improvements of performance for Dhrystone, likely because of spatial locality of instructions and a very small code footprint. The default line width is 128 bytes, which is slightly larger than usual, and 64 did not build for cv32, but did build for cv64.

       .. image:: img/Cycles_vs_Instruction_Cache_Line_Width_in_cv32a65x.png
         :width: 400
       .. image:: img/Cycles_vs_Instruction_Cache_Line_Width_in_cv64a6_imafdc_sv39.png
         :width: 400

   * - ``DCacheType``
     - ``cache_type_t``
     - Cache Type
     - There are three options; writethrough, writeback, and high performance, which is capable of reordering. Cv64 didn't compile with the high-performance option. Writeback is likely slower due to blocking on writes until the line is filled, while the out-of-order cache can fill for a write while still servicing reads.

       .. image:: img/Cycles_vs_Data_Cache_Type_cv32a65x.png
         :width: 400
       .. image:: img/Cycles_vs_Data_Cache_Type_cv64a6_imafdc_sv39.png
         :width: 400

   * - ``DcacheIdWidth``
     - ``int unsigned``
     - Data cache ID
     - Both cv32 and cv64 built with an ID of 2 rather than 1, but performance was unchanged. We did not determine the function of the cache ID.

   * - ``DcacheByteSize``
     - ``int unsigned``
     - Data cache size (in bytes)
     - A wide range of data cache sizes built and ran Dhrystone, but Dhrystone performance did not appear to be sensitive to data cache size.

       .. image:: img/Cycles_vs_Data_Cache_Byte_Size_cv32a65x.png
         :width: 400
       .. image:: img/Cycles_vs_Data_Cache_Byte_Size_cv64a6_imafdc_sv39.png
         :width: 400

   * - ``DcacheSetAssoc``
     - ``int unsigned``
     - Data cache associativity (number of ways)
     - Data cache associativity was parameterisable to any value we tried.  As cv64 had a 32KiB cache by default, and 8-way associative, performance did not meaningfully change with associativity changes.

       .. image:: img/Cycles_vs_Data_Cache_Assosciativity_cv32a65x.png
         :width: 400

   * - ``DcacheLineWidth``
     - ``int unsigned``
     - Data cache line width
     - Both cv32 and cv64 built with a range of data cache line widths, though cv64 did not build with 64-byte data cache lines.

       .. image:: img/Cycles_vs_Data_Cache_Line_Width_cv32a65x.png
         :width: 400
       .. image:: img/Cycles_vs_Data_Cache_Line_Width_cv64a6_imafdc_sv39.png
         :width: 400

   * - ``DataUserEn``
     - ``int unsigned``
     - User field on data bus enable
     - cv32 built and ran with this changed from 1 to 0.

   * - ``WtDcacheWbufDepth``
     - ``int unsigned``
     - Write-through data cache write buffer depth
     - cv32 did not build with 16-entry cache.  Also, performance was affected by changing cv32 from 8 to 4 despite the cache type for cv32 being HPDCACHE (High-performance Data Cache) by default.

       .. image:: img/Cycles_vs_Data_Cache_Write_Buffer_Depth_cv32a65x.png
         :width: 400
       .. image:: img/Cycles_vs_Data_Cache_Write_Buffer_Depth_cv64a6_imafdc_sv39.png
         :width: 400

   * - ``FetchUserEn``
     - ``int unsigned``
     - User field on fetch bus enable
     - cv64 built with this turned off.  Perforformance was not affected.

   * - ``FetchUserWidth``
     - ``int unsigned``
     - Width of fetch user field
     - 

   * - ``FpgaEn``
     - ``bit``
     - Is FPGA optimization of CV32A6
     - 

   * - ``TechnoCut``
     - ``bit``
     - Is Techno Cut instanciated
     - Turning this from off to on for cv64 worked and ran Dhrystone, but did not change performance.

   * - ``SuperscalarEn``
     - ``bit``
     - Enable superscalar* with 2 issue ports and 2 commit ports.
     - cv32a65x (called cv32 here) has this on by default, and cv64a6_imafdc_sv39 (called cv64 here) has this off by default. SuperscalarEn doesn't currently work in conjunction with floating point extensions (F, D), so I turned off CVA6ConfigRVF for cv64 and was able to enable SuperscalarEn to test that 64-bit superscalar is possible and achieves the expected performance, which is a 17\% decrease in cycles in Dhrystone.

       .. image:: img/Cycles_vs_Superscalar_Enable_cv32a65x.png
         :width: 400
       .. image:: img/Cycles_vs_Superscalar_Enable_cv64a6_imafdc_sv39.png
         :width: 400

   * - ``NrCommitPorts``
     - ``int unsigned``
     - Number of commit ports. Forced to 2 if SuperscalarEn.
     - This parameter had no effect on superscalar cv32, as suggested in the note in the previous cell.

   * - ``NrLoadPipeRegs``
     - ``int unsigned``
     - Load cycle latency number
     - This was parametrisable for both cv32 and cv64 in the options that we tried.  The latency for cv32 was 0 by default, and the latency for cv64 was 1 by default.

       .. image:: img/Cycles_vs_Number_of_Load_Pipe_Registers_cv32a65x.png
         :width: 400
       .. image:: img/Cycles_vs_Number_of_Load_Pipe_Registers_cv64a6_imafdc_sv39.png
         :width: 400

   * - ``NrStorePipeRegs``
     - ``int unsigned``
     - Store cycle latency number
     - The build succeeds when this option is set from 0 to 1, but the benchmark does not run.  There seems to have been a bug.

   * - ``NrScoreboardEntries``
     - ``int unsigned``
     - Scoreboard length
     - This parameter only works for powers-of-two.  Other values build, but we seem to lock up at run time. We seem to reach full performance at 8 entries.

       .. image:: img/Cycles_vs_Number_of_Scoreboard_Entries_cv32a65x.png
         :width: 400
       .. image:: img/Cycles_vs_Number_of_Scoreboard_Entries_cv64a6_imafdc_sv39.png
         :width: 400

   * - ``NrLoadBufEntries``
     - ``int unsigned``
     - Load buffer entry buffer
     - Dhrystone seemed almost completely insensitive to this number.  The superscalar cv32 lost 0.37% performance when it was reduced from 2 to 1, but single-issue cv64 did not lose any performance with one entry.  Also, larger numbers of entries did not help cv64, and did not build on cv32.

   * - ``MaxOutstandingStores``
     - ``int unsigned``
     - Maximum number of outstanding stores
     - This parameter did not affect performance in cv32 in the simulator setup.  We might assume that the simplified memory for simulation might not expose the effects of high-lantency memory.

   * - ``RASDepth``
     - ``int unsigned``
     - Return address stack depth
     - This operand built and ran with a few different options for cv32 and cv64.  The default parameter is 2, but even Dhrystone benefits from at least 3.  Maybe timing or area prevents a more generous allocation?

       .. image:: img/Cycles_vs_Return_Address_Stack_Depth_cv32a65x.png
         :width: 400
       .. image:: img/Cycles_vs_Return_Address_Stack_Depth_cv64a6_imafdc_sv39.png
         :width: 400

   * - ``BTBEntries``
     - ``int unsigned``
     - Branch target buffer entries
     - This parameter had nearly no effect in either cv32 or cv64 with Dhrystone.  The default for cv32 is 0; we didn't yet investigate what this means, but there was no improvement from changing to 4.  cv64 has 32, but changing it to 2 also did not change performance.  We might assume for now that Dhrystone uses only direct jumps and returns, and therefore does not exercise the BTB at all.

   * - ``BHTEntries``
     - ``int unsigned``
     - Branch history entries
     - This was a very flexible parameter, where even non-power-of-two values appeared to give some benefit.  cv32 had 32 entries by default, and cv64 had 128.  Dhrystone consistently showed benefit from increasing the size of this table; bigger benchmarks would likely be even more sensitive.

       .. image:: img/Cycles_vs_Branch_History_Table_Entries_in_cv32a65x.png
         :width: 400
       .. image:: img/Cycles_vs_Branch_History_Table_Entries_in_cv64a6_imafdc_sv39.png
         :width: 400

   * - ``InstrTlbEntries``
     - ``int unsigned``
     - MMU instruction TLB entries
     - Parameters of 1 to 4 built and ran Dhrystone; performance didn't change, as virtual memory was not being used.

   * - ``DataTlbEntries``
     - ``int unsigned``
     - MMU data TLB entries
     - Parameters of 1 to 4 built and ran Dhrystone; performance didn't change, as virtual memory was not being used.

   * - ``UseSharedTlb``
     - ``bit unsigned``
     - MMU option to use shared TLB
     - cv32 uses this option, enabling the shared TLB (or "level 2" TLB), but cv64 does not, curiously.

   * - ``SharedTlbDepth``
     - ``int unsigned``
     - MMU depth of shared TLB
     - Both cv32 and cv64 are configured with a depth of 64, though "UseSharedTlb" is not enabled in cv64.
