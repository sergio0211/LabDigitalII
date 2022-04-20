`timescale 1ns / 1ps
module sh_l_tb;
// Inputs
reg [2:0] portA;
reg init_sh_l;
reg clk;
reg rst;

// Outputs
wire [3:0] sal_sh_l;

// Instantiate the Unit Under Test (UUT)
sh_l uut (
  .portA(portA),
  .init_sh_l(init_sh_l),
  .clk(clk),
  .rst(rst),
  .sal_sh_l(sal_sh_l)
);


initial begin
  // Initialize Inputs
  init_sh_l = 0;
  clk = 0;
  rst = 1;
  portA = 5;

  // Wait 100 ns for global reset to finish
  #10;

  rst = 0;
  // Add stimulus here

  #40 init_sh_l = 1; #10 init_sh_l = 0;
  #40 init_sh_l = 1; #10 init_sh_l = 0;
  #40 init_sh_l = 1; #10 init_sh_l = 0;
  #40 init_sh_l = 1; #10 init_sh_l = 0;

  #10 rst = 1;

end

always #1 clk = ~clk;
initial begin: TEST_CASE
     $dumpfile("sh_l_tb.vcd");
     #(260) $stop;
   end

endmodule
