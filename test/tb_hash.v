`timescale 1ns / 1ns
`define dbg  1

module sim();
reg       tb_enable = 1'b0;
reg[7:0]  tb_key_length;
reg[31:0] tb_k0, tb_k1, tb_k2;

wire CLK;
wire RST;
wire[31:0] tb_hashkey;
wire tb_complete;

clock clock (
  .CLK(CLK)
, .RST(RST)
);

lookup3 lookup3 (
  .CLK(CLK)
, .RST(RST)
, .key_length(tb_key_length)
, .k0(tb_k0)
, .k1(tb_k1)
, .k2(tb_k2)
, .hashkey(tb_hashkey)
);

initial begin
  #100 tb_enable = 1'b1; tb_key_length = 4'hd; tb_k0 = "abcd"; tb_k1 = "efgh"; tb_k2 = "ijkl";
  #100 tb_enable = 1'b1; tb_key_length = 4'hd; tb_k0 = "abcd"; tb_k1 = "efgh"; tb_k2 = "ijkl";
  #100 tb_enable = 1'b1; tb_key_length = 4'hd; tb_k0 = "abcd"; tb_k1 = "efgh"; tb_k2 = "ijkl";
  #100 $finish;
end

initial begin
  $dumpfile("lookup3.vcd");
  $dumpvars(0, sim.lookup3);
end

always @(posedge CLK) begin
  if (RST)
    tb_enable <= 1'b0;
  else begin
    if (tb_hashkey)
      $display("key: %s, hashkey: %h", {tb_k0, tb_k1, tb_k2}, tb_hashkey);
    if (tb_enable)
      tb_enable <= 1'b0;
  end
end

endmodule // sim()

module clock (
  output reg CLK
, output reg RST
);

initial CLK = 1'b0;
initial RST = 1'b0;
always #1 begin
  CLK <= ~CLK;
  RST <= 1'b0;
end
endmodule

