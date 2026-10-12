
// ip_cnt_down: down-counter with load, on-demand decrement and auto-reload.
//
// Design assumptions :
//  - AutoReload=1: reload happens when the counter is 0 AND dec_i=1.
//    The counter stays at 0 (done_o=1) until then.
//  - AutoReload=0: the counter stops at 0 (no wrap-around).
//  - dec_i works in both modes; only load_i is ignored when AutoReload=1.
//  - done_o and almost_done_o use the next counter value (count),
//    so they change on the same clock edge as cnt_o.

`timescale  1ns/1ps
module ip_cnt_down #(

 parameter  int  Width = 8,//Specifies width of load_val      

 parameter  int  AutoReload=1 //If set to '1' when counter reaches zero it autoreloads 
)(

input    logic   rst_i,//Active high reset  
input    logic   clk_i,//Main clock.  

input    logic [Width-1:0] load_val_i ,//Value to load into the counter. 
input    logic load_i,//When asserted, the value from load_val gets loaded into internal counter.

input    logic dec_i,//When asserted, internal counter gets decremented by 1 if current value not zero.

output  logic [Width-1:0] cnt_o,//Content of the internal counter. 
output  logic almost_done_o,//When asserted, internal counter value is equal to 1 or less. 
output  logic done_o//When asserted, internal counter value is equal to 0.

);

logic  [Width-1:0]count;

always_comb begin
  count = cnt_o;           
  if (load_i && !AutoReload)     count=load_val_i;
  else if (dec_i&& count != '0)   count =count -1;
  else if (AutoReload && dec_i &&  count=='0)              count =load_val_i;

end

always_ff @(posedge clk_i) begin
  if (rst_i) begin
    cnt_o         <= '0;
    done_o        <= 1'b1;
    almost_done_o <= 1'b1;
  end else begin
    cnt_o         <= count;
    done_o        <= (count==0);
    almost_done_o <= (count<=1);
  end
end
endmodule
