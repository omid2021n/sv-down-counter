`timescale  1ns/1ps
module  ip_cnt_down_tb;

logic   rst_i;  
logic   clk_i;  
 
logic [7:0] load_val_i;  
logic load_i;
                      
logic dec_i;
int errors = 0;
//------------------------------AutoReload 0

logic [7:0] cnt_o_0; 
logic almost_done_o_0; 
logic done_o_0;
//------------------------------AutoReload 1

logic [7:0] cnt_o_1; 
logic almost_done_o_1; 
logic done_o_1;

//------------------------------Test  with  Autoreload(1)

ip_cnt_down  #(
.Width(8),
.AutoReload(1)

) dut_auto_1(

.rst_i(rst_i),  
.clk_i(clk_i), 
 
.load_val_i(load_val_i), 
.load_i(load_i),
                      
.dec_i(dec_i),

.cnt_o(cnt_o_1),
.almost_done_o(almost_done_o_1), 
.done_o(done_o_1)
);

//------------------------------Test  with  Autoreload(0)

ip_cnt_down  #(
.Width(8),
.AutoReload(0)

) dut_auto_0(

.rst_i(rst_i),  
.clk_i(clk_i), 
 
.load_val_i(load_val_i), 
.load_i(load_i),
                      
.dec_i(dec_i),

.cnt_o(cnt_o_0),
.almost_done_o(almost_done_o_0), 
.done_o(done_o_0)
);


///========================Clk  25 Mhz=================== 
initial  begin 
clk_i=1'b0;
forever #20 clk_i=~clk_i;
end
//=======================================================
task run_cont(input[7:0] c); 
@(negedge clk_i);
load_val_i =c;
dec_i=1'b1;
load_i=1'b1;
@(negedge clk_i);
load_i=1'b0;

endtask 
//=======================================================
initial  begin 
rst_i =1'b1;
load_i=1'b0;
dec_i =1'b0;
load_val_i=8'h00;
repeat(5) @(negedge clk_i);

rst_i=1'b0;

@(negedge  clk_i);

run_cont(8'd2);

@(negedge  clk_i);

run_cont(8'd5);

repeat (2) @(negedge clk_i);

dec_i = 1'b0;

repeat (4) @(negedge clk_i);

dec_i = 1'b1;

repeat (15) @(negedge clk_i);

//=============Report test
repeat (5) @(negedge clk_i);
if (errors == 0) $display("*** TEST PASSED ***");
else             $display("*** TEST FAILED: %0d errors ***", errors);
$finish;

end 


//===== SVA checks =====


// AutoReload = 1,done_o_1 must match the counter
  a_done_1: assert property (
    @(posedge clk_i) disable iff (rst_i)
      done_o_1 == (cnt_o_1 == 0)
  ) else begin
   $error("done_o_1 wrong: cnt=%0d done=%b", $sampled(cnt_o_1), $sampled(done_o_1));
    errors++;
  end

  // AutoReload = 1,almost_done_o_1 must match the counter
  a_almost_1: assert property (
    @(posedge clk_i) disable iff (rst_i)
      almost_done_o_1 == (cnt_o_1 <= 1)
  ) else begin
     $error("almost_done_o_1 wrong: cnt=%0d almost=%b", $sampled(cnt_o_1), $sampled(almost_done_o_1));
    errors++;
  end
// AutoReload = 0,done_o_0 must match the counter
  a_done_0: assert property (
    @(posedge clk_i) disable iff (rst_i)
      done_o_0 == (cnt_o_0 == 0)
  ) else begin
    $error("done_o_0 wrong: cnt=%0d done=%b", $sampled(cnt_o_0), $sampled(done_o_0));
    errors++;
  end

  // AutoReload = 0,almost_done_o_0 must match the counter
  a_almost_0: assert property (
    @(posedge clk_i) disable iff (rst_i)
      almost_done_o_0 == (cnt_o_0 <= 1)
  ) else begin
    $error("almost_done_o_0 wrong: cnt=%0d almost=%b", $sampled(cnt_o_0), $sampled(almost_done_o_0));
    errors++;
  end


//============================================
initial begin                       
  $dumpfile("ip_cnt_down_tb.vcd");
  $dumpvars(0, ip_cnt_down_tb);
end


endmodule 






