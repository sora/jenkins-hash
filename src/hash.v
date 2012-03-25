/*
 * hash.v by Yohei Kuga <sora@haeena.net>
 * A jenkinks hash function in Verilog-HDL
 *
 * Original code in C by Bob Jenkins, 1996
 * http://burtleburtle.net/bob/c/lookup3.c
 */

module hash_r1 (
  input CLK
, input RST
, input [31:0] ia
, input [31:0] ib
, input [31:0] ic
, input [31:0] k0
, input [31:0] k1
, input [31:0] k2
, input [7:0]  iw
, output reg[31:0] oa
, output reg[31:0] ob
, output reg[31:0] oc
, output reg[7:0]  ow
);

reg[31:0] a0, b0, c0;
reg[31:0] a1, b1, c1;
reg[31:0] a2, b2, c2;
reg[31:0] a3, b3, c3;
reg[7:0]  w0, w1, w2, w3;

wire[7:0]  next_w0 = iw - 8'd12;
wire[31:0] next_a0 = ia + k0;
wire[31:0] next_b0 = ib + k1;
wire[31:0] next_c0 = ic + k2;
wire[31:0] next_a1 = (a0 - c0) ^ {c0[27:0], c0[31:28]};
wire[31:0] next_c1 = c0 + b0;
wire[31:0] next_a2 = a1 + c1;
wire[31:0] next_c2 = (c1 - b1) ^ {b1[23:0], b1[31:24]};
wire[31:0] next_a3 = (a2 - c2) ^ {c2[15:0], c2[31:16]};
wire[31:0] next_c3 = c2 + b2;
wire[31:0] next_a4 = a3 + c3;
wire[31:0] next_c4 = (c3 - b3) ^ {b3[27:0], b3[31:28]};

always @(posedge CLK) begin
  if (RST) begin
    oa <= 32'b0;
    ob <= 32'b0;
    oc <= 32'b0;
    ow <= 8'b0;
  end else begin
    if (iw > 8'd12) begin
      a0 <= next_a0;
      c0 <= next_c0;
      b0 <= next_b0;
      w0 <= next_w0;
      a1 <= next_a1;
      c1 <= next_c1;
      b1 <= (b0 - next_a1) ^ {next_a1[25:0], next_a1[31:26]};
      w1 <= w0;
      a2 <= next_a2;
      c2 <= next_c2;
      b2 <= b1 + next_a2;
      w2 <= w1;
      a3 <= next_a3;
      c3 <= next_c3;
      b3 <= (b2 - next_a3) ^ {next_a3[12:0], next_a3[31:13]};
      w3 <= w2;
      oa <= next_a4;
      ob <= next_c4;
      oc <= b3 + next_a4;
      ow <= w3;
    end else begin
      a0 <= ia;
      c0 <= ic;
      b0 <= ib;
      w0 <= iw;
      a1 <= a0;
      c1 <= c0;
      b1 <= b0;
      w1 <= w0;
      a2 <= a1;
      c2 <= c1;
      b2 <= b1;
      w2 <= w1;
      a3 <= a2;
      c3 <= c2;
      b3 <= b2;
      w3 <= w2;
      oa <= a3;
      ob <= b3;
      oc <= c3;
      ow <= w3;
    end
  end
end
endmodule

module hash_r2 (
  input CLK
, input RST
, input [31:0] ia
, input [31:0] ib
, input [31:0] ic
, input [31:0] k0
, input [31:0] k1
, input [31:0] k2
, input [7:0]  iw
, output reg[31:0] o
);

reg[31:0] a0, b0, c0;
reg[31:0] a1, b1, c1;
reg[31:0] a2, b2, c2;
reg[31:0] next_a0, next_b0, next_c0;

wire[31:0] next_c1 = (c0 ^ b0) - {b0[17:0], b0[31:18]};
wire[31:0] next_a1 = (a0 ^ next_c1) - {next_c1[20:0], next_c1[31:21]};
wire[31:0] next_c2 = (c1 ^ b1) - {b1[15:0], b1[31:16]};
wire[31:0] next_a2 = (a1 ^ next_c2) - {next_c2[27:0], next_c2[31:28]};

always @(posedge CLK) begin
  if (RST)
    o <= 1'b0;
  else begin
    if (iw) begin
      c0 <= next_c0;
      a0 <= next_a0;
      b0 <= next_b0;
      c1 <= next_c1;
      a1 <= next_a1;
      b1 <= (b0 ^ next_a1) - {next_a1[6:0], next_a1[31:7]};
      c2 <= next_c2;
      a2 <= next_a2;
      b2 <= (b1 ^ next_a2) - {next_a2[17:0], next_a2[31:18]};
      o  <= (c2 ^ b2) - {b2[7:0], b2[31:8]};
    end else begin
      c0 <= ic;
      a0 <= ia;
      b0 <= ib;
      c1 <= c0;
      a1 <= a0;
      b1 <= b0;
      c2 <= c1;
      a2 <= a1;
      b2 <= b1;
      o  <= c2;
    end
  end
end

always @* begin
  case (iw)
    8'd12: begin
      next_c0 <= ic + k2;
      next_b0 <= ib + k1;
      next_a0 <= ia + k0;
    end
    8'd11: begin
      next_c0 <= ic + k2 & 32'h00FFFFFF;
      next_b0 <= ib + k1;
      next_a0 <= ia + k0;
    end
    8'd10: begin
      next_c0 <= ic + k2 & 32'h0000FFFF;
      next_b0 <= ib + k1;
      next_a0 <= ia + k0;
    end
    8'd9: begin
      next_c0 <= ic + k2 & 32'h000000FF;
      next_b0 <= ib + k1;
      next_a0 <= ia + k0;
    end
    8'd8: begin
      next_c0 <= ic;
      next_b0 <= ib + k1;
      next_a0 <= ia + k0;
    end
    8'd7: begin
      next_c0 <= ic;
      next_b0 <= ib + k1 & 32'h00FFFFFF;
      next_a0 <= ia + k0;
    end
    8'd6: begin
      next_c0 <= ic;
      next_b0 <= ib + k1 & 32'h0000FFFF;
      next_a0 <= ia + k0;
    end
    8'd5: begin
      next_c0 <= ic;
      next_b0 <= ib + k1 & 32'h000000FF;
      next_a0 <= ia + k0;
    end
    8'd4: begin
      next_c0 <= ic;
      next_b0 <= ib;
      next_a0 <= ia + k0;
    end
    8'd3: begin
      next_c0 <= ic;
      next_b0 <= ib;
      next_a0 <= ia + k0 & 32'h00FFFFFF;
    end
    8'd2: begin
      next_c0 <= ic;
      next_b0 <= ib;
      next_a0 <= ia + k0 & 32'h0000FFFF;
    end
    8'd1: begin
      next_c0 <= ic;
      next_b0 <= ib;
      next_a0 <= ia + k0 & 32'h000000FF;
    end
    default: begin
      next_c0 <= ic;
      next_b0 <= ib;
      next_a0 <= ia;
    end
  endcase
end

endmodule

module hash (
  input CLK
, input RST
, input [7:0]  key_length   //from memcache protocol header
, input [31:0] k0
, input [31:0] k1
, input [31:0] k2
, output reg[31:0] hashkey
);

parameter interval = 1'b0;  //tmp

wire[31:0] a[0:21];
wire[31:0] b[0:21];
wire[31:0] c[0:21];
wire[7:0]  w[0:21];
wire[31:0] lc;

/* round 0 */
assign a[0] = k0 + 32'hDEADBEEF + key_length + interval;
assign b[0] = k1 + 32'hDEADBEEF + key_length + interval;
assign c[0] = k2 + 32'hDEADBEEF + key_length + interval;
assign w[0] = key_length;

/* halfway round */
genvar i;
generate
  for (i=1; i<22; i=i+1) begin :loop
    hash_r1 round (CLK, RST,a[i-1], b[i-1], c[i-1], k0, k1, k2, w[i-1], a[i], b[i], c[i], w[i]);
  end
endgenerate

/* last round */
hash_r2 lastround (CLK, RST, a[21], b[21], c[21], k0, k1, k2, w[21], lc);

always @(posedge CLK) begin
  if (RST)
    hashkey <= 32'hFFFFFFFF;
  else
    hashkey <= lc;
end
endmodule

