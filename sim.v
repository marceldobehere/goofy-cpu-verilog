module GoofySim;
    reg 	 clk = 0;
    reg      res = 0;
    always #2 clk = !clk;


    initial begin
    $dumpfile("dump.lxt");
    $dumpvars(0, GoofySim);
    $display("Starting simulation");

    $monitor("clk", clk);

    #10 $display("Simulation complete"); $finish;
    end

endmodule