module sim();

reg CLK, RST;
initial   CLK = 1'b0;
always #6 CLK = ~CLK; /* 83.333 MHz */

reg        tb_enable;
reg        tb_onloop;
reg[7:0]   tb_wcount;
reg[7:0]   tb_word;
reg[7:0]   tb_key_length;
reg[7:0]   tb_interval;
wire       tb_valid;
wire[31:0] tb_hashkey;

reg[31:0] ROM7[0:6];
reg[31:0] ROM12[0:11];
reg[31:0] ROM15[0:14];
reg[31:0] ROM100[0:99];
reg[31:0] ROM200[0:199];
reg[31:0] ROM250[0:249];

initial begin
  $readmemh("7.hex", ROM7);
  $readmemh("12.hex", ROM12);
  $readmemh("15.hex", ROM15);
  $readmemh("100.hex", ROM100);
  $readmemh("200.hex", ROM200);
  $readmemh("250.hex", ROM250);
end

hash hash (
  .CLK(CLK)
, .RST(rst)
, .enable(tb_enable)
, .onloop(tb_onloop)
, .wcount(tb_wcount)
, .word(tb_word)
, .key_length(tb_length)
, .interval(tb_interval)
, .valid(tb_valid)
, .hashkey(tb_hashkey)
);

task waitaclock;
begin
  @(posedge CLK);
  #1;
end
endtask

task sim_n7;
begin
  tb_enable     = 1'b1;
  tb_onloop     = 1'b1;
  tb_wcount     = 8'd8;
  tb_key_length = 8'd8;
  tb_interval   = 8'b0;
end
endtask

always begin
  $dumpfile("hash.vcd");
  $dumpvars(0, sim.hash);

  rst = 1'b1;

  waitaclock;

  rst = 1'b0;

  waitaclock;

  sim_n7;

  #1000;

  $finish;
end

always @(posedge CLK) begin
  if (RST)
    word
  else begin
    case (tb_key_length)
      8'd7:   tb_word <= ROM7[count];
      8'd12:  tb_word <= ROM12[count];
      8'd15:  tb_word <= ROM15[count];
      8'd100: tb_word <= ROM100[count];
      8'd200: tb_word <= ROM200[count];
      8'd250: tb_word <= ROM250[count];
    endcase
  end
end

endmodule

