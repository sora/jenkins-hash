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
, .enable(tb_enable)
, .key_length(tb_key_length)
, .k0(tb_k0)
, .k1(tb_k1)
, .k2(tb_k2)
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

reg       enable;
reg[3:0]  count12;
reg[10:0] count;

always @(posedge clk) begin
  if (rst) begin
    count   <= 11'b0;
    count12 <= 4'b0;
    enable  <= 1'b0;
  end else begin
    if (enable) begin
      case (count12)
        4'b0000: tb_k0[31:24] <= piece;
        4'b0001: tb_k0[23:16] <= piece;
        4'b0010: tb_k0[15:8]  <= piece;
        4'b0011: tb_k0[7:0]   <= piece;
        4'b0100: tb_k1[31:24] <= piece;
        4'b0101: tb_k1[23:16] <= piece;
        4'b0110: tb_k1[15:8]  <= piece;
        4'b0111: tb_k1[7:0]   <= piece;
        4'b1000: tb_k2[31:24] <= piece;
        4'b1001: tb_k2[23:16] <= piece;
        4'b1010: tb_k2[15:8]  <= piece;
        4'b1011: tb_k2[7:0]   <= piece;
      endcase

      if (count12 == 4'b1100) begin
        count12 <= 4'b0;
        tb_k0   <= 32'b0;
        tb_k1   <= 32'b0;
        tb_k2   <= 32'b0;
      end else
        count12 <= count12 + 4'b1;

      if (count == key_length) begin
        enable  <= 1'b0;
        count   <= 11'b0;
        count12 <= 4'b0;
        tb_k0   <= 32'b0;
        tb_k1   <= 32'b0;
        tb_k2   <= 32'b0;
      end else
        count <= count + 11'b1;

    end
  end
end

always @*
  tb_enable = (count12 == 4'b1100) ? 1'b1 : 1'b0;

endmodule

