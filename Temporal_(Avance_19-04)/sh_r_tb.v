`timescale 1ns / 1ps
module sh_r_tb;
// Inputs
reg [2:0] portB;
reg init_sh_r;
reg clk;
reg rst;

// Outputs
wire [3:0] sal_sh_r;

// Instantiate the Unit Under Test (UUT)
sh_r uut (
  .portB(portB),
  .init_sh_r(init_sh_r),
  .clk(clk),
  .rst(rst),
  .sal_sh_r(sal_sh_r)
);


initial begin
  // Initialize Inputs
  init_sh_r = 0;
  clk = 0;
  rst = 1;
  portB = 5;

  // Wait 100 ns for global reset to finish
  #10;

  rst = 0;
  // Add stimulus here

  #40 init_sh_r = 1; #10 init_sh_r = 0;
  #40 init_sh_r = 1; #10 init_sh_r = 0;
  #40 init_sh_r = 1; #10 init_sh_r = 0;
  #40 init_sh_r = 1; #10 init_sh_r = 0;

  #10 rst = 1;

end

always #1 clk = ~clk;
initial begin: TEST_CASE
     $dumpfile("sh_r_tb.vcd");
     #(260) $stop;
   end

endmodule
