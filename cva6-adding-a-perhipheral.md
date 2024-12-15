![Cap Ltd Logo](./img/CapLtdLogo.png)

# Adding a component to the CVA6 corev_apu SoC

This guide describes how to add a component to the default CVA6 SoC for FPGA on the Genesys 2 board.
This is required for devices that need to access one of the board's peripherals, and may also be suitable for accelerators for functionality taking several cycles to complete, i.e. when the co-processor interface is unsuitable.
The changes will be illustrated with examples that arose from changing over the Ethernet MAC from a lowRISC IP to the "AXI Ethernet" Xilinx IP, mostly within [this commit](https://github.com/Capabilities-Limited/cva6/commit/af2b8b52)).
Seeing the changes made in that commit will be useful for following along with this guide.
Note that the AXI Ethernet Xilinx component requires the Xilinx TEMAC license.

## The corev_apu framework

The framework is contained within the [`corev_apu`](https://github.com/Capabilities-Limited/cva6/tree/af2b8b52/corev_apu) subdirectory of the [CVA6](https://github.com/Capabilities-Limited/cva6/tree/af2b8b52/) repo.
This contains all the components required to generate an FPGA bitstream, suitable for targeting several different Xilinx FPGA boards.
Rather than using Vivado's XML or GUI to connect IPs, the platform performs all these connections in (System)Verilog, and presents a Verilog module as the top-level.

## Preparing the environment

We assume Vivado version 2020.1. You also need a RISC-V compiler for the device tree.
With those setup, the following command will build an FPGA image with the default configuration, when run from the cva6 [root directory](https://github.com/Capabilities-Limited/cva6/tree/af2b8b52/):

```sh
make fpga
```

This takes about an hour to run.
Many build artefacts (e.g. separate runs for different Xilinx IPs) are cached between runs.
However, Makefile dependencies are not fully set up, so `make clean`s may be required when changing files between runs.

## Adding the IP

The APU is laid out as shown below, with CVA6 (though the module is still called ariane) connected to a top-level bus (described in [ariane_xilinx.sv](https://github.com/Capabilities-Limited/cva6/tree/af2b8b52/corev_apu/fpga/src/ariane_xilinx.sv)), which then instantiates another bus for peripherals (in [ariane_peripherals_xilinx.sv](https://github.com/Capabilities-Limited/cva6/tree/af2b8b52/corev_apu/fpga/src/ariane_peripherals_xilinx.sv)).

TODO diagram

Since the Ethernet controller is a peripheral, and since the existing lowRISC IP is instantiated there, we will instantiate the Xilinx AXI Ethernet there also:

In [ariane_peripherals_xilinx.sv](https://github.com/Capabilities-Limited/cva6/commit/af2b8b52651278bfa813b66ce93aa0c106e87787#diff-afab9e4d855ccbd3fb324cf2ee13b65059fae8ebd3775f128c8a9ac9cff4673cR1009):
```diff
+        xlnx_axi_ethernet i_xlnx_axi_ethernet_mac (
+            .s_axi_lite_resetn      ( rst_ni                           ),
+            .s_axi_lite_clk         ( clk_i                            ),
+            // Omitting various other clock and reset connections
+            .s_axi_araddr           ( s_axi_lite_ethernet_mac_araddr   ),
+            .s_axi_arready          ( s_axi_lite_ethernet_mac_arready  ),
+            // Omitting various other AXI connections
+            .rgmii_rd               ( eth_rxd                          ),
+            .rgmii_rx_ctl           ( eth_rxctl                        ),
+            // Omitting various other external connections
+        );
```

Since the AXI Ethernet is a Xilinx component, we also add it to the existing infrastructure for adding Xilinx IPs to the project.
This exposes the Verilog template, allowing the above instantiation of the `xlnx_axi_ethernet` module to pick up the correct component during synthesis.
In particular, we add a build directory: [corev_apu/fpga/xilinx/xlnx_axi_ethernet/](https://github.com/Capabilities-Limited/tree/af2b8b52/corev_apu/fpga/xilinx/xlnx_axi_ethernet/).
We specialise the [tcl/run.tcl](https://github.com/Capabilities-Limited/cva6/commit/242ae5c52193df0c0c5e3b1bb994d7f5794638ad#diff-6118aa8d1a0140034dd0050f729a379538c069045b69d8c1f0aefbb4ad140783R1) file with specifics of the IP to instantiate as follows:

```diff
+ set ipName xlnx_axi_ethernet

// Skipping code not specific to added component

+ create_ip -name axi_ethernet -vendor xilinx.com -library ip -module_name $ipName
+ set_property -dict [ list CONFIG.PHY_TYPE {RGMII} \
+                    ] [get_ips $ipName]
```

In the above, the arguments to `create_ip` describe the component to be instantiated, and the `set_property` arguments pass the arguments that can specialise our particular IP: in our case telling the Mac that that the board has an "RGMII" Phy.

We then add the required references for the new IP to the Makefile and run.tcl scripts for the FPGA build as a whole.
The IP is also listed, again with parameters specialised, in ariane_xilinx_ip.yml:

```diff
+ xlnx_axi_ethernet:
+   ip: axi_ethernet
+   vendor: xilinx.com
+   config:
+     phy_type: RGMII
```

We do this same process to instantiate the Xilinx AXI FIFO component, required to provide a memory mapped way to read and write frame data to the MAC.

## Interface conversions

The Vivado system builder usually automatically handles conversions between different interconnect types (e.g. between AXI, AXI-Lite, and different data widths).
Since we are working in Verilog, we need to do this manually instead, but we can still use the Xilinx components to do the transformations.

## Defining the address map

We need to define the address map, so the buses can route correctly.
This is defined in [corev_apu/tb/ariane_soc_pkg.sv](https://github.com/Capabilities-Limited/tree/af2b8b52/corev_apu/tb/ariane_soc_pkg.sv).
Note: in the case of the AXI Ethernet, we are replacing the existing lowRISC Ethernet Mac that handles data and management with a separate FIFO (for data) and Mac (only used for management), so we separate those AXI mappings:

```diff
     SPIBase      = 64'h2000_0000,
-    EthernetBase = 64'h3000_0000,
+    EthernetDataBase = 64'h3000_0000,
+    EthernetMgmtBase = 64'h3800_0000,
     GPIOBase     = 64'h4000_0000,
```

```diff
   localparam logic[63:0] SPILength      = 64'h800000;
-  localparam logic[63:0] EthernetLength = 64'h10000;
+  localparam logic[63:0] EthernetDataLength = 64'h10000;
+  localparam logic[63:0] EthernetMgmtLength = 64'h40000;
   localparam logic[63:0] GPIOLength     = 64'h1000;
```

## Interrupts

For peripherals that provide interrupt lines, these can be connected up to the PLIC to then connect to the core.
A default `NumSources` is defined in ariane_soc, but this could be overridden if needed.
ariane_xilinx_peripherals.sv wires the unused ones to zero, so we needed to free an additional one to use for the AXI FIFO.
We can then connect the wires to the interrupt outputs of the peripherals.

## External connections and constraints

Since we are reusing the same connections as the lowRISC Ethernet MAC, we did not need to modify the external connections, but they are described here for completeness.
To connect to an external peripheral, we can add connections to the peripherals component and the top-level Verilog.
We then need constraints to ensure these get mapped to the correct pins on the FPGA and use the correct protocol and voltages.
The details about the connections for Genesys 2 can be found in the [manual](https://digilent.com/reference/programmable-logic/genesys-2/reference-manual).
Example constraints can also be found in the [Digilent Genesys 2 out-of-box demo](https://github.com/Digilent/Genesys-2-OOB/blob/master/src/constraints/Genesys2_H.xdc).

## Augmenting the device tree

The corev_apu framework builds and embeds a device tree, describing the hardware and address map to allow them to be automatically discovered by certain operating systems.
There is a separate device tree for 32-bit and 64-bit systems: we needed to make the same change to both of them.
Interrupt numbers are also described here: note that interrupt numbers exposed to software (one-based) are one higher than their index in the `irq_sources` vector (zero-based).

## Help with debugging

Adding peripherals can cause frustrating bugs, e.g. when interface connections don't quite line up, or peripherals don't behave as intended.
Ideally as many bugs as possible can be found by testing in simulation first.
For FPGA-specific bugs, we find it is always helpful to look through Vivado warnings to identify any issue of relevance.
These can be found scattered in various directories throughout the build, but recording the top-level log is useful too, e.g.

```sh
make fpga | tee buildlog.txt
```

As a final resort, adding in Xilinx's ILA probes (described in a separate document) allows monitoring of live signals onboard the FPGA, allowing issues to be bisected.
However, this does require a new synthesis every time the probed signals are changed.
