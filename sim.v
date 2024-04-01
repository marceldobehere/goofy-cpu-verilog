module GoofySim;
    reg 	 clk = 0;
    reg      res = 1;
    wire hlt;
    always #2 clk = hlt ? clk : !clk;
    
    // Core
    GoofyCore core (
        clk,
        res,
        hlt
    );

    initial begin
    $dumpfile("dump.lxt");
    $dumpvars(0, GoofySim);
    $display("Starting simulation");

    $monitor("clk: %h, state: %h, rip:%h [%h %h %h], mc:%h (%h) [%h], f: %h", 
        clk, core.state, 
        core.rip, core.iop, core.op0, core.op1, 
        core.mc_counter, core.mc_addr, core.mc_out, core.mc_finish
        
    );

    #4 res = 0;

    #100 $finish;
    end

endmodule