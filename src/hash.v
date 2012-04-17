/*
 * hash.v by Yohei Kuga <sora@haeena.net>
 * A jenkinks hash function in Verilog-HDL
 *
 * Original code in C by Bob Jenkins, 1996
 * http://burtleburtle.net/bob/c/lookup3.c
 */

`define dbg 1

module hash_r1 #(
  parameter maxwords = 250                  // MAX number of key length.
`ifdef dbg
, parameter nloop    = 21
`else
, parameter nloop    = div12p1(maxwords)
`endif
)(
  input CLK
, input RST
, input emit
, input onloop
, input [31:0] ia
, input [31:0] ib
, input [31:0] ic
, input [31:0] k0
, input [31:0] k1
, input [31:0] k2
, output reg[31:0] oa
, output reg[31:0] ob
, output reg[31:0] oc
);

function [4:0] div12p1;
  input [7:0] nwords;
begin
  for (div12p1=0; nwords>0; div12p1=div12p1+1)
    nwords = nwords - 12;
end
endfunction

wire[31:0] a0 = ia + k0;
wire[31:0] b0 = ib + k1;
wire[31:0] c0 = ic + k2;
wire[31:0] a1 = (a0 - c0) ^ {c0[27:0], c0[31:28]};
wire[31:0] c1 = c0 + b0;
wire[31:0] b1 = (b0 - a1) ^ {a1[25:0], a1[31:26]};
wire[31:0] a2 = a1 + c1;
wire[31:0] c2 = (c1 - b1) ^ {b1[23:0], b1[31:24]};
wire[31:0] b2 = b1 + a2;
wire[31:0] a3 = (a2 - c2) ^ {c2[15:0], c2[31:16]};
wire[31:0] c3 = c2 + b2;
wire[31:0] b3 = (b2 - a3) ^ {a3[12:0], a3[31:13]};
wire[31:0] a4 = a3 + c3;
wire[31:0] c4 = (c3 - b3) ^ {b3[27:0], b3[31:28]};
wire[31:0] b4 = b3 + a4;

always @(posedge CLK) begin
  if (RST) begin
    oa <= 32'b0;
    ob <= 32'b0;
    oc <= 32'b0;
  end else begin
    if (emit) begin
      if (onloop) begin
        oa <= a4;
        oc <= c4;
        ob <= b4;
      end else begin
        oa <= ia;
        ob <= ib;
        oc <= ic;
      end
    end
  end
end
endmodule

module hash_r2 (
  input CLK
, input RST
, input emit
, input onloop
, input [7:0] wcount
, input [31:0] ia
, input [31:0] ib
, input [31:0] ic
, input [31:0] k0
, input [31:0] k1
, input [31:0] k2
, output reg[31:0] o
);

reg[31:0] a0, b0, c0;

wire[31:0] c1 = (c0 ^ b0) - {b0[17:0], b0[31:18]};
wire[31:0] a1 = (a0 ^ c1) - {c1[20:0], c1[31:21]};
wire[31:0] b1 = (b0 ^ a1) - {a1[6:0], a1[31:7]};
wire[31:0] c2 = (c1 ^ b1) - {b1[15:0], b1[31:16]};
wire[31:0] a2 = (a1 ^ c2) - {c2[27:0], c2[31:28]};
wire[31:0] b2 = (b1 ^ a2) - {a2[17:0], a2[31:18]};
wire[31:0] c3 = (c2 ^ b2) - {b2[7:0], b2[31:8]};

always @(posedge CLK) begin
  if (RST)
    o <= 32'b0;
  else begin
    if (emit) begin
      if (onloop)
        o <= c3;
      else
        o <= ic;
    end
  end
end

always @* begin
  case (wcount)
    8'd12: begin
      c0 <= ic + k2;
      b0 <= ib + k1;
      a0 <= ia + k0;
    end
    8'd11: begin
      c0 <= ic + k2 & 32'h00FFFFFF;
      b0 <= ib + k1;
      a0 <= ia + k0;
    end
    8'd10: begin
      c0 <= ic + k2 & 32'h0000FFFF;
      b0 <= ib + k1;
      a0 <= ia + k0;
    end
    8'd9: begin
      c0 <= ic + k2 & 32'h000000FF;
      b0 <= ib + k1;
      a0 <= ia + k0;
    end
    8'd8: begin
      c0 <= ic;
      b0 <= ib + k1;
      a0 <= ia + k0;
    end
    8'd7: begin
      c0 <= ic;
      b0 <= ib + k1 & 32'h00FFFFFF;
      a0 <= ia + k0;
    end
    8'd6: begin
      c0 <= ic;
      b0 <= ib + k1 & 32'h0000FFFF;
      a0 <= ia + k0;
    end
    8'd5: begin
      c0 <= ic;
      b0 <= ib + k1 & 32'h000000FF;
      a0 <= ia + k0;
    end
    8'd4: begin
      c0 <= ic;
      b0 <= ib;
      a0 <= ia + k0;
    end
    8'd3: begin
      c0 <= ic;
      b0 <= ib;
      a0 <= ia + k0 & 32'h00FFFFFF;
    end
    8'd2: begin
      c0 <= ic;
      b0 <= ib;
      a0 <= ia + k0 & 32'h0000FFFF;
    end
    8'd1: begin
      c0 <= ic;
      b0 <= ib;
      a0 <= ia + k0 & 32'h000000FF;
    end
  endcase
end

endmodule

module hash (
  input CLK
, input RST
, input enable
, input onloop
, input [7:0] wcount      // remaining character counts (0 ~ 12)
, input [7:0] word        // a character of key
, input [7:0] key_length  // key length
, input [7:0] interval
, output valid
, output reg[31:0] hashkey
);

reg[31:0] k0, k1, k2;
reg[3:0]  count12;

wire[31:0] a[0:21];
wire[31:0] b[0:21];
wire[31:0] c[0:21];
wire[31:0] lc;            // last c

/* round 0 */
assign a[0] = k0 + 32'hDEADBEEF + key_length + interval;
assign b[0] = k1 + 32'hDEADBEEF + key_length + interval;
assign c[0] = k2 + 32'hDEADBEEF + key_length + interval;

/* round 1 ~ nloop */
generate
  genvar i;
  for (i=1; i<22; i=i+1) begin :loop
    hash_r1 round ( .CLK(CLK)
                  , .RST(RST)
                  , .emit(emit)
                  , .onloop(onloop)
                  , .ia(a[i-1])
                  , .ib(b[i-1])
                  , .ic(c[i-1])
                  , .k0(k0)
                  , .k1(k1)
                  , .k2(k2)
                  , .oa(a[i])
                  , .ob(b[i])
                  , .oc(c[i]) );
  end
endgenerate

/* last round */
hash_r2 lastround ( .CLK(CLK)
                  , .RST(RST)
                  , .emit(emit)
                  , .onloop(onloop)
                  , .wcount(wcount)
                  , .ia(a[21])
                  , .ib(b[21])
                  , .ic(c[21])
                  , .k0(k0)
                  , .k1(k1)
                  , .k2(k2)
                  , .o(lc) );

always @*
  case (count12)
    4'd12: k0[31:24] <= word;
    4'd11: k0[23:16] <= word;
    4'd10: k0[15:8]  <= word;
    4'd9:  k0[7:0]   <= word;
    4'd8:  k1[31:24] <= word;
    4'd7:  k1[23:16] <= word;
    4'd6:  k1[15:8]  <= word;
    4'd5:  k1[7:0]   <= word;
    4'd4:  k2[31:24] <= word;
    4'd3:  k2[23:16] <= word;
    4'd2:  k2[15:8]  <= word;
    4'd1:  k2[7:0]   <= word;
  endcase

wire emit = (count12) ? 4'b0 : 4'b1;

always @(posedge CLK) begin
  if (RST) begin
    count12 <= 4'd12;
    k0      <= 32'b0;
    k1      <= 32'b0;
    k2      <= 32'b0;
  end else begin
    if (enable) begin
      if (count12)
        count12 <= count12 - 4'b1;
      else begin
        count12 <= 4'd12;
        k0      <= 32'b0;
        k1      <= 32'b0;
        k2      <= 32'b0;
      end
    end
  end
end

always @(posedge CLK) begin
  if (RST)
    hashkey <= 32'b0;
  else
    hashkey <= lc;
end

endmodule

