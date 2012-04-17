module sim();

reg CLK, RST;
initial   CLK = 1'b0;
always #5 CLK = ~CLK; /* 100 MHz */

wire       tb_enable;
wire[7:0]  tb_wcount;
reg[7:0]   tb_word;
reg[7:0]   tb_key_length;
reg[7:0]   tb_interval;
wire       tb_valid;
wire[31:0] tb_hashkey;
wire       tb_onloop;

reg[31:0] ROM7[0:6];
reg[31:0] ROM12[0:11];
reg[31:0] ROM15[0:14];
reg[31:0] ROM100[0:99];
reg[31:0] ROM200[0:199];
reg[31:0] ROM250[0:249];

initial begin
  $readmemh("test/data/7.hex", ROM7);
  $readmemh("test/data/12.hex", ROM12);
  $readmemh("test/data/15.hex", ROM15);
  $readmemh("test/data/100.hex", ROM100);
  $readmemh("test/data/200.hex", ROM200);
  $readmemh("test/data/250.hex", ROM250);
end

hash hash
// #(
//   parameter maxwords = 250
// )
(
  .CLK(CLK)
, .RST(RST)
, .enable(tb_enable)
, .onloop(tb_onloop)
, .wcount(tb_wcount)
, .word(tb_word)
, .key_length(tb_key_length)
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

/* TASK: KEY_LENGTH=8'd15 */
task sim_n15;
begin
  simstart      = 1'b1;
  tb_key_length = 8'd15;
  tb_interval   = 8'b0;
end
endtask

always begin
  $dumpfile("hash.vcd");
  $dumpvars(0, sim.hash);

  RST = 1'b1;

  waitaclock;
  waitaclock;
  waitaclock;

  RST = 1'b0;

  waitaclock;

  sim_n15;

  #1000;

  $finish;
end

reg      simstart = 1'b0;
reg[7:0] count    = 8'b0;

always @(posedge CLK) begin
  if (simstart) begin
    count <= count + 8'b1;
    case (tb_key_length)
      8'd7:   tb_word <= ROM7[count];
      8'd12:  tb_word <= ROM12[count];
      8'd15:  tb_word <= ROM15[count];
      8'd100: tb_word <= ROM100[count];
      8'd200: tb_word <= ROM200[count];
      8'd250: tb_word <= ROM250[count];
    endcase
  end else
    count <= 8'b0;
end

assign tb_enable = (tb_word) ? 1'b1 : 1'b0;
assign tb_wcount = (tb_word) ? tb_wcount - 8'b1 : tb_key_length;
assign tb_onloop = (tb_wcount > 8'd12) ? 1'b1 : 1'b0;

endmodule

