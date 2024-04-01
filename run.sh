set -e

iverilog -o ./res/sim -DMICROCODE=\"./files/microcode.bin\" -DRAM=\"./files/ram.bin\" -DROM=\"./files/inc_hlt.bin\" src/*.v sim.v
vvp ./res/sim -lxt2
read -p "Press enter to continue"
gtkwave dump.lxt