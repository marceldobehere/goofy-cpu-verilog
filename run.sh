set -e

xxd -p -c 1 files/inc_hlt.bin > files/inc_hlt.hex
xxd -p -c 8 files/microcode.bin > files/microcode.hex

iverilog -o ./res/sim -DMICROCODE=\"./files/microcode.hex\" -DRAM=\"./files/inc_hlt.hex\" src/*.v sim.v
vvp ./res/sim -lxt2
read -p "Press enter to continue"
gtkwave --save ./files/view.gtkw dump.lxt