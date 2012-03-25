module sim();

reg clk, rst;
initial   clk = 1'b0;
always #6 clk = ~clk; /* 83.333 MHz */

reg[31:0]  tb_k0, tb_k1, tb_k2;
reg[7:0]   tb_key_length;
reg        tb_enable = 1'b0;

wire[31:0] tb_hashkey;
wire tb_complete;

hash hash (
  .CLK(clk)
, .RST(rst)
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

parameter[1:0] s0 = 2'b00 //idle
             , s1 = 2'b01
             , s2 = 2'b10
             , s3 = 2'b11;

reg[1:0]    state = s0;
reg[11:0]   wp;
reg[2000:1] key;

always @(posedge clk) begin
  if (rst) begin
    state <= s0;
    wp    <= 11'b0;
    key   <= 2000'b0;
  end else begin
    if (tb_enable)
      state <= s1;
    case (state)
      s1: begin
        wp <= wp - 96;
        if (wp > 7'd96) begin
          tb_k0 <= key[wp :- 7'd32];
          tb_k1 <= key[wp :- 7'd64];
          tb_k2 <= key[wp :- 7'd96];
        end else if (wp > 64) begin
          tb_k0 <= key[wp :- 7'd32];
          tb_k1 <= key[wp :- 7'd64];
          tb_k2 <= 31'b0;
        end else if (wp > 32) begin
          tb_k0 <= key[wp :- 7'd32];
          tb_k1 <= 31'b0;
          tb_k2 <= 31'b0;
        end else begin
          state     <= s0;
          tb_enable <= 1'b0;
        end
      end
    endcase
  end
end

endmodule

