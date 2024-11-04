![Cap Ltd Logo](./img/CapLtdLogo.png)

# Executing and debugging a Verilator RTL simulation of CVA6

## Preparing the environment

The setup-env.sh script from the cva6 repo expects the RISCV environment variable to be set, and a "verilator" directory.

```sh
export RISCV=~/riscv-tools
echo "export RISCV=~/riscv-tools" >> ~/.bashrc
cd ~/cva6
rm -rf tools/verilator
ln -s ~/cva6/tools/verilator-v5.008 tools/verilator
```

## Running a simulation

You can now use the cva6.py script to run a standalone simulation:
```sh
cd ~/cva6/verif/sim
export DV_SIMULATORS=veri-testharness
export TRACE_FAST=1
python3 cva6.py --target cv64a6_imafdc_sv39 --iss=$DV_SIMULATORS \
--iss_yaml=cva6.yaml --c_tests ../tests/custom/hello_world/hello_world.c \
--linker=../tests/custom/common/test.ld \
--gcc_opts="-static -mcmodel=medany -fvisibility=hidden -nostdlib \
-nostartfiles -g ../tests/custom/common/syscalls.c \
../tests/custom/common/crt.S -lgcc \
-I../tests/custom/env -I../tests/custom/common"
```

This allows inspection of the instruction trace in this file:

```sh
cd ~/cva6
cat cva6/verif/sim/out_*/veri-testharness_sim/hello_world.cv64a6_imafdc_sv39.log
```

For a full waveform trace:
```sh
sudo apt install gtkwave
gtkwave /home/user/cva6/verif/sim/out_*/veri-testharness_sim/*.vcd &
```

The most interesting signals are under ariane_testharness.i_ariane.i_cva6.  For example, pc_commit[63:0] in that module.  This can be clicked and dragged into the "signals" pane to display it on the waveform timeline.
