module sim();

reg clk, rst;
initial   clk = 1'b0;
always #6 clk = ~clk; /* 83.333 MHz */

reg[31:0]  tb_k0, tb_k1, tb_k2;
reg        tb_enable;
reg[7:0]   tb_key_length;
wire[31:0] tb_hashkey;

hash hash (
  .CLK(clk)
, .RST(rst)
, .charcnt(tb_charcnt)
, .char(tb_char)
, .hashkey(tb_hashkey)
);

task waitaclock;
begin
  @(posedge clk);
  #1;
end
endtask

task word250;
  input [7:0] wc;
  input [2000:1] key;
begin
  tb_key_length = wc;
end
endtask

always begin
  $dumpfile("hash.vcd");
  $dumpvars(0, sim.hash);

  rst = 1'b1;

  waitaclock;

  rst = 1'b0;

  waitaclock;

  word250(8'd3, "abc");
  word250(8'd12, "abcdefghijkl");
  word250(8'd15, "abcdefghijklmno");
  word250(8'd100, "abcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrst");
  word250(8'd200, "abcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrst");
  word250(8'd250, "abcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghijklmnopqrstabcdefghij");

  #1000;

  $finish;
end


endmodule

