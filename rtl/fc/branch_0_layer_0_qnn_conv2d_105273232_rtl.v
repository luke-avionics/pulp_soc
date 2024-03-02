
//------> /media/WDS_4TB/software/siemens/catapult/2022.1/Mgc_home/pkgs/siflibs/ccs_ctrl_in_buf_wait_v4.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
// Change History:
//    2019-01-24 - Add assertion to verify rdy signal behavior under reset.
//                 Fix bug in that behavior.
//    2019-01-04 - Fixed bug 54073 - rdy signal should not be asserted during
//                 reset
//    2018-11-19 - Improved code coverage for is_idle
//    2018-08-22 - Added is_idle to interface (as compare to 
//                 ccs_ctrl_in_buf_wait_v2)
//------------------------------------------------------------------------------


module ccs_ctrl_in_buf_wait_v4 (clk, en, arst, srst, irdy, ivld, idat, vld, rdy, dat, is_idle);

    parameter integer rscid   = 1;
    parameter integer width   = 8;
    parameter integer ph_clk  = 1;
    parameter integer ph_en   = 1;
    parameter integer ph_arst = 1;
    parameter integer ph_srst = 1;

    input              clk;
    input              en;
    input              arst;
    input              srst;
    output             rdy;
    input              vld;
    input  [width-1:0] dat;
    input              irdy;
    output             ivld;
    output [width-1:0] idat;
    output             is_idle;

    wire               rdy_int;
    wire               vld_int;
    reg                filled;
    wire               filled_next;
    wire               lbuf;
    reg    [width-1:0] abuf;
    reg                hs_init;

    assign rdy_int = ~filled | irdy;
    assign rdy = rdy_int & hs_init;
    assign vld_int = vld & hs_init;

    assign ivld = filled_next;
    assign idat = abuf;

    assign lbuf = vld_int & rdy_int;
    assign filled_next = vld_int | (filled & ~irdy);

    assign is_idle = ~lbuf & (filled ~^ filled_next) & hs_init;

    // Output registers:
    generate
    if (ph_arst == 0 && ph_clk == 1)
    begin: POS_CLK_NEG_ARST
        always @(posedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            hs_init <= 1'b1;
            if (lbuf == 1'b1)
                abuf <= dat;
        end
    end
    else if (ph_arst == 1 && ph_clk == 1)
    begin: POS_CLK_POS_ARST
        always @(posedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            hs_init <= 1'b1;
            if (lbuf == 1'b1)
                abuf <= dat;
        end
    end
    else if (ph_arst == 0 && ph_clk == 0)
    begin: NEG_CLK_NEG_ARST
        always @(negedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            hs_init <= 1'b1;
            if (lbuf == 1'b1)
                abuf <= dat;
        end
    end
    else if (ph_arst == 1 && ph_clk == 0)
    begin: NEG_CLK_POS_ARST
        always @(negedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            hs_init <= 1'b0;
            abuf <= {width{1'b0}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            hs_init <= 1'b1;
            if (lbuf == 1'b1)
                abuf <= dat;
        end
    end
    endgenerate

`ifdef RDY_ASRT 
    generate
    if (ph_clk==1) 
    begin: POS_CLK_ASSERT

       property rdyAsrt ;
         @(posedge clk) (srst==ph_srst) |=> (rdy==0);
       endproperty
       a1: assert property(rdyAsrt);

       property rdyAsrtASync ;
         @(posedge clk) (arst==ph_arst) |-> (rdy==0);
       endproperty
       a2: assert property(rdyAsrtASync);

    end else if (ph_clk==0) 
    begin: NEG_CLK_ASSERT

       property rdyAsrt ;
         @(negedge clk) ((srst==ph_srst) || (arst==ph_arst)) |=> (rdy==0);
       endproperty
       a1: assert property(rdyAsrt);

       property rdyAsrtASync ;
         @(negedge clk) (arst==ph_arst) |-> (rdy==0);
       endproperty
       a2: assert property(rdyAsrtASync);
    end
    endgenerate

`endif

endmodule



//------> /media/WDS_4TB/software/siemens/catapult/2022.1/Mgc_home/pkgs/siflibs/ccs_out_buf_wait_v5.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

module ccs_out_buf_wait_v5 (clk, en, arst, srst, ivld, irdy, idat, rdy, vld, dat, is_idle);

    parameter integer  rscid   = 1;
    parameter integer  width   = 8;
    parameter integer  ph_clk  = 1;
    parameter integer  ph_en   = 1;
    parameter integer  ph_arst = 1;
    parameter integer  ph_srst = 1;
    parameter integer  rst_val = 0;

    input              clk;
    input              en;
    input              arst;
    input              srst;
    output             irdy;
    input              ivld;
    input  [width-1:0] idat;
    input              rdy;
    output             vld;
    output [width-1:0] dat;
    output             is_idle;

    reg                filled;
    wire               filled_next;
    wire               lbuf;
    reg    [width-1:0] abuf;

    assign irdy = ~filled_next;

    assign vld = filled | ivld;
    assign dat = filled ? abuf : idat;

    assign lbuf = ivld & ~filled & ~rdy;
    assign filled_next = filled ? ~rdy : lbuf;

    assign is_idle = ~lbuf & (filled ~^ filled_next);

    // Output registers:
    generate
    if (ph_arst == 0 && ph_clk == 1)
    begin: POS_CLK_NEG_ARST
        always @(posedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            if (lbuf == 1'b1)
                abuf <= idat;
        end
    end
    else if (ph_arst == 1 && ph_clk == 1)
    begin: POS_CLK_POS_ARST
        always @(posedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            if (lbuf == 1'b1)
                abuf <= idat;
        end
    end
    else if (ph_arst == 0 && ph_clk == 0)
    begin: NEG_CLK_NEG_ARST
        always @(negedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            if (lbuf == 1'b1)
                abuf <= idat;
        end
    end
    else if (ph_arst == 1 && ph_clk == 0)
    begin: NEG_CLK_POS_ARST
        always @(negedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (srst == ph_srst)
        begin
            filled <= 1'b0;
            abuf <= {width{rst_val}};
        end
        else if (en == ph_en)
        begin
            filled <= filled_next;
            if (lbuf == 1'b1)
                abuf <= idat;
        end
    end
    endgenerate
endmodule

//------> /media/WDS_4TB/software/siemens/catapult/2022.1/Mgc_home/pkgs/branch_0_layer_0_qnn_conv2d_105273232_pkgs/mgc_comps_src/mgc_mul2add1_beh.v 
//mul2add1
(* use_dsp48="yes" *)
module mgc_mul2add1(a,b,b2,c,d,d2,cst,z);
  parameter gentype = 0;
  parameter width_a = 0;
  parameter signd_a = 0;
  parameter width_b = 0;
  parameter signd_b = 0;
  parameter width_b2 = 0;
  parameter signd_b2 = 0;
  parameter width_c = 0;
  parameter signd_c = 0;
  parameter width_d = 0;
  parameter signd_d = 0;
  parameter width_d2 = 0;
  parameter signd_d2 = 0;
  parameter width_e = 0;
  parameter signd_e = 0;
  parameter width_z = 0;
  parameter isadd = 1;
  parameter add_b2 = 1;
  parameter add_d2 = 1;
  parameter use_const = 1;
  input  [width_a-1:0] a;
  input  [width_b-1:0] b;
  input  [width_b2-1:0] b2; // spyglass disable SYNTH_5121,W240
  input  [width_c-1:0] c;
  input  [width_d-1:0] d;
  input  [width_d2-1:0] d2; // spyglass disable SYNTH_5121,W240
  input  [width_e-1:0] cst; // spyglass disable SYNTH_5121,W240
  output [width_z-1:0] z;

  function integer MAX;
    input integer LEFT, RIGHT;
  begin
    if (LEFT > RIGHT) MAX = LEFT;
    else              MAX = RIGHT;
  end endfunction
  function integer ZLEN;
    input integer a_len, b_len, c_len, d_len, e_len;
  begin
    ZLEN = MAX(a_len+b_len, MAX(c_len+d_len,e_len)) + 2;
  end endfunction
  function integer PREADDLEN;
    input integer b_len, d_len, width_d;
  begin
    if(width_d) PREADDLEN = MAX(b_len,d_len) + 1;
    else        PREADDLEN = b_len;
  end endfunction
  function integer PREADDMULLEN;
    input integer a_len, b_len, d_len, width_d;
  begin
    PREADDMULLEN = a_len + PREADDLEN(b_len,d_len,width_d);
  end endfunction

  localparam a_len    = width_a-signd_a+1;
  localparam b_len    = width_b-signd_b+1;
  localparam b2_len   = width_b2-signd_b2+1;
  localparam c_len    = width_c-signd_c+1;
  localparam d_len    = width_d-signd_d+1;
  localparam d2_len   = width_d2-signd_d2+1;
  localparam e_len    = width_e-signd_e+1;
  localparam bpb2_len = PREADDLEN(b_len, b2_len, width_b2);
  localparam dpd2_len = PREADDLEN(d_len, d2_len, width_d2);
  localparam axb_len  = PREADDMULLEN(a_len, b_len, b2_len, width_b2);
  localparam cxd_len  = PREADDMULLEN(c_len, d_len, d2_len, width_d2);
  localparam z_len    = ZLEN(a_len, bpb2_len, c_len, dpd2_len, e_len);

  reg [a_len-1:0]   aa;
  reg [b_len-1:0]   bb;
  reg [b2_len-1:0]  bb2;
  reg [c_len-1:0]   cc;
  reg [d_len-1:0]   dd;
  reg [d2_len-1:0]  dd2;
  reg [e_len-1:0]   ee;
  reg [bpb2_len-1:0]  b_bb2;
  reg [dpd2_len-1:0]  d_dd2;
  reg [axb_len-1:0] axb;
  reg [cxd_len-1:0] cxd;
  reg [z_len-1:0]   zz;

  // make all inputs signed
  always @(*) aa = signd_a ? a : {1'b0, a};
  always @(*) bb = signd_b ? b : {1'b0, b};
  generate if (width_b2) begin
    (* keep ="true" *) reg [b2_len-1:0]  bb2_keep;
    always @(*) bb2_keep = signd_b2 ? b2 : {1'b0, b2};
    always @(*) bb2 = bb2_keep;
  end endgenerate
  always @(*) cc = signd_c ? c : {1'b0, c};
  always @(*) dd = signd_d ? d : {1'b0, d};
  generate if (width_d2) begin
    (* keep ="true" *) reg [d2_len-1:0]  dd2_keep;
    always @(*) dd2_keep = signd_d2 ? d2 : {1'b0, d2};
    always @(*) dd2 = dd2_keep;
  end endgenerate
  always @(*) ee = signd_e ? cst : {1'b0, cst};
  
  // perform preadd1
  generate
    if (width_b2) begin
      if (add_b2) begin always @(*)  b_bb2 = $signed(bb) + $signed(bb2); end
      else        begin always @(*)  b_bb2 = $signed(bb) - $signed(bb2); end
    end else      begin always @(*)  b_bb2 = $signed(bb); end
  endgenerate
  
  // perform preadd2
  generate
    if (width_d2) begin
      if (add_d2) begin always @(*)  d_dd2 = $signed(dd) + $signed(dd2); end
      else        begin always @(*)  d_dd2 = $signed(dd) - $signed(dd2); end
    end else      begin always @(*)  d_dd2 = $signed(dd); end
  endgenerate

  // perform muladd1
  always @(*) axb = $signed(aa) * $signed(b_bb2);
  always @(*) cxd = $signed(cc) * $signed(d_dd2);
  generate
    if (use_const>0) begin
      if ( isadd) begin always @(*) zz = $signed(axb) + $signed(cxd) + $signed(ee); end else
                  begin always @(*) zz = $signed(axb) - $signed(cxd) + $signed(ee); end
    end else begin
      if ( isadd) begin always @(*) zz = $signed(axb) + $signed(cxd); end else
                  begin always @(*) zz = $signed(axb) - $signed(cxd); end
    end 
  endgenerate

  // adjust output
  assign z = zz;

endmodule // mgc_mul2add1

//------> /media/WDS_4TB/software/siemens/catapult/2022.1/Mgc_home/pkgs/siflibs/ccs_genreg_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

module ccs_genreg_v1 (clk, en, arst, srst, d, z);
    parameter integer width   = 1;
    parameter integer ph_clk  = 1;
    parameter integer ph_en   = 1;
    parameter integer ph_arst = 0;
    parameter integer ph_srst = 1;
    parameter         has_en  = 1'b1;

    input clk;
    input en;
    input arst;
    input srst;
    input      [width-1:0] d;
    output reg [width-1:0] z;

    //  Generate parameters
    //  ph_clk | ph_arst | has_en     Label:
    //    1        1          1       GEN_CLK1_ARST1_EN1
    //    1        1          0       GEN_CLK1_ARST1_EN0
    //    1        0          1       GEN_CLK1_ARST0_EN1
    //    1        0          0       GEN_CLK1_ARST0_EN0
    //    0        1          1       GEN_CLK0_ARST1_EN1
    //    0        1          0       GEN_CLK0_ARST1_EN0
    //    0        0          1       GEN_CLK0_ARST0_EN1
    //    0        0          0       GEN_CLK0_ARST0_EN0
    
    generate 
      // Pos edge clock, pos edge async reset, has enable
      if (ph_clk == 1 & ph_arst == 1 & has_en == 1)
      begin: GEN_CLK1_ARST1_EN1
        always @(posedge clk or posedge arst)
          if (arst == 1'b1)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else if (en == $unsigned(ph_en))
            z <= d;
      end  //GEN_CLK1_ARST1_EN1

      // Pos edge clock, pos edge async reset, no enable
      else if (ph_clk == 1 & ph_arst == 1 & has_en == 0)
      begin: GEN_CLK1_ARST1_EN0
        always @(posedge clk or posedge arst)
          if (arst == 1'b1)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else
            z <= d;
      end  //GEN_CLK1_ARST1_EN0

      // Pos edge clock, neg edge async reset, has enable
      else if (ph_clk == 1 & ph_arst == 0 & has_en == 1)
      begin: GEN_CLK1_ARST0_EN1
        always @(posedge clk or negedge arst)
          if (arst == 1'b0)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else if (en == $unsigned(ph_en))
            z <= d;
      end  //GEN_CLK1_ARST0_EN1

      // Pos edge clock, neg edge async reset, no enable
      else if (ph_clk == 1 & ph_arst == 0 & has_en == 0)
      begin: GEN_CLK1_ARST0_EN0
        always @(posedge clk or negedge arst)
          if (arst == 1'b0)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else
            z <= d;
      end  //GEN_CLK1_ARST0_EN0


      // Neg edge clock, pos edge async reset, has enable
      if (ph_clk == 0 & ph_arst == 1 & has_en == 1)
      begin: GEN_CLK0_ARST1_EN1
        always @(negedge clk or posedge arst)
          if (arst == 1'b1)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else if (en == $unsigned(ph_en))
            z <= d;
      end  //GEN_CLK0_ARST1_EN1

      // Neg edge clock, pos edge async reset, no enable
      else if (ph_clk == 0 & ph_arst == 1 & has_en == 0)
      begin: GEN_CLK0_ARST1_EN0
        always @(negedge clk or posedge arst)
          if (arst == 1'b1)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else
            z <= d;
      end  //GEN_CLK0_ARST1_EN0

      // Neg edge clock, neg edge async reset, has enable
      else if (ph_clk == 0 & ph_arst == 0 & has_en == 1)
      begin: GEN_CLK0_ARST0_EN1
        always @(negedge clk or negedge arst)
          if (arst == 1'b0)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else if (en == $unsigned(ph_en))
            z <= d;
      end  //GEN_CLK0_ARST0_EN1

      // Neg edge clock, neg edge async reset, no enable
      else if (ph_clk == 0 & ph_arst == 0 & has_en == 0)
      begin: GEN_CLK0_ARST0_EN0
        always @(negedge clk or negedge arst)
          if (arst == 1'b0)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else
            z <= d;
      end  //GEN_CLK0_ARST0_EN0
    endgenerate
endmodule


//------> /media/WDS_4TB/software/siemens/catapult/2022.1/Mgc_home/pkgs/siflibs/ccs_fifo_wait_core_v5.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

/*
 *            _________________________________________________
 * WRITER    |                                                 |   READER
 *           |               ccs_fifo_wait_core                |
 *           |             _____________________               |
 *        --<|  din_rdy --<|  ---------------- <|--- dout_rdy <|---
 *           |             |       FIFO         |              |
 *        ---|> din_vld ---|> ----------------  |>-- dout_vld  |>--
 *        ---|>     din ---|> ----------------  |>-- dout      |>--
 *           |             |____________________|              |
 *           |_________________________________________________|
 *
 *    rdy    - can be considered as a notFULL signal
 *    vld    - can be considered as a notEMPTY signal
 *    is_idle - clk can be safely gated
 *
 * Change History:
 *    2019-01-24 - Add assertion to verify rdy signal behavior under reset.
 *                 Fix bug in that behavior.
 */

module ccs_fifo_wait_core_v5 (clk, en, arst, srst, din_vld, din_rdy, din, dout_vld, dout_rdy, dout, sd, is_idle);

    parameter integer rscid    = 0;     // resource ID
    parameter integer width    = 8;     // fifo width
    parameter integer sz_width = 8;     // size of port for elements in fifo
    parameter integer fifo_sz  = 8;     // fifo depth
    parameter integer ph_clk   = 1;     // clock polarity 1=rising edge, 0=falling edge
    parameter integer ph_en    = 1;     // clock enable polarity
    parameter integer ph_arst  = 1;     // async reset polarity
    parameter integer ph_srst  = 1;     // sync reset polarity
    parameter integer ph_log2  = 3;     // log2(fifo_sz)

    input                 clk;
    input                 en;
    input                 arst;
    input                 srst;
    input                 din_vld;    // writer has valid data
    output                din_rdy;    // fifo ready for data (not full)
    input  [width-1:0]    din;
    output                dout_vld;   // fifo has valid data (not empty)
    input                 dout_rdy;   // reader ready for data
    output [width-1:0]    dout;
    output [sz_width-1:0] sd;
    output                is_idle;

    localparam integer fifo_b  = width * fifo_sz;
    localparam integer fifo_mx = (fifo_sz > 0) ? (fifo_sz-1) : 0 ;
    localparam integer fifo_mx_over_8 = fifo_mx / 8 ;

    reg      [fifo_mx:0] stat_pre;
    wire     [fifo_mx:0] stat;
    reg      [( (fifo_b > 0) ? fifo_b : 1)-1:0] buff_pre;
    wire     [( (fifo_b > 0) ? fifo_b : 1)-1:0] buff;
    reg      [fifo_mx:0] en_l;
    reg      [fifo_mx_over_8:0] en_l_s;

    reg      [width-1:0] buff_nxt;

    reg                  stat_nxt;
    reg                  stat_behind;
    reg                  stat_ahead;
    reg                  stat_tail;
    reg                  en_l_var;

    integer              i;
    genvar               eni;

    wire [32:0]          size_t;
    reg  [31:0]          count;
    reg  [31:0]          count_t;
    reg  [32:0]          n_elem;
    wire                 din_rdy_drv;
    wire                 dout_vld_drv;
    wire                 din_vld_int;
    wire                 hs_init;
    wire                 active;
    wire                 is_idle_drv;

    // synopsys translate_off
    reg  [31:0]          peak;
    initial
    begin
      count = 32'b0;
      peak  = 32'b0;
    end
    // synopsys translate_on

    assign din_rdy = din_rdy_drv;
    assign dout_vld = dout_vld_drv;
    assign is_idle = is_idle_drv;

    generate
    if ( fifo_sz > 0 )
    begin: FIFO_REG
      assign din_vld_int = din_vld & hs_init;
      assign din_rdy_drv = (dout_rdy | ~stat[0]) & hs_init;
      assign dout_vld_drv = din_vld_int | stat[fifo_sz-1];

      assign active = (din_vld_int & din_rdy_drv) | (dout_rdy & dout_vld_drv);
      assign is_idle_drv = ~active & hs_init;

      assign size_t = (count - {31'b0, (dout_rdy & stat[fifo_sz-1])}) + {31'b0, din_vld_int};
      assign sd = size_t[sz_width-1:0];

      assign dout = (stat[fifo_sz-1]) ? buff[fifo_b-1:width*(fifo_sz-1)] : din;

      always @(*)
      begin: FIFOPROC
        n_elem = 33'b0;
        for (i = fifo_sz-1; i >= 0; i = i - 1)
        begin
          stat_behind = (i != 0) ? stat[i-1] : 1'b0;
          stat_ahead  = (i != (fifo_sz-1)) ? stat[i+1] : 1'b1;

          // Determine if this buffer element will have data
          stat_nxt = stat_ahead &                       // valid element ahead of this one (or head)
                       (stat_behind                     // valid element behind this one
                         | (stat[i] & (~dout_rdy))      // valid element and output not ready (in use and not shifted)
                         | (stat[i] & din_vld_int)      // valid element and input has data
                         | (din_vld_int & (~dout_rdy))  // input has data and output not ready
                       );
          stat_pre[i] = stat_nxt;

          // First empty elem when not shifting or last valid elem after shifting (assumes stat_behind == 0)
          stat_tail = stat_ahead & ((~stat[i] & ~dout_rdy) | (stat[i] & dout_rdy));

          if (dout_rdy & stat_behind)
          begin
            // shift valid element
            buff_nxt[0+:width] = buff[width*(i-1)+:width];
            en_l_var = 1'b1;
          end
          else if (din_vld_int & stat_tail)
          begin
            // update tail with input data
            buff_nxt = din;
            en_l_var = 1'b1;
          end
          else
          begin
            // no-op, disable register
            buff_nxt = din; // Don't care input to disabled flop
            en_l_var = 1'b0;
          end
          buff_pre[width*i+:width] = buff_nxt[0+:width];

          if (ph_en != 0)
            en_l[i] = en & en_l_var;
          else
            en_l[i] = en | ~en_l_var;

          if ((stat_ahead == 1'b1) & (stat[i] == 1'b0))
            //found tail, update the number of elements for count
            n_elem = ($unsigned(fifo_sz) - 1) - $unsigned(i);
        end //for loop

        // Enable for stat registers (partitioned into banks of eight)
        // Take care of the head first
        if (ph_en != 0)
          en_l_s[(((fifo_sz > 0) ? fifo_sz : 1)-1)/8] = en & active;
        else
          en_l_s[(((fifo_sz > 0) ? fifo_sz : 1)-1)/8] = en | ~active;

        // Now every eight
        for (i = fifo_sz-1; i >= 7; i = i - 1)
        begin
          if (($unsigned(i)%8) == 0)
          begin
            if (ph_en != 0)
              en_l_s[(i/8)-1] = en & (stat[i]) & (active);
            else
              en_l_s[(i/8)-1] = en | ~(stat[i]) | ~(active);
          end
        end

        // Update count and peak
        if ( stat[fifo_sz-1] == 1'b0 )
          count_t = 32'b0;
        else if ( stat[0] == 1'b1 )
          count_t = fifo_sz;
        else
          count_t = n_elem[31:0];
        count = count_t;
        // synopsys translate_off
        if ( peak < count )
          peak = count;
        // synopsys translate_on
      end //FIFOPROC

      // Handshake valid after reset
      ccs_genreg_v1
      #(
        .width   (1),
        .ph_clk  (ph_clk),
        .ph_en   (1),
        .ph_arst (ph_arst),
        .ph_srst (ph_srst),
        .has_en  (1'b0)
      )
      HS_INIT_REG
      (
        .clk     (clk),
        .en      (1'b1),
        .arst    (arst),
        .srst    (srst),
        .d       (1'b1),
        .z       (hs_init)
      );

      // Buffer and status registers
      for (eni = fifo_sz-1; eni >= 0; eni = eni - 1)
      begin: GEN_REGS
        ccs_genreg_v1
        #(
          .width   (1),
          .ph_clk  (ph_clk),
          .ph_en   (ph_en),
          .ph_arst (ph_arst),
          .ph_srst (ph_srst),
          .has_en  (1'b1)
        )
        STATREG
        (
          .clk     (clk),
          .en      (en_l_s[eni/8]),
          .arst    (arst),
          .srst    (srst),
          .d       (stat_pre[eni]),
          .z       (stat[eni])
        );

        ccs_genreg_v1
        #(
          .width   (width),
          .ph_clk  (ph_clk),
          .ph_en   (ph_en),
          .ph_arst (ph_arst),
          .ph_srst (ph_srst),
          .has_en  (1'b1)
        )
        BUFREG
        (
          .clk     (clk),
          .en      (en_l[eni]),
          .arst    (arst),
          .srst    (srst),
          .d       (buff_pre[width*eni+:width]),
          .z       (buff[width*eni+:width])
        );
      end

    end
    else
    begin: FEED_THRU
      assign din_rdy_drv  = dout_rdy;
      assign dout_vld_drv = din_vld;
      assign dout     = din;
      // non-blocking is not II=1 when fifo_sz=0
      assign sd = {{(sz_width-1){1'b0}}, (din_vld & ~dout_rdy)};
      assign is_idle_drv = ~(din_vld & dout_rdy);
    end
    endgenerate

`ifdef RDY_ASRT
    generate
    if (ph_clk==1)
    begin: POS_CLK_ASSERT

       property rdyAsrt ;
         @(posedge clk) (srst==ph_srst) |=> (din_rdy==0);
       endproperty
       a1Pos: assert property(rdyAsrt);

       property rdyAsrtASync ;
         @(posedge clk) (arst==ph_arst) |-> (din_rdy==0);
       endproperty
       a2Pos: assert property(rdyAsrtASync);

    end else if (ph_clk==0)
    begin: NEG_CLK_ASSERT

       property rdyAsrt ;
         @(negedge clk) ((srst==ph_srst) || (arst==ph_arst)) |=> (din_rdy==0);
       endproperty
       a1Neg: assert property(rdyAsrt);

       property rdyAsrtASync ;
         @(negedge clk) (arst==ph_arst) |-> (din_rdy==0);
       endproperty
       a2Neg: assert property(rdyAsrtASync);

    end
    endgenerate
`endif

endmodule

//------> /media/WDS_4TB/software/siemens/catapult/2022.1/Mgc_home/pkgs/siflibs/ccs_pipe_v6.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------
/*
 *
 *            _______________________________________________
 * WRITER    |                                              |          READER
 *           |                 ccs_pipe                     |
 *           |            ______________________            |
 *        --<| din_rdy --<|  ---------------- <|---dout_rdy<|---
 *           |            |       FIFO         |            |
 *        ---|>din_vld ---|> ----------------  |>--dout_vld |>--
 *        ---|>din -------|> ----------------  |> -----dout |>--
 *           |            |____________________|            |
 *           |______________________________________________|
 *
 *    din_rdy     - can be considered as a notFULL signal
 *    dout_vld    - can be considered as a notEMPTY signal
 *    write_stall - an internal debug signal formed from din_vld & !din_rdy
 *    read_stall  - an internal debug signal formed from dout_rdy & !dout_vld
 *    is_idle     - indicates the clock can be safely gated
 *    stall_ctrl  - Stall the pipe(fifo).  Used by STALL_FLAG_SV directive
 */

module ccs_pipe_v6 (clk, en, arst, srst, din_rdy, din_vld, din, dout_rdy, dout_vld, dout, 
                    sz, sz_req, is_idle);

    parameter integer rscid    = 0; // resource ID
    parameter integer width    = 8; // fifo width
    parameter integer sz_width = 8; // width of size of elements in fifo
    parameter integer fifo_sz  = 8; // fifo depth
    parameter integer log2_sz  = 3; // log2(fifo_sz)
    parameter integer ph_clk   = 1; // clock polarity 1=rising edge, 0=falling edge
    parameter integer ph_en    = 1; // clock enable polarity
    parameter integer ph_arst  = 1; // async reset polarity
    parameter integer ph_srst  = 1; // sync reset polarity

    // clock 
    input              clk;
    input              en;
    input              arst;
    input              srst;

    // writer
    output             din_rdy;
    input              din_vld;
    input  [width-1:0] din;

    // reader
    input              dout_rdy;
    output             dout_vld;
    output [width-1:0] dout;

    // size
    output [sz_width-1:0] sz;
    input                 sz_req;
    output                is_idle;

    localparam stallOff = 0; 
    wire                  stall_ctrl;
    assign stall_ctrl = stallOff;
   
    // synopsys translate_off
    wire   write_stall;
    wire   read_stall;
    assign write_stall = (din_vld & !din_rdy) | stall_ctrl;
    assign read_stall  = (dout_rdy & !dout_vld) | stall_ctrl;
    // synopsys translate_on

    wire    tmp_din_rdy;
    assign  din_rdy = tmp_din_rdy & !stall_ctrl;
    wire    tmp_dout_vld;
    assign  dout_vld = tmp_dout_vld & !stall_ctrl;
   
    ccs_fifo_wait_core_v5
    #(
        .rscid    (rscid),
        .width    (width),
        .sz_width (sz_width),
        .fifo_sz  (fifo_sz),
        .ph_clk   (ph_clk),
        .ph_en    (ph_en),
        .ph_arst  (ph_arst),
        .ph_srst  (ph_srst),
        .ph_log2  (log2_sz)
    )
    FIFO
    (
        .clk      (clk),
        .en       (en),
        .arst     (arst),
        .srst     (srst),
        .din_vld  (din_vld & !stall_ctrl),
        .din_rdy  (tmp_din_rdy),
        .din      (din),
        .dout_vld (tmp_dout_vld),
        .dout_rdy (dout_rdy & !stall_ctrl),
        .dout     (dout),
        .sd       (sz),
        .is_idle  (is_idle)
    );

endmodule


//------> ./rtl_branch_0_layer_0_qnn_conv2d_105273232mgc_rom_sync_40_4_12_1_1.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    2022.1/981271 Production Release
//  HLS Date:       Thu Feb 10 22:05:20 PST 2022
// 
//  Generated by:   yzhang919@eic-gt-cpu1
//  Generated date: Thu Feb 29 06:06:57 2024
// ----------------------------------------------------------------------

// 
module branch_0_layer_0_qnn_conv2d_105273232mgc_rom_sync_40_4_12_1_1 (addr, data_out,
    clk
);
  input [1:0]addr ;
  output [11:0]data_out ;
  input clk ;


  // Constants for ROM dimensions
  parameter n_width    = 12;
  parameter n_size     = 4;
  parameter n_numports = 1;
  parameter n_addr_w   = 2;
  parameter n_inreg    = 0;
  parameter n_outreg   = 0;

  // Declare storage for memory elements
  (* rom_style = "block" *)
  reg [11:0] mem [3:0];

  // Declare output registers
  reg [11:0] data_out_t;

  // Initialize ROM contents
  initial begin: rom_init_blk
    mem[0] <= 12'b110001000001;
    mem[1] <= 12'b000101011000;
    mem[2] <= 12'b011101101010;
    mem[3] <= 12'b001110100101;
  end


  // Synchronous ROM read block
  always@(posedge clk)
  begin
    data_out_t <= mem[addr];
  end

  // Output register assignment
  assign data_out = data_out_t;

endmodule



//------> ./rtl_branch_0_layer_0_qnn_conv2d_105273232mgc_rom_sync_38_4_288_1_1.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    2022.1/981271 Production Release
//  HLS Date:       Thu Feb 10 22:05:20 PST 2022
// 
//  Generated by:   yzhang919@eic-gt-cpu1
//  Generated date: Thu Feb 29 06:06:57 2024
// ----------------------------------------------------------------------

// 
module branch_0_layer_0_qnn_conv2d_105273232mgc_rom_sync_38_4_288_1_1 (addr, data_out,
    clk
);
  input [1:0]addr ;
  output [287:0]data_out ;
  input clk ;


  // Constants for ROM dimensions
  parameter n_width    = 288;
  parameter n_size     = 4;
  parameter n_numports = 1;
  parameter n_addr_w   = 2;
  parameter n_inreg    = 0;
  parameter n_outreg   = 0;

  // Declare storage for memory elements
  (* rom_style = "block" *)
  reg [287:0] mem [3:0];

  // Declare output registers
  reg [287:0] data_out_t;

  // Initialize ROM contents
  initial begin: rom_init_blk
    mem[0] <= 288'b001011001100100010111111110100010000011000100001100000100101101111101101110111111010110010010100110110001110010010011010111000001101110000100001101101011111011110011011111011100110011111011101011100011000001000111000010100101100010000001011010111000010110011101110011001001000110111111010;
    mem[1] <= 288'b010111101000001011001010001000110111110011110111111111000001101111000000100111010001110111001000000100111010100111000101011111100101110101011100100000010000001110001110111111000100111101101111101100001100110111000010001101100111111110100011001010001100100000110101101000101011010001100110;
    mem[2] <= 288'b100111110110011101011010111101111110100011010101010010101011101110111111000101011110110111001010111010000011010100011101011011100000110100101011001100011001101100100110001000001110101011110010111110110001000001110110001101110110101000111100111110100101101000001011000001000010100100110101;
    mem[3] <= 288'b001100000011001011000111110101111100001011010100011000000111101010001000000000011110011101110111001000101001001110111010101011011101110101010100100110101001000110010100110111000010001110110110000011111000001110101111001101011000011000110110001110110010011111001000101100110110100111001001;
  end


  // Synchronous ROM read block
  always@(posedge clk)
  begin
    data_out_t <= mem[addr];
  end

  // Output register assignment
  assign data_out = data_out_t;

endmodule



//------> ./rtl.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    2022.1/981271 Production Release
//  HLS Date:       Thu Feb 10 22:05:20 PST 2022
// 
//  Generated by:   yzhang919@eic-gt-cpu1
//  Generated date: Thu Feb 29 06:06:56 2024
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_core_fsm
    (
  clk, rst, AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp, fsm_output, FMAP_PSUM_HEIGHT_C_0_tr0
);
  input clk;
  input rst;
  input AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;
  input FMAP_PSUM_HEIGHT_C_0_tr0;


  // FSM State Type Declaration for branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_core_fsm_1
  parameter
    main_C_0 = 1'd0,
    FMAP_PSUM_HEIGHT_C_0 = 1'd1;

  reg  state_var;
  reg  state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_core_fsm_1
    case (state_var)
      FMAP_PSUM_HEIGHT_C_0 : begin
        fsm_output = 2'b10;
        if ( FMAP_PSUM_HEIGHT_C_0_tr0 ) begin
          state_var_NS = main_C_0;
        end
        else begin
          state_var_NS = FMAP_PSUM_HEIGHT_C_0;
        end
      end
      // main_C_0
      default : begin
        fsm_output = 2'b01;
        state_var_NS = FMAP_PSUM_HEIGHT_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( rst ) begin
      state_var <= main_C_0;
    end
    else if ( AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_staller
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_staller
    (
  clk, rst, core_wten, AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp
);
  input clk;
  input rst;
  output core_wten;
  reg core_wten;
  input AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  always @(posedge clk) begin
    if ( rst ) begin
      core_wten <= 1'b0;
    end
    else begin
      core_wten <= ~ AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_mgc_rom_sync_40_4_12000001
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_mgc_rom_sync_40_4_12000001
    (
  clk, rst, FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out_mxwt,
      FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_biwt,
      FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_bdwt,
      FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out
);
  input clk;
  input rst;
  output [11:0] FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out_mxwt;
  input FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_biwt;
  input FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_bdwt;
  input [11:0] FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out;


  // Interconnect Declarations
  reg FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_bcwt;
  reg [11:0] FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out_mxwt
      = MUX_v_12_2_2(FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out,
      FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out_bfwt,
      FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_bcwt);
  always @(posedge clk) begin
    if ( rst ) begin
      FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_bcwt
          <= 1'b0;
    end
    else begin
      FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_bcwt
          <= ~((~(FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_bcwt
          | FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_biwt))
          | FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_biwt
        ) begin
      FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out_bfwt
          <= FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out;
    end
  end

  function automatic [11:0] MUX_v_12_2_2;
    input [11:0] input_0;
    input [11:0] input_1;
    input  sel;
    reg [11:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_12_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_mgc_rom_sync_40_4_12000000
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_mgc_rom_sync_40_4_12000000
    (
  core_wen, core_wten, FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_oswt,
      FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_biwt,
      FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_bdwt
);
  input core_wen;
  input core_wten;
  input FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_oswt;
  output FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_biwt;
  output FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_bdwt;



  // Interconnect Declarations for Component Instantiations 
  assign FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_bdwt
      = FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_oswt
      & core_wen;
  assign FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_biwt
      = (~ core_wten) & FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_oswt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_wait_dp
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_wait_dp
    (
  clk, rst, AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy, AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg
);
  input clk;
  input rst;
  input AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy;
  output AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg;


  // Interconnect Declarations
  reg AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg = ~ AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg_rneg;
  always @(posedge clk) begin
    if ( rst ) begin
      AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg_rneg <= 1'b0;
    end
    else begin
      AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg_rneg <= ~ AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_AC_CH_ID99580272_func0_fc_bias_shape_4_wait_dp
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_AC_CH_ID99580272_func0_fc_bias_shape_4_wait_dp
    (
  clk, rst, AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_oswt, AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp,
      AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_biwt, AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bdwt,
      AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bcwt
);
  input clk;
  input rst;
  input AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_oswt;
  output AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp;
  input AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_biwt;
  input AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bdwt;
  output AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bcwt;
  reg AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp = (~ AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_oswt)
      | AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_biwt | AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bcwt <= 1'b0;
    end
    else begin
      AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bcwt <= ~((~(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bcwt
          | AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_biwt)) | AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_AC_CH_ID99580272_func0_fc_bias_shape_4_wait_ctrl
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_AC_CH_ID99580272_func0_fc_bias_shape_4_wait_ctrl
    (
  core_wen, AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_oswt, AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg,
      AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_biwt, AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bdwt,
      AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bcwt, AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_ivld_core_sct
);
  input core_wen;
  input AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_oswt;
  input AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg;
  output AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_biwt;
  output AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bdwt;
  input AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bcwt;
  output AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bdwt = AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_oswt
      & core_wen;
  assign AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_biwt = AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_ogwt
      & AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg;
  assign AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_ogwt = AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_oswt
      & (~ AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bcwt);
  assign AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_ivld_core_sct = AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_core_fsm
    (
  clk, rst, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp, fsm_output,
      W_HEIGHT_C_0_tr0
);
  input clk;
  input rst;
  input AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;
  input W_HEIGHT_C_0_tr0;


  // FSM State Type Declaration for branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_core_fsm_1
  parameter
    main_C_0 = 1'd0,
    W_HEIGHT_C_0 = 1'd1;

  reg  state_var;
  reg  state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_core_fsm_1
    case (state_var)
      W_HEIGHT_C_0 : begin
        fsm_output = 2'b10;
        if ( W_HEIGHT_C_0_tr0 ) begin
          state_var_NS = main_C_0;
        end
        else begin
          state_var_NS = W_HEIGHT_C_0;
        end
      end
      // main_C_0
      default : begin
        fsm_output = 2'b01;
        state_var_NS = W_HEIGHT_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( rst ) begin
      state_var <= main_C_0;
    end
    else if ( AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_staller
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_staller
    (
  clk, rst, core_wten, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp
);
  input clk;
  input rst;
  output core_wten;
  reg core_wten;
  input AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  always @(posedge clk) begin
    if ( rst ) begin
      core_wten <= 1'b0;
    end
    else begin
      core_wten <= ~ AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_mgc_rom_sync_38_4_288_1_1_wait_dp
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_mgc_rom_sync_38_4_288_1_1_wait_dp
    (
  clk, rst, W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt, W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_biwt,
      W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_bdwt, W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out
);
  input clk;
  input rst;
  output [252:0] W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt;
  input W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_biwt;
  input W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_bdwt;
  input [287:0] W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out;


  // Interconnect Declarations
  reg W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_bcwt;
  reg [287:0] W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_bfwt;
  wire [287:0] W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst;


  // Interconnect Declarations for Component Instantiations 
  assign W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst = MUX_v_288_2_2(W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out,
      W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_bfwt, W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_bcwt);
  assign W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt = {(W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[287:266])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[264:260])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[258:257])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[255:249])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[247:244])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[242:233])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[231:229])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[224])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[222:214])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[212:209])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[207:203])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[201:187])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[185:166])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[164:158])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[156])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[152])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[150:143])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[141:129])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[127])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[125:113])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[111:109])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[107:106])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[104:86])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[84:72])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[70:69])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[66:55])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[53:44])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[42:20])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[18:10])
      , (W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst[8:0])};
  always @(posedge clk) begin
    if ( rst ) begin
      W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_bcwt <= 1'b0;
    end
    else begin
      W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_bcwt <= ~((~(W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_bcwt
          | W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_biwt)) | W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_biwt ) begin
      W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_bfwt <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out;
    end
  end

  function automatic [287:0] MUX_v_288_2_2;
    input [287:0] input_0;
    input [287:0] input_1;
    input  sel;
    reg [287:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_288_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_mgc_rom_sync_38_4_288_1_1_wait_ctrl
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_mgc_rom_sync_38_4_288_1_1_wait_ctrl
    (
  core_wen, core_wten, W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_oswt, W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_biwt,
      W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_bdwt
);
  input core_wen;
  input core_wten;
  input W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_oswt;
  output W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_biwt;
  output W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_bdwt;



  // Interconnect Declarations for Component Instantiations 
  assign W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_bdwt = W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_oswt
      & core_wen;
  assign W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_biwt = (~ core_wten) & W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_oswt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_wait_dp
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_wait_dp
    (
  clk, rst, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg
);
  input clk;
  input rst;
  input AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy;
  output AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg;


  // Interconnect Declarations
  reg AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg = ~ AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg_rneg;
  always @(posedge clk) begin
    if ( rst ) begin
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg_rneg <= 1'b0;
    end
    else begin
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg_rneg <= ~ AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_AC_CH_ID104977024_func0_fc_weight_shape_4000001
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_AC_CH_ID104977024_func0_fc_weight_shape_4000001
    (
  clk, rst, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_oswt, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp,
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_biwt, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bdwt,
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bcwt
);
  input clk;
  input rst;
  input AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_oswt;
  output AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp;
  input AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_biwt;
  input AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bdwt;
  output AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bcwt;
  reg AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp = (~ AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_oswt)
      | AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_biwt | AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bcwt <= 1'b0;
    end
    else begin
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bcwt <= ~((~(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bcwt
          | AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_biwt)) | AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_AC_CH_ID104977024_func0_fc_weight_shape_4000000
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_AC_CH_ID104977024_func0_fc_weight_shape_4000000
    (
  core_wen, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_oswt, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg,
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_biwt, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bdwt,
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bcwt, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_ivld_core_sct
);
  input core_wen;
  input AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_oswt;
  input AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg;
  output AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_biwt;
  output AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bdwt;
  input AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bcwt;
  output AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bdwt = AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_oswt
      & core_wen;
  assign AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_biwt = AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_ogwt
      & AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg;
  assign AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_ogwt = AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_oswt
      & (~ AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bcwt);
  assign AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_ivld_core_sct = AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_run_fsm
//  FSM Module
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_run_fsm
    (
  clk, rst, run_wen, fsm_output, FMAP_WIDTH_HWC_C_2_tr0, FMAP_HEIGHT_HWC_C_1_tr0
);
  input clk;
  input rst;
  input run_wen;
  output [5:0] fsm_output;
  reg [5:0] fsm_output;
  input FMAP_WIDTH_HWC_C_2_tr0;
  input FMAP_HEIGHT_HWC_C_1_tr0;


  // FSM State Type Declaration for branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_run_fsm_1
  parameter
    main_C_0 = 3'd0,
    FMAP_HEIGHT_HWC_C_0 = 3'd1,
    FMAP_WIDTH_HWC_C_0 = 3'd2,
    FMAP_WIDTH_HWC_C_1 = 3'd3,
    FMAP_WIDTH_HWC_C_2 = 3'd4,
    FMAP_HEIGHT_HWC_C_1 = 3'd5;

  reg [2:0] state_var;
  reg [2:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_run_fsm_1
    case (state_var)
      FMAP_HEIGHT_HWC_C_0 : begin
        fsm_output = 6'b000010;
        state_var_NS = FMAP_WIDTH_HWC_C_0;
      end
      FMAP_WIDTH_HWC_C_0 : begin
        fsm_output = 6'b000100;
        state_var_NS = FMAP_WIDTH_HWC_C_1;
      end
      FMAP_WIDTH_HWC_C_1 : begin
        fsm_output = 6'b001000;
        state_var_NS = FMAP_WIDTH_HWC_C_2;
      end
      FMAP_WIDTH_HWC_C_2 : begin
        fsm_output = 6'b010000;
        if ( FMAP_WIDTH_HWC_C_2_tr0 ) begin
          state_var_NS = FMAP_HEIGHT_HWC_C_1;
        end
        else begin
          state_var_NS = FMAP_WIDTH_HWC_C_0;
        end
      end
      FMAP_HEIGHT_HWC_C_1 : begin
        fsm_output = 6'b100000;
        if ( FMAP_HEIGHT_HWC_C_1_tr0 ) begin
          state_var_NS = main_C_0;
        end
        else begin
          state_var_NS = FMAP_HEIGHT_HWC_C_0;
        end
      end
      // main_C_0
      default : begin
        fsm_output = 6'b000001;
        state_var_NS = FMAP_HEIGHT_HWC_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( rst ) begin
      state_var <= main_C_0;
    end
    else if ( run_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_staller
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_staller
    (
  run_wen, din_rsci_wen_comp, dout_rsci_wen_comp
);
  output run_wen;
  input din_rsci_wen_comp;
  input dout_rsci_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign run_wen = din_rsci_wen_comp & dout_rsci_wen_comp;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_dout_rsci_dout_wait_ctrl
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_dout_rsci_dout_wait_ctrl
    (
  dout_rsci_iswt0, dout_rsci_irdy_oreg, dout_rsci_biwt
);
  input dout_rsci_iswt0;
  input dout_rsci_irdy_oreg;
  output dout_rsci_biwt;



  // Interconnect Declarations for Component Instantiations 
  assign dout_rsci_biwt = dout_rsci_iswt0 & dout_rsci_irdy_oreg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_din_rsci_din_wait_ctrl
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_din_rsci_din_wait_ctrl
    (
  din_rsci_iswt0, din_rsci_ivld_oreg, din_rsci_biwt
);
  input din_rsci_iswt0;
  input din_rsci_ivld_oreg;
  output din_rsci_biwt;



  // Interconnect Declarations for Component Instantiations 
  assign din_rsci_biwt = din_rsci_iswt0 & din_rsci_ivld_oreg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_run_fsm
//  FSM Module
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_run_fsm
    (
  clk, rst, run_wen, fsm_output, FMAP_WIDTH_C_1_tr0, OUT_CHAN_C_0_tr0, FMAP_WIDTH_C_2_tr0,
      FMAP_HEIGHT_C_0_tr0
);
  input clk;
  input rst;
  input run_wen;
  output [5:0] fsm_output;
  reg [5:0] fsm_output;
  input FMAP_WIDTH_C_1_tr0;
  input OUT_CHAN_C_0_tr0;
  input FMAP_WIDTH_C_2_tr0;
  input FMAP_HEIGHT_C_0_tr0;


  // FSM State Type Declaration for branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_run_fsm_1
  parameter
    main_C_0 = 3'd0,
    FMAP_WIDTH_C_0 = 3'd1,
    FMAP_WIDTH_C_1 = 3'd2,
    OUT_CHAN_C_0 = 3'd3,
    FMAP_WIDTH_C_2 = 3'd4,
    FMAP_HEIGHT_C_0 = 3'd5;

  reg [2:0] state_var;
  reg [2:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_run_fsm_1
    case (state_var)
      FMAP_WIDTH_C_0 : begin
        fsm_output = 6'b000010;
        state_var_NS = FMAP_WIDTH_C_1;
      end
      FMAP_WIDTH_C_1 : begin
        fsm_output = 6'b000100;
        if ( FMAP_WIDTH_C_1_tr0 ) begin
          state_var_NS = FMAP_WIDTH_C_2;
        end
        else begin
          state_var_NS = OUT_CHAN_C_0;
        end
      end
      OUT_CHAN_C_0 : begin
        fsm_output = 6'b001000;
        if ( OUT_CHAN_C_0_tr0 ) begin
          state_var_NS = FMAP_WIDTH_C_2;
        end
        else begin
          state_var_NS = OUT_CHAN_C_0;
        end
      end
      FMAP_WIDTH_C_2 : begin
        fsm_output = 6'b010000;
        if ( FMAP_WIDTH_C_2_tr0 ) begin
          state_var_NS = FMAP_HEIGHT_C_0;
        end
        else begin
          state_var_NS = FMAP_WIDTH_C_0;
        end
      end
      FMAP_HEIGHT_C_0 : begin
        fsm_output = 6'b100000;
        if ( FMAP_HEIGHT_C_0_tr0 ) begin
          state_var_NS = main_C_0;
        end
        else begin
          state_var_NS = FMAP_WIDTH_C_0;
        end
      end
      // main_C_0
      default : begin
        fsm_output = 6'b000001;
        state_var_NS = FMAP_WIDTH_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( rst ) begin
      state_var <= main_C_0;
    end
    else if ( run_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_staller
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_staller
    (
  run_wen, din_rsci_wen_comp, kernelIn_rsci_wen_comp, dout_rsci_wen_comp
);
  output run_wen;
  input din_rsci_wen_comp;
  input kernelIn_rsci_wen_comp;
  input dout_rsci_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign run_wen = din_rsci_wen_comp & kernelIn_rsci_wen_comp & dout_rsci_wen_comp;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_dout_rsci_dout_wait_dp
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_dout_rsci_dout_wait_dp
    (
  clk, rst, dout_rsci_oswt, dout_rsci_wen_comp, dout_rsci_biwt, dout_rsci_bdwt, dout_rsci_bcwt,
      dout_rsci_biwt_pff, dout_rsci_bcwt_pff
);
  input clk;
  input rst;
  input dout_rsci_oswt;
  output dout_rsci_wen_comp;
  input dout_rsci_biwt;
  input dout_rsci_bdwt;
  output dout_rsci_bcwt;
  input dout_rsci_biwt_pff;
  output dout_rsci_bcwt_pff;


  // Interconnect Declarations
  reg dout_rsci_bcwt_reg;
  wire OUT_CHAN_nor_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign OUT_CHAN_nor_rmff = ~((~(dout_rsci_bcwt | dout_rsci_biwt)) | dout_rsci_bdwt);
  assign dout_rsci_wen_comp = (~ dout_rsci_oswt) | dout_rsci_biwt_pff | dout_rsci_bcwt_pff;
  assign dout_rsci_bcwt = dout_rsci_bcwt_reg;
  assign dout_rsci_bcwt_pff = OUT_CHAN_nor_rmff;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_rsci_bcwt_reg <= 1'b0;
    end
    else begin
      dout_rsci_bcwt_reg <= OUT_CHAN_nor_rmff;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_dout_rsci_dout_wait_ctrl
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_dout_rsci_dout_wait_ctrl
    (
  run_wen, dout_rsci_oswt, dout_rsci_irdy_oreg, dout_rsci_biwt, dout_rsci_bdwt, dout_rsci_bcwt,
      dout_rsci_ivld_run_sct, dout_rsci_biwt_pff, dout_rsci_oswt_pff, dout_rsci_bcwt_pff,
      dout_rsci_irdy_oreg_pff
);
  input run_wen;
  input dout_rsci_oswt;
  input dout_rsci_irdy_oreg;
  output dout_rsci_biwt;
  output dout_rsci_bdwt;
  input dout_rsci_bcwt;
  output dout_rsci_ivld_run_sct;
  output dout_rsci_biwt_pff;
  input dout_rsci_oswt_pff;
  input dout_rsci_bcwt_pff;
  input dout_rsci_irdy_oreg_pff;


  // Interconnect Declarations
  wire dout_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_rsci_bdwt = dout_rsci_oswt & run_wen;
  assign dout_rsci_ogwt = dout_rsci_oswt & (~ dout_rsci_bcwt);
  assign dout_rsci_ivld_run_sct = dout_rsci_ogwt;
  assign dout_rsci_biwt = dout_rsci_ogwt & dout_rsci_irdy_oreg;
  assign dout_rsci_biwt_pff = dout_rsci_oswt_pff & (~ dout_rsci_bcwt_pff) & dout_rsci_irdy_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_kernelIn_rsci_kernelIn_wait_dp
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_kernelIn_rsci_kernelIn_wait_dp
    (
  clk, rst, kernelIn_rsci_oswt, kernelIn_rsci_wen_comp, kernelIn_rsci_idat_mxwt,
      kernelIn_rsci_biwt, kernelIn_rsci_bdwt, kernelIn_rsci_bcwt, kernelIn_rsci_idat,
      kernelIn_rsci_biwt_pff, kernelIn_rsci_bcwt_pff
);
  input clk;
  input rst;
  input kernelIn_rsci_oswt;
  output kernelIn_rsci_wen_comp;
  output [287:0] kernelIn_rsci_idat_mxwt;
  input kernelIn_rsci_biwt;
  input kernelIn_rsci_bdwt;
  output kernelIn_rsci_bcwt;
  input [287:0] kernelIn_rsci_idat;
  input kernelIn_rsci_biwt_pff;
  output kernelIn_rsci_bcwt_pff;


  // Interconnect Declarations
  reg [287:0] kernelIn_rsci_idat_bfwt;
  reg kernelIn_rsci_bcwt_reg;
  wire OUT_CHAN_PACK_KERNEL_RD_nor_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign OUT_CHAN_PACK_KERNEL_RD_nor_rmff = ~((~(kernelIn_rsci_bcwt | kernelIn_rsci_biwt))
      | kernelIn_rsci_bdwt);
  assign kernelIn_rsci_idat_mxwt = MUX_v_288_2_2(kernelIn_rsci_idat, kernelIn_rsci_idat_bfwt,
      kernelIn_rsci_bcwt);
  assign kernelIn_rsci_wen_comp = (~ kernelIn_rsci_oswt) | kernelIn_rsci_biwt_pff
      | kernelIn_rsci_bcwt_pff;
  assign kernelIn_rsci_bcwt = kernelIn_rsci_bcwt_reg;
  assign kernelIn_rsci_bcwt_pff = OUT_CHAN_PACK_KERNEL_RD_nor_rmff;
  always @(posedge clk) begin
    if ( rst ) begin
      kernelIn_rsci_bcwt_reg <= 1'b0;
    end
    else begin
      kernelIn_rsci_bcwt_reg <= OUT_CHAN_PACK_KERNEL_RD_nor_rmff;
    end
  end
  always @(posedge clk) begin
    if ( kernelIn_rsci_biwt ) begin
      kernelIn_rsci_idat_bfwt <= kernelIn_rsci_idat;
    end
  end

  function automatic [287:0] MUX_v_288_2_2;
    input [287:0] input_0;
    input [287:0] input_1;
    input  sel;
    reg [287:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_288_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_kernelIn_rsci_kernelIn_wait_ctrl
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_kernelIn_rsci_kernelIn_wait_ctrl
    (
  run_wen, kernelIn_rsci_oswt, kernelIn_rsci_ivld_oreg, kernelIn_rsci_biwt, kernelIn_rsci_bdwt,
      kernelIn_rsci_bcwt, kernelIn_rsci_irdy_run_sct, kernelIn_rsci_biwt_pff, kernelIn_rsci_oswt_pff,
      kernelIn_rsci_bcwt_pff, kernelIn_rsci_ivld_oreg_pff
);
  input run_wen;
  input kernelIn_rsci_oswt;
  input kernelIn_rsci_ivld_oreg;
  output kernelIn_rsci_biwt;
  output kernelIn_rsci_bdwt;
  input kernelIn_rsci_bcwt;
  output kernelIn_rsci_irdy_run_sct;
  output kernelIn_rsci_biwt_pff;
  input kernelIn_rsci_oswt_pff;
  input kernelIn_rsci_bcwt_pff;
  input kernelIn_rsci_ivld_oreg_pff;


  // Interconnect Declarations
  wire kernelIn_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign kernelIn_rsci_bdwt = kernelIn_rsci_oswt & run_wen;
  assign kernelIn_rsci_ogwt = kernelIn_rsci_oswt & (~ kernelIn_rsci_bcwt);
  assign kernelIn_rsci_irdy_run_sct = kernelIn_rsci_ogwt;
  assign kernelIn_rsci_biwt = kernelIn_rsci_ogwt & kernelIn_rsci_ivld_oreg;
  assign kernelIn_rsci_biwt_pff = kernelIn_rsci_oswt_pff & (~ kernelIn_rsci_bcwt_pff)
      & kernelIn_rsci_ivld_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_wait_dp
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_wait_dp
    (
  clk, rst, kernelIn_rsci_ivld, kernelIn_rsci_ivld_oreg, dout_rsci_irdy, dout_rsci_irdy_oreg
);
  input clk;
  input rst;
  input kernelIn_rsci_ivld;
  output kernelIn_rsci_ivld_oreg;
  input dout_rsci_irdy;
  output dout_rsci_irdy_oreg;


  // Interconnect Declarations
  reg kernelIn_rsci_ivld_oreg_rneg;
  reg dout_rsci_irdy_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign kernelIn_rsci_ivld_oreg = ~ kernelIn_rsci_ivld_oreg_rneg;
  assign dout_rsci_irdy_oreg = ~ dout_rsci_irdy_oreg_rneg;
  always @(posedge clk) begin
    if ( rst ) begin
      kernelIn_rsci_ivld_oreg_rneg <= 1'b0;
      dout_rsci_irdy_oreg_rneg <= 1'b0;
    end
    else begin
      kernelIn_rsci_ivld_oreg_rneg <= ~ kernelIn_rsci_ivld;
      dout_rsci_irdy_oreg_rneg <= ~ dout_rsci_irdy;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_din_rsci_din_wait_ctrl
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_din_rsci_din_wait_ctrl
    (
  din_rsci_iswt0, din_rsci_ivld_oreg, din_rsci_biwt
);
  input din_rsci_iswt0;
  input din_rsci_ivld_oreg;
  output din_rsci_biwt;



  // Interconnect Declarations for Component Instantiations 
  assign din_rsci_biwt = din_rsci_iswt0 & din_rsci_ivld_oreg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_run_fsm
//  FSM Module
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_run_fsm
    (
  clk, rst, run_wen, fsm_output, FMAP_PSUM_OCHAN_C_0_tr0, FMAP_PSUM_WIDTH_C_0_tr0,
      FMAP_PSUM_HEIGHT_C_0_tr0
);
  input clk;
  input rst;
  input run_wen;
  output [3:0] fsm_output;
  reg [3:0] fsm_output;
  input FMAP_PSUM_OCHAN_C_0_tr0;
  input FMAP_PSUM_WIDTH_C_0_tr0;
  input FMAP_PSUM_HEIGHT_C_0_tr0;


  // FSM State Type Declaration for branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_run_fsm_1
  parameter
    main_C_0 = 2'd0,
    FMAP_PSUM_OCHAN_C_0 = 2'd1,
    FMAP_PSUM_WIDTH_C_0 = 2'd2,
    FMAP_PSUM_HEIGHT_C_0 = 2'd3;

  reg [1:0] state_var;
  reg [1:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_run_fsm_1
    case (state_var)
      FMAP_PSUM_OCHAN_C_0 : begin
        fsm_output = 4'b0010;
        if ( FMAP_PSUM_OCHAN_C_0_tr0 ) begin
          state_var_NS = FMAP_PSUM_WIDTH_C_0;
        end
        else begin
          state_var_NS = FMAP_PSUM_OCHAN_C_0;
        end
      end
      FMAP_PSUM_WIDTH_C_0 : begin
        fsm_output = 4'b0100;
        if ( FMAP_PSUM_WIDTH_C_0_tr0 ) begin
          state_var_NS = FMAP_PSUM_HEIGHT_C_0;
        end
        else begin
          state_var_NS = FMAP_PSUM_OCHAN_C_0;
        end
      end
      FMAP_PSUM_HEIGHT_C_0 : begin
        fsm_output = 4'b1000;
        if ( FMAP_PSUM_HEIGHT_C_0_tr0 ) begin
          state_var_NS = main_C_0;
        end
        else begin
          state_var_NS = FMAP_PSUM_OCHAN_C_0;
        end
      end
      // main_C_0
      default : begin
        fsm_output = 4'b0001;
        state_var_NS = FMAP_PSUM_OCHAN_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( rst ) begin
      state_var <= main_C_0;
    end
    else if ( run_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_staller
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_staller
    (
  run_wen, din_rsci_wen_comp, bias_rsci_wen_comp, dout_rsci_wen_comp
);
  output run_wen;
  input din_rsci_wen_comp;
  input bias_rsci_wen_comp;
  input dout_rsci_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign run_wen = din_rsci_wen_comp & bias_rsci_wen_comp & dout_rsci_wen_comp;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_dout_rsci_dout_wait_dp
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_dout_rsci_dout_wait_dp
    (
  clk, rst, dout_rsci_oswt, dout_rsci_wen_comp, dout_rsci_biwt, dout_rsci_bdwt, dout_rsci_bcwt,
      dout_rsci_biwt_pff, dout_rsci_bcwt_pff
);
  input clk;
  input rst;
  input dout_rsci_oswt;
  output dout_rsci_wen_comp;
  input dout_rsci_biwt;
  input dout_rsci_bdwt;
  output dout_rsci_bcwt;
  input dout_rsci_biwt_pff;
  output dout_rsci_bcwt_pff;


  // Interconnect Declarations
  reg dout_rsci_bcwt_reg;
  wire FMAP_PSUM_OCHAN_if_1_nor_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign FMAP_PSUM_OCHAN_if_1_nor_rmff = ~((~(dout_rsci_bcwt | dout_rsci_biwt)) |
      dout_rsci_bdwt);
  assign dout_rsci_wen_comp = (~ dout_rsci_oswt) | dout_rsci_biwt_pff | dout_rsci_bcwt_pff;
  assign dout_rsci_bcwt = dout_rsci_bcwt_reg;
  assign dout_rsci_bcwt_pff = FMAP_PSUM_OCHAN_if_1_nor_rmff;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_rsci_bcwt_reg <= 1'b0;
    end
    else begin
      dout_rsci_bcwt_reg <= FMAP_PSUM_OCHAN_if_1_nor_rmff;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_dout_rsci_dout_wait_ctrl
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_dout_rsci_dout_wait_ctrl
    (
  run_wen, dout_rsci_oswt, dout_rsci_irdy_oreg, dout_rsci_biwt, dout_rsci_bdwt, dout_rsci_bcwt,
      dout_rsci_ivld_run_sct, dout_rsci_biwt_pff, dout_rsci_oswt_pff, dout_rsci_bcwt_pff,
      dout_rsci_irdy_oreg_pff
);
  input run_wen;
  input dout_rsci_oswt;
  input dout_rsci_irdy_oreg;
  output dout_rsci_biwt;
  output dout_rsci_bdwt;
  input dout_rsci_bcwt;
  output dout_rsci_ivld_run_sct;
  output dout_rsci_biwt_pff;
  input dout_rsci_oswt_pff;
  input dout_rsci_bcwt_pff;
  input dout_rsci_irdy_oreg_pff;


  // Interconnect Declarations
  wire dout_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_rsci_bdwt = dout_rsci_oswt & run_wen;
  assign dout_rsci_ogwt = dout_rsci_oswt & (~ dout_rsci_bcwt);
  assign dout_rsci_ivld_run_sct = dout_rsci_ogwt;
  assign dout_rsci_biwt = dout_rsci_ogwt & dout_rsci_irdy_oreg;
  assign dout_rsci_biwt_pff = dout_rsci_oswt_pff & (~ dout_rsci_bcwt_pff) & dout_rsci_irdy_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_bias_rsci_bias_wait_dp
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_bias_rsci_bias_wait_dp
    (
  clk, rst, bias_rsci_oswt, bias_rsci_wen_comp, bias_rsci_idat_mxwt, bias_rsci_biwt,
      bias_rsci_bdwt, bias_rsci_bcwt, bias_rsci_idat, bias_rsci_biwt_pff, bias_rsci_bcwt_pff
);
  input clk;
  input rst;
  input bias_rsci_oswt;
  output bias_rsci_wen_comp;
  output [25:0] bias_rsci_idat_mxwt;
  input bias_rsci_biwt;
  input bias_rsci_bdwt;
  output bias_rsci_bcwt;
  input [31:0] bias_rsci_idat;
  input bias_rsci_biwt_pff;
  output bias_rsci_bcwt_pff;


  // Interconnect Declarations
  reg [25:0] bias_rsci_idat_bfwt_25_0;
  reg bias_rsci_bcwt_reg;
  wire FMAP_PSUM_OCHAN_if_nor_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign FMAP_PSUM_OCHAN_if_nor_rmff = ~((~(bias_rsci_bcwt | bias_rsci_biwt)) | bias_rsci_bdwt);
  assign bias_rsci_idat_mxwt = MUX_v_26_2_2((bias_rsci_idat[25:0]), bias_rsci_idat_bfwt_25_0,
      bias_rsci_bcwt);
  assign bias_rsci_wen_comp = (~ bias_rsci_oswt) | bias_rsci_biwt_pff | bias_rsci_bcwt_pff;
  assign bias_rsci_bcwt = bias_rsci_bcwt_reg;
  assign bias_rsci_bcwt_pff = FMAP_PSUM_OCHAN_if_nor_rmff;
  always @(posedge clk) begin
    if ( rst ) begin
      bias_rsci_bcwt_reg <= 1'b0;
    end
    else begin
      bias_rsci_bcwt_reg <= FMAP_PSUM_OCHAN_if_nor_rmff;
    end
  end
  always @(posedge clk) begin
    if ( bias_rsci_biwt ) begin
      bias_rsci_idat_bfwt_25_0 <= bias_rsci_idat[25:0];
    end
  end

  function automatic [25:0] MUX_v_26_2_2;
    input [25:0] input_0;
    input [25:0] input_1;
    input  sel;
    reg [25:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_26_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_bias_rsci_bias_wait_ctrl
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_bias_rsci_bias_wait_ctrl
    (
  run_wen, bias_rsci_oswt, bias_rsci_ivld_oreg, bias_rsci_biwt, bias_rsci_bdwt, bias_rsci_bcwt,
      bias_rsci_irdy_run_sct, bias_rsci_biwt_pff, bias_rsci_oswt_pff, bias_rsci_bcwt_pff,
      bias_rsci_ivld_oreg_pff
);
  input run_wen;
  input bias_rsci_oswt;
  input bias_rsci_ivld_oreg;
  output bias_rsci_biwt;
  output bias_rsci_bdwt;
  input bias_rsci_bcwt;
  output bias_rsci_irdy_run_sct;
  output bias_rsci_biwt_pff;
  input bias_rsci_oswt_pff;
  input bias_rsci_bcwt_pff;
  input bias_rsci_ivld_oreg_pff;


  // Interconnect Declarations
  wire bias_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign bias_rsci_bdwt = bias_rsci_oswt & run_wen;
  assign bias_rsci_ogwt = bias_rsci_oswt & (~ bias_rsci_bcwt);
  assign bias_rsci_irdy_run_sct = bias_rsci_ogwt;
  assign bias_rsci_biwt = bias_rsci_ogwt & bias_rsci_ivld_oreg;
  assign bias_rsci_biwt_pff = bias_rsci_oswt_pff & (~ bias_rsci_bcwt_pff) & bias_rsci_ivld_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_wait_dp
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_wait_dp
    (
  clk, rst, din_rsci_ivld, din_rsci_ivld_oreg, bias_rsci_ivld, bias_rsci_ivld_oreg,
      dout_rsci_irdy, dout_rsci_irdy_oreg
);
  input clk;
  input rst;
  input din_rsci_ivld;
  output din_rsci_ivld_oreg;
  input bias_rsci_ivld;
  output bias_rsci_ivld_oreg;
  input dout_rsci_irdy;
  output dout_rsci_irdy_oreg;


  // Interconnect Declarations
  reg din_rsci_ivld_oreg_rneg;
  reg bias_rsci_ivld_oreg_rneg;
  reg dout_rsci_irdy_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign din_rsci_ivld_oreg = ~ din_rsci_ivld_oreg_rneg;
  assign bias_rsci_ivld_oreg = ~ bias_rsci_ivld_oreg_rneg;
  assign dout_rsci_irdy_oreg = ~ dout_rsci_irdy_oreg_rneg;
  always @(posedge clk) begin
    if ( rst ) begin
      din_rsci_ivld_oreg_rneg <= 1'b0;
      bias_rsci_ivld_oreg_rneg <= 1'b0;
      dout_rsci_irdy_oreg_rneg <= 1'b0;
    end
    else begin
      din_rsci_ivld_oreg_rneg <= ~ din_rsci_ivld;
      bias_rsci_ivld_oreg_rneg <= ~ bias_rsci_ivld;
      dout_rsci_irdy_oreg_rneg <= ~ dout_rsci_irdy;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_din_rsci_din_wait_dp
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_din_rsci_din_wait_dp
    (
  clk, rst, din_rsci_oswt, din_rsci_wen_comp, din_rsci_idat_mxwt, din_rsci_biwt,
      din_rsci_bdwt, din_rsci_bcwt, din_rsci_idat, din_rsci_biwt_pff, din_rsci_bcwt_pff
);
  input clk;
  input rst;
  input din_rsci_oswt;
  output din_rsci_wen_comp;
  output [22:0] din_rsci_idat_mxwt;
  input din_rsci_biwt;
  input din_rsci_bdwt;
  output din_rsci_bcwt;
  input [22:0] din_rsci_idat;
  input din_rsci_biwt_pff;
  output din_rsci_bcwt_pff;


  // Interconnect Declarations
  reg [22:0] din_rsci_idat_bfwt;
  reg din_rsci_bcwt_reg;
  wire FMAP_PSUM_OCHAN_nor_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign FMAP_PSUM_OCHAN_nor_rmff = ~((~(din_rsci_bcwt | din_rsci_biwt)) | din_rsci_bdwt);
  assign din_rsci_idat_mxwt = MUX_v_23_2_2(din_rsci_idat, din_rsci_idat_bfwt, din_rsci_bcwt);
  assign din_rsci_wen_comp = (~ din_rsci_oswt) | din_rsci_biwt_pff | din_rsci_bcwt_pff;
  assign din_rsci_bcwt = din_rsci_bcwt_reg;
  assign din_rsci_bcwt_pff = FMAP_PSUM_OCHAN_nor_rmff;
  always @(posedge clk) begin
    if ( rst ) begin
      din_rsci_bcwt_reg <= 1'b0;
    end
    else begin
      din_rsci_bcwt_reg <= FMAP_PSUM_OCHAN_nor_rmff;
    end
  end
  always @(posedge clk) begin
    if ( din_rsci_biwt ) begin
      din_rsci_idat_bfwt <= din_rsci_idat;
    end
  end

  function automatic [22:0] MUX_v_23_2_2;
    input [22:0] input_0;
    input [22:0] input_1;
    input  sel;
    reg [22:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_23_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_din_rsci_din_wait_ctrl
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_din_rsci_din_wait_ctrl
    (
  run_wen, din_rsci_oswt, din_rsci_ivld_oreg, din_rsci_biwt, din_rsci_bdwt, din_rsci_bcwt,
      din_rsci_irdy_run_sct, din_rsci_biwt_pff, din_rsci_oswt_pff, din_rsci_bcwt_pff,
      din_rsci_ivld_oreg_pff
);
  input run_wen;
  input din_rsci_oswt;
  input din_rsci_ivld_oreg;
  output din_rsci_biwt;
  output din_rsci_bdwt;
  input din_rsci_bcwt;
  output din_rsci_irdy_run_sct;
  output din_rsci_biwt_pff;
  input din_rsci_oswt_pff;
  input din_rsci_bcwt_pff;
  input din_rsci_ivld_oreg_pff;


  // Interconnect Declarations
  wire din_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_rsci_bdwt = din_rsci_oswt & run_wen;
  assign din_rsci_ogwt = din_rsci_oswt & (~ din_rsci_bcwt);
  assign din_rsci_irdy_run_sct = din_rsci_ogwt;
  assign din_rsci_biwt = din_rsci_ogwt & din_rsci_ivld_oreg;
  assign din_rsci_biwt_pff = din_rsci_oswt_pff & (~ din_rsci_bcwt_pff) & din_rsci_ivld_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_run_fsm
//  FSM Module
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_run_fsm
    (
  clk, rst, run_wen, fsm_output, for_C_0_tr0
);
  input clk;
  input rst;
  input run_wen;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;
  input for_C_0_tr0;


  // FSM State Type Declaration for branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_run_fsm_1
  parameter
    main_C_0 = 1'd0,
    for_C_0 = 1'd1;

  reg  state_var;
  reg  state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_run_fsm_1
    case (state_var)
      for_C_0 : begin
        fsm_output = 2'b10;
        if ( for_C_0_tr0 ) begin
          state_var_NS = main_C_0;
        end
        else begin
          state_var_NS = for_C_0;
        end
      end
      // main_C_0
      default : begin
        fsm_output = 2'b01;
        state_var_NS = for_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( rst ) begin
      state_var <= main_C_0;
    end
    else if ( run_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_staller
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_staller
    (
  run_wen, din_rsci_wen_comp, dout_rsci_wen_comp
);
  output run_wen;
  input din_rsci_wen_comp;
  input dout_rsci_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign run_wen = din_rsci_wen_comp & dout_rsci_wen_comp;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_dout_rsci_dout_wait_dp
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_dout_rsci_dout_wait_dp
    (
  clk, rst, dout_rsci_oswt, dout_rsci_wen_comp, dout_rsci_biwt, dout_rsci_bdwt, dout_rsci_bcwt,
      dout_rsci_biwt_pff, dout_rsci_bcwt_pff
);
  input clk;
  input rst;
  input dout_rsci_oswt;
  output dout_rsci_wen_comp;
  input dout_rsci_biwt;
  input dout_rsci_bdwt;
  output dout_rsci_bcwt;
  input dout_rsci_biwt_pff;
  output dout_rsci_bcwt_pff;


  // Interconnect Declarations
  reg dout_rsci_bcwt_reg;
  wire for_nor_2_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign for_nor_2_rmff = ~((~(dout_rsci_bcwt | dout_rsci_biwt)) | dout_rsci_bdwt);
  assign dout_rsci_wen_comp = (~ dout_rsci_oswt) | dout_rsci_biwt_pff | dout_rsci_bcwt_pff;
  assign dout_rsci_bcwt = dout_rsci_bcwt_reg;
  assign dout_rsci_bcwt_pff = for_nor_2_rmff;
  always @(posedge clk) begin
    if ( rst ) begin
      dout_rsci_bcwt_reg <= 1'b0;
    end
    else begin
      dout_rsci_bcwt_reg <= for_nor_2_rmff;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_dout_rsci_dout_wait_ctrl
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_dout_rsci_dout_wait_ctrl
    (
  run_wen, dout_rsci_oswt, dout_rsci_irdy_oreg, dout_rsci_biwt, dout_rsci_bdwt, dout_rsci_bcwt,
      dout_rsci_ivld_run_sct, dout_rsci_biwt_pff, dout_rsci_oswt_pff, dout_rsci_bcwt_pff,
      dout_rsci_irdy_oreg_pff
);
  input run_wen;
  input dout_rsci_oswt;
  input dout_rsci_irdy_oreg;
  output dout_rsci_biwt;
  output dout_rsci_bdwt;
  input dout_rsci_bcwt;
  output dout_rsci_ivld_run_sct;
  output dout_rsci_biwt_pff;
  input dout_rsci_oswt_pff;
  input dout_rsci_bcwt_pff;
  input dout_rsci_irdy_oreg_pff;


  // Interconnect Declarations
  wire dout_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign dout_rsci_bdwt = dout_rsci_oswt & run_wen;
  assign dout_rsci_ogwt = dout_rsci_oswt & (~ dout_rsci_bcwt);
  assign dout_rsci_ivld_run_sct = dout_rsci_ogwt;
  assign dout_rsci_biwt = dout_rsci_ogwt & dout_rsci_irdy_oreg;
  assign dout_rsci_biwt_pff = dout_rsci_oswt_pff & (~ dout_rsci_bcwt_pff) & dout_rsci_irdy_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_wait_dp
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_wait_dp
    (
  clk, rst, din_rsci_ivld, din_rsci_ivld_oreg, dout_rsci_irdy, dout_rsci_irdy_oreg
);
  input clk;
  input rst;
  input din_rsci_ivld;
  output din_rsci_ivld_oreg;
  input dout_rsci_irdy;
  output dout_rsci_irdy_oreg;


  // Interconnect Declarations
  reg din_rsci_ivld_oreg_rneg;
  reg dout_rsci_irdy_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign din_rsci_ivld_oreg = ~ din_rsci_ivld_oreg_rneg;
  assign dout_rsci_irdy_oreg = ~ dout_rsci_irdy_oreg_rneg;
  always @(posedge clk) begin
    if ( rst ) begin
      din_rsci_ivld_oreg_rneg <= 1'b0;
      dout_rsci_irdy_oreg_rneg <= 1'b0;
    end
    else begin
      din_rsci_ivld_oreg_rneg <= ~ din_rsci_ivld;
      dout_rsci_irdy_oreg_rneg <= ~ dout_rsci_irdy;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_din_rsci_din_wait_dp
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_din_rsci_din_wait_dp
    (
  clk, rst, din_rsci_oswt, din_rsci_wen_comp, din_rsci_idat_mxwt, din_rsci_biwt,
      din_rsci_bdwt, din_rsci_bcwt, din_rsci_idat, din_rsci_biwt_pff, din_rsci_bcwt_pff
);
  input clk;
  input rst;
  input din_rsci_oswt;
  output din_rsci_wen_comp;
  output [25:0] din_rsci_idat_mxwt;
  input din_rsci_biwt;
  input din_rsci_bdwt;
  output din_rsci_bcwt;
  input [25:0] din_rsci_idat;
  input din_rsci_biwt_pff;
  output din_rsci_bcwt_pff;


  // Interconnect Declarations
  reg [25:0] din_rsci_idat_bfwt;
  reg din_rsci_bcwt_reg;
  wire for_nor_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign for_nor_rmff = ~((~(din_rsci_bcwt | din_rsci_biwt)) | din_rsci_bdwt);
  assign din_rsci_idat_mxwt = MUX_v_26_2_2(din_rsci_idat, din_rsci_idat_bfwt, din_rsci_bcwt);
  assign din_rsci_wen_comp = (~ din_rsci_oswt) | din_rsci_biwt_pff | din_rsci_bcwt_pff;
  assign din_rsci_bcwt = din_rsci_bcwt_reg;
  assign din_rsci_bcwt_pff = for_nor_rmff;
  always @(posedge clk) begin
    if ( rst ) begin
      din_rsci_bcwt_reg <= 1'b0;
    end
    else begin
      din_rsci_bcwt_reg <= for_nor_rmff;
    end
  end
  always @(posedge clk) begin
    if ( din_rsci_biwt ) begin
      din_rsci_idat_bfwt <= din_rsci_idat;
    end
  end

  function automatic [25:0] MUX_v_26_2_2;
    input [25:0] input_0;
    input [25:0] input_1;
    input  sel;
    reg [25:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_26_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_din_rsci_din_wait_ctrl
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_din_rsci_din_wait_ctrl
    (
  run_wen, din_rsci_oswt, din_rsci_ivld_oreg, din_rsci_biwt, din_rsci_bdwt, din_rsci_bcwt,
      din_rsci_irdy_run_sct, din_rsci_biwt_pff, din_rsci_oswt_pff, din_rsci_bcwt_pff,
      din_rsci_ivld_oreg_pff
);
  input run_wen;
  input din_rsci_oswt;
  input din_rsci_ivld_oreg;
  output din_rsci_biwt;
  output din_rsci_bdwt;
  input din_rsci_bcwt;
  output din_rsci_irdy_run_sct;
  output din_rsci_biwt_pff;
  input din_rsci_oswt_pff;
  input din_rsci_bcwt_pff;
  input din_rsci_ivld_oreg_pff;


  // Interconnect Declarations
  wire din_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign din_rsci_bdwt = din_rsci_oswt & run_wen;
  assign din_rsci_ogwt = din_rsci_oswt & (~ din_rsci_bcwt);
  assign din_rsci_irdy_run_sct = din_rsci_ogwt;
  assign din_rsci_biwt = din_rsci_ogwt & din_rsci_ivld_oreg;
  assign din_rsci_biwt_pff = din_rsci_oswt_pff & (~ din_rsci_bcwt_pff) & din_rsci_ivld_oreg_pff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp
    (
  clk, rst, core_wen, core_wten, FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_oswt,
      FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_addr_core,
      FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out_mxwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_oswt;
  input [1:0] FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_addr_core;
  output [11:0] FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out_mxwt;


  // Interconnect Declarations
  wire FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_biwt;
  wire FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_bdwt;
  wire [11:0] FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out;


  // Interconnect Declarations for Component Instantiations 
  branch_0_layer_0_qnn_conv2d_105273232mgc_rom_sync_40_4_12_1_1  FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp
      (
      .addr(FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_addr_core),
      .data_out(FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out),
      .clk(clk)
    );
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_mgc_rom_sync_40_4_12000000
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_mgc_rom_sync_40_4_12000002
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_oswt(FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_oswt),
      .FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_biwt(FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_biwt),
      .FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_bdwt(FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_bdwt)
    );
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_mgc_rom_sync_40_4_12000001
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_mgc_rom_sync_40_4_12000003
      (
      .clk(clk),
      .rst(rst),
      .FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out_mxwt(FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out_mxwt),
      .FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_biwt(FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_biwt),
      .FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_bdwt(FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_bdwt),
      .FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out(FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci
    (
  clk, rst, AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_dat, AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_vld,
      AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_rdy, core_wen, AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_oswt,
      AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp, AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy,
      AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg, AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat
);
  input clk;
  input rst;
  output [31:0] AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_dat;
  output AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_vld;
  input AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_rdy;
  input core_wen;
  input AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_oswt;
  output AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp;
  output AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy;
  input AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg;
  input [31:0] AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat;


  // Interconnect Declarations
  wire AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_biwt;
  wire AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bdwt;
  wire AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bcwt;
  wire AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_ivld_core_sct;
  wire AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  wire [31:0] nl_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat;
  assign nl_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat = {(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat[31:8])
      , 1'b1 , (AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat[6:2]) , 1'b0 , (AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat[0])};
  ccs_out_buf_wait_v5 #(.rscid(32'sd39),
  .width(32'sd32),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1),
  .rst_val(32'sd0)) AC_CH_ID99580272_func0_fc_bias_shape_4_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .irdy(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy),
      .ivld(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_ivld_core_sct),
      .idat(nl_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat[31:0]),
      .rdy(AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_rdy),
      .vld(AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_vld),
      .dat(AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_dat),
      .is_idle(AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_is_idle)
    );
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_AC_CH_ID99580272_func0_fc_bias_shape_4_wait_ctrl
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_AC_CH_ID99580272_func0_fc_bias_shape_4_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_oswt(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_oswt),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_biwt(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_biwt),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bdwt(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bdwt),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bcwt(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bcwt),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_ivld_core_sct(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_ivld_core_sct)
    );
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_AC_CH_ID99580272_func0_fc_bias_shape_4_wait_dp
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_AC_CH_ID99580272_func0_fc_bias_shape_4_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_oswt(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_oswt),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_biwt(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_biwt),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bdwt(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bdwt),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bcwt(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp
    (
  clk, rst, core_wen, core_wten, W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_oswt,
      W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_addr_core, W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_oswt;
  input [1:0] W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_addr_core;
  output [252:0] W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt;


  // Interconnect Declarations
  wire W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_biwt;
  wire W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_bdwt;
  wire [287:0] W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out;
  wire [252:0] W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst;


  // Interconnect Declarations for Component Instantiations 
  branch_0_layer_0_qnn_conv2d_105273232mgc_rom_sync_38_4_288_1_1  W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp
      (
      .addr(W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_addr_core),
      .data_out(W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out),
      .clk(clk)
    );
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_mgc_rom_sync_38_4_288_1_1_wait_ctrl
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_mgc_rom_sync_38_4_288_1_1_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_oswt(W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_oswt),
      .W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_biwt(W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_biwt),
      .W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_bdwt(W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_bdwt)
    );
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_mgc_rom_sync_38_4_288_1_1_wait_dp
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_mgc_rom_sync_38_4_288_1_1_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt(W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst),
      .W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_biwt(W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_biwt),
      .W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_bdwt(W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_bdwt),
      .W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out(W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out)
    );
  assign W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt = W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt_pconst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci
    (
  clk, rst, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_dat, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_vld,
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_rdy, core_wen, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_oswt,
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy,
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat
);
  input clk;
  input rst;
  output [287:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_dat;
  output AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_vld;
  input AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_rdy;
  input core_wen;
  input AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_oswt;
  output AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp;
  output AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy;
  input AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg;
  input [287:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat;


  // Interconnect Declarations
  wire AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_biwt;
  wire AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bdwt;
  wire AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bcwt;
  wire AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_ivld_core_sct;
  wire AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  wire [287:0] nl_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat;
  assign nl_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat = {(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[287:266])
      , 1'b1 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[264:260])
      , 1'b0 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[258:257])
      , 1'b1 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[255:249])
      , 1'b0 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[247:244])
      , 1'b0 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[242:233])
      , 1'b0 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[231:229])
      , 4'b1101 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[224])
      , 1'b1 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[222:214])
      , 1'b0 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[212:209])
      , 1'b1 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[207:203])
      , 1'b1 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[201:187])
      , 1'b0 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[185:166])
      , 1'b1 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[164:158])
      , 1'b0 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[156]) ,
      3'b110 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[152]) ,
      1'b0 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[150:143])
      , 1'b0 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[141:129])
      , 1'b1 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[127]) ,
      1'b0 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[125:113])
      , 1'b0 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[111:109])
      , 1'b0 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[107:106])
      , 1'b1 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[104:86])
      , 1'b0 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[84:72])
      , 1'b0 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[70:69])
      , 2'b10 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[66:55])
      , 1'b0 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[53:44])
      , 1'b1 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[42:20])
      , 1'b0 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[18:10])
      , 1'b0 , (AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[8:0])};
  ccs_out_buf_wait_v5 #(.rscid(32'sd37),
  .width(32'sd288),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1),
  .rst_val(32'sd0)) AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .irdy(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy),
      .ivld(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_ivld_core_sct),
      .idat(nl_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat[287:0]),
      .rdy(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_rdy),
      .vld(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_vld),
      .dat(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_dat),
      .is_idle(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_is_idle)
    );
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_AC_CH_ID104977024_func0_fc_weight_shape_4000000
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_AC_CH_ID104977024_func0_fc_weight_shape_4000002
      (
      .core_wen(core_wen),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_oswt(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_oswt),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_biwt(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_biwt),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bdwt(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bdwt),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bcwt(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bcwt),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_ivld_core_sct(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_ivld_core_sct)
    );
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_AC_CH_ID104977024_func0_fc_weight_shape_4000001
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_AC_CH_ID104977024_func0_fc_weight_shape_4000003
      (
      .clk(clk),
      .rst(rst),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_oswt(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_oswt),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_biwt(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_biwt),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bdwt(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bdwt),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bcwt(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_dout_rsci
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_dout_rsci
    (
  clk, rst, dout_rsc_dat, dout_rsc_vld, dout_rsc_rdy, dout_rsci_oswt, dout_rsci_wen_comp,
      dout_rsci_idat, dout_rsci_oswt_pff
);
  input clk;
  input rst;
  output [107:0] dout_rsc_dat;
  output dout_rsc_vld;
  input dout_rsc_rdy;
  input dout_rsci_oswt;
  output dout_rsci_wen_comp;
  input [107:0] dout_rsci_idat;
  input dout_rsci_oswt_pff;


  // Interconnect Declarations
  wire dout_rsci_biwt;
  wire dout_rsc_is_idle;
  wire dout_rsci_irdy;


  // Interconnect Declarations for Component Instantiations 
  wire [107:0] nl_dout_rsci_idat;
  assign nl_dout_rsci_idat = {1'b0 , (dout_rsci_idat[106:99]) , 1'b0 , (dout_rsci_idat[97:90])
      , 1'b0 , (dout_rsci_idat[88:81]) , 1'b0 , (dout_rsci_idat[79:72]) , 1'b0 ,
      (dout_rsci_idat[70:63]) , 1'b0 , (dout_rsci_idat[61:54]) , 1'b0 , (dout_rsci_idat[52:45])
      , 1'b0 , (dout_rsci_idat[43:36]) , 1'b0 , (dout_rsci_idat[34:27]) , 1'b0 ,
      (dout_rsci_idat[25:18]) , 1'b0 , (dout_rsci_idat[16:9]) , 1'b0 , (dout_rsci_idat[7:0])};
  ccs_out_buf_wait_v5 #(.rscid(32'sd2),
  .width(32'sd108),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1),
  .rst_val(32'sd0)) dout_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .irdy(dout_rsci_irdy),
      .ivld(dout_rsci_oswt),
      .idat(nl_dout_rsci_idat[107:0]),
      .rdy(dout_rsc_rdy),
      .vld(dout_rsc_vld),
      .dat(dout_rsc_dat),
      .is_idle(dout_rsc_is_idle)
    );
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_dout_rsci_dout_wait_ctrl
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_dout_rsci_dout_wait_ctrl_inst
      (
      .dout_rsci_iswt0(dout_rsci_oswt_pff),
      .dout_rsci_irdy_oreg(dout_rsci_irdy),
      .dout_rsci_biwt(dout_rsci_biwt)
    );
  assign dout_rsci_wen_comp = (~ dout_rsci_oswt_pff) | dout_rsci_biwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_din_rsci
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_din_rsci
    (
  clk, rst, din_rsc_dat, din_rsc_vld, din_rsc_rdy, din_rsci_oswt, din_rsci_wen_comp,
      din_rsci_idat_mxwt, din_rsci_oswt_pff
);
  input clk;
  input rst;
  input [31:0] din_rsc_dat;
  input din_rsc_vld;
  output din_rsc_rdy;
  input din_rsci_oswt;
  output din_rsci_wen_comp;
  output [31:0] din_rsci_idat_mxwt;
  input din_rsci_oswt_pff;


  // Interconnect Declarations
  wire din_rsci_biwt;
  wire [31:0] din_rsci_idat;
  wire din_rsc_is_idle;
  wire din_rsci_ivld;


  // Interconnect Declarations for Component Instantiations 
  ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd1),
  .width(32'sd32),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1)) din_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .rdy(din_rsc_rdy),
      .vld(din_rsc_vld),
      .dat(din_rsc_dat),
      .irdy(din_rsci_oswt),
      .ivld(din_rsci_ivld),
      .idat(din_rsci_idat),
      .is_idle(din_rsc_is_idle)
    );
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_din_rsci_din_wait_ctrl
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_din_rsci_din_wait_ctrl_inst
      (
      .din_rsci_iswt0(din_rsci_oswt_pff),
      .din_rsci_ivld_oreg(din_rsci_ivld),
      .din_rsci_biwt(din_rsci_biwt)
    );
  assign din_rsci_idat_mxwt = din_rsci_idat;
  assign din_rsci_wen_comp = (~ din_rsci_oswt_pff) | din_rsci_biwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_dout_rsci
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_dout_rsci
    (
  clk, rst, dout_rsc_dat, dout_rsc_vld, dout_rsc_rdy, run_wen, dout_rsci_oswt, dout_rsci_wen_comp,
      dout_rsci_irdy, dout_rsci_irdy_oreg, dout_rsci_idat, dout_rsci_oswt_pff, dout_rsci_irdy_oreg_pff
);
  input clk;
  input rst;
  output [22:0] dout_rsc_dat;
  output dout_rsc_vld;
  input dout_rsc_rdy;
  input run_wen;
  input dout_rsci_oswt;
  output dout_rsci_wen_comp;
  output dout_rsci_irdy;
  input dout_rsci_irdy_oreg;
  input [22:0] dout_rsci_idat;
  input dout_rsci_oswt_pff;
  input dout_rsci_irdy_oreg_pff;


  // Interconnect Declarations
  wire dout_rsci_biwt;
  wire dout_rsci_bdwt;
  wire dout_rsci_bcwt;
  wire dout_rsci_ivld_run_sct;
  wire dout_rsc_is_idle;
  wire dout_rsci_wen_comp_reg;
  wire dout_rsci_biwt_iff;
  wire dout_rsci_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  ccs_out_buf_wait_v5 #(.rscid(32'sd10),
  .width(32'sd23),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1),
  .rst_val(32'sd0)) dout_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .irdy(dout_rsci_irdy),
      .ivld(dout_rsci_ivld_run_sct),
      .idat(dout_rsci_idat),
      .rdy(dout_rsc_rdy),
      .vld(dout_rsc_vld),
      .dat(dout_rsc_dat),
      .is_idle(dout_rsc_is_idle)
    );
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_dout_rsci_dout_wait_ctrl
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_dout_rsci_dout_wait_ctrl_inst
      (
      .run_wen(run_wen),
      .dout_rsci_oswt(dout_rsci_oswt),
      .dout_rsci_irdy_oreg(dout_rsci_irdy_oreg),
      .dout_rsci_biwt(dout_rsci_biwt),
      .dout_rsci_bdwt(dout_rsci_bdwt),
      .dout_rsci_bcwt(dout_rsci_bcwt),
      .dout_rsci_ivld_run_sct(dout_rsci_ivld_run_sct),
      .dout_rsci_biwt_pff(dout_rsci_biwt_iff),
      .dout_rsci_oswt_pff(dout_rsci_oswt_pff),
      .dout_rsci_bcwt_pff(dout_rsci_bcwt_iff),
      .dout_rsci_irdy_oreg_pff(dout_rsci_irdy_oreg_pff)
    );
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_dout_rsci_dout_wait_dp
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_dout_rsci_dout_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_rsci_oswt(dout_rsci_oswt_pff),
      .dout_rsci_wen_comp(dout_rsci_wen_comp_reg),
      .dout_rsci_biwt(dout_rsci_biwt),
      .dout_rsci_bdwt(dout_rsci_bdwt),
      .dout_rsci_bcwt(dout_rsci_bcwt),
      .dout_rsci_biwt_pff(dout_rsci_biwt_iff),
      .dout_rsci_bcwt_pff(dout_rsci_bcwt_iff)
    );
  assign dout_rsci_wen_comp = dout_rsci_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_kernelIn_rsci
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_kernelIn_rsci
    (
  clk, rst, kernelIn_rsc_dat, kernelIn_rsc_vld, kernelIn_rsc_rdy, run_wen, kernelIn_rsci_oswt,
      kernelIn_rsci_wen_comp, kernelIn_rsci_ivld, kernelIn_rsci_ivld_oreg, kernelIn_rsci_idat_mxwt,
      kernelIn_rsci_oswt_pff, kernelIn_rsci_ivld_oreg_pff
);
  input clk;
  input rst;
  input [287:0] kernelIn_rsc_dat;
  input kernelIn_rsc_vld;
  output kernelIn_rsc_rdy;
  input run_wen;
  input kernelIn_rsci_oswt;
  output kernelIn_rsci_wen_comp;
  output kernelIn_rsci_ivld;
  input kernelIn_rsci_ivld_oreg;
  output [287:0] kernelIn_rsci_idat_mxwt;
  input kernelIn_rsci_oswt_pff;
  input kernelIn_rsci_ivld_oreg_pff;


  // Interconnect Declarations
  wire kernelIn_rsci_biwt;
  wire kernelIn_rsci_bdwt;
  wire kernelIn_rsci_bcwt;
  wire kernelIn_rsci_irdy_run_sct;
  wire [287:0] kernelIn_rsci_idat;
  wire kernelIn_rsc_is_idle;
  wire kernelIn_rsci_wen_comp_reg;
  wire kernelIn_rsci_biwt_iff;
  wire kernelIn_rsci_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd9),
  .width(32'sd288),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1)) kernelIn_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .rdy(kernelIn_rsc_rdy),
      .vld(kernelIn_rsc_vld),
      .dat(kernelIn_rsc_dat),
      .irdy(kernelIn_rsci_irdy_run_sct),
      .ivld(kernelIn_rsci_ivld),
      .idat(kernelIn_rsci_idat),
      .is_idle(kernelIn_rsc_is_idle)
    );
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_kernelIn_rsci_kernelIn_wait_ctrl
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_kernelIn_rsci_kernelIn_wait_ctrl_inst
      (
      .run_wen(run_wen),
      .kernelIn_rsci_oswt(kernelIn_rsci_oswt),
      .kernelIn_rsci_ivld_oreg(kernelIn_rsci_ivld_oreg),
      .kernelIn_rsci_biwt(kernelIn_rsci_biwt),
      .kernelIn_rsci_bdwt(kernelIn_rsci_bdwt),
      .kernelIn_rsci_bcwt(kernelIn_rsci_bcwt),
      .kernelIn_rsci_irdy_run_sct(kernelIn_rsci_irdy_run_sct),
      .kernelIn_rsci_biwt_pff(kernelIn_rsci_biwt_iff),
      .kernelIn_rsci_oswt_pff(kernelIn_rsci_oswt_pff),
      .kernelIn_rsci_bcwt_pff(kernelIn_rsci_bcwt_iff),
      .kernelIn_rsci_ivld_oreg_pff(kernelIn_rsci_ivld_oreg_pff)
    );
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_kernelIn_rsci_kernelIn_wait_dp
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_kernelIn_rsci_kernelIn_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .kernelIn_rsci_oswt(kernelIn_rsci_oswt_pff),
      .kernelIn_rsci_wen_comp(kernelIn_rsci_wen_comp_reg),
      .kernelIn_rsci_idat_mxwt(kernelIn_rsci_idat_mxwt),
      .kernelIn_rsci_biwt(kernelIn_rsci_biwt),
      .kernelIn_rsci_bdwt(kernelIn_rsci_bdwt),
      .kernelIn_rsci_bcwt(kernelIn_rsci_bcwt),
      .kernelIn_rsci_idat(kernelIn_rsci_idat),
      .kernelIn_rsci_biwt_pff(kernelIn_rsci_biwt_iff),
      .kernelIn_rsci_bcwt_pff(kernelIn_rsci_bcwt_iff)
    );
  assign kernelIn_rsci_wen_comp = kernelIn_rsci_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_din_rsci
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_din_rsci
    (
  clk, rst, din_rsc_dat, din_rsc_vld, din_rsc_rdy, din_rsci_oswt, din_rsci_wen_comp,
      din_rsci_idat_mxwt, din_rsci_oswt_pff
);
  input clk;
  input rst;
  input [107:0] din_rsc_dat;
  input din_rsc_vld;
  output din_rsc_rdy;
  input din_rsci_oswt;
  output din_rsci_wen_comp;
  output [107:0] din_rsci_idat_mxwt;
  input din_rsci_oswt_pff;


  // Interconnect Declarations
  wire din_rsci_biwt;
  wire [107:0] din_rsci_idat;
  wire din_rsc_is_idle;
  wire din_rsci_ivld;


  // Interconnect Declarations for Component Instantiations 
  ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd8),
  .width(32'sd108),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1)) din_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .rdy(din_rsc_rdy),
      .vld(din_rsc_vld),
      .dat(din_rsc_dat),
      .irdy(din_rsci_oswt),
      .ivld(din_rsci_ivld),
      .idat(din_rsci_idat),
      .is_idle(din_rsc_is_idle)
    );
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_din_rsci_din_wait_ctrl
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_din_rsci_din_wait_ctrl_inst
      (
      .din_rsci_iswt0(din_rsci_oswt_pff),
      .din_rsci_ivld_oreg(din_rsci_ivld),
      .din_rsci_biwt(din_rsci_biwt)
    );
  assign din_rsci_idat_mxwt = din_rsci_idat;
  assign din_rsci_wen_comp = (~ din_rsci_oswt_pff) | din_rsci_biwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_dout_rsci
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_dout_rsci
    (
  clk, rst, dout_rsc_dat, dout_rsc_vld, dout_rsc_rdy, run_wen, dout_rsci_oswt, dout_rsci_wen_comp,
      dout_rsci_irdy, dout_rsci_irdy_oreg, dout_rsci_idat, dout_rsci_oswt_pff, dout_rsci_irdy_oreg_pff
);
  input clk;
  input rst;
  output [25:0] dout_rsc_dat;
  output dout_rsc_vld;
  input dout_rsc_rdy;
  input run_wen;
  input dout_rsci_oswt;
  output dout_rsci_wen_comp;
  output dout_rsci_irdy;
  input dout_rsci_irdy_oreg;
  input [25:0] dout_rsci_idat;
  input dout_rsci_oswt_pff;
  input dout_rsci_irdy_oreg_pff;


  // Interconnect Declarations
  wire dout_rsci_biwt;
  wire dout_rsci_bdwt;
  wire dout_rsci_bcwt;
  wire dout_rsci_ivld_run_sct;
  wire dout_rsc_is_idle;
  wire dout_rsci_wen_comp_reg;
  wire dout_rsci_biwt_iff;
  wire dout_rsci_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  ccs_out_buf_wait_v5 #(.rscid(32'sd23),
  .width(32'sd26),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1),
  .rst_val(32'sd0)) dout_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .irdy(dout_rsci_irdy),
      .ivld(dout_rsci_ivld_run_sct),
      .idat(dout_rsci_idat),
      .rdy(dout_rsc_rdy),
      .vld(dout_rsc_vld),
      .dat(dout_rsc_dat),
      .is_idle(dout_rsc_is_idle)
    );
  branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_dout_rsci_dout_wait_ctrl
      branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_dout_rsci_dout_wait_ctrl_inst
      (
      .run_wen(run_wen),
      .dout_rsci_oswt(dout_rsci_oswt),
      .dout_rsci_irdy_oreg(dout_rsci_irdy_oreg),
      .dout_rsci_biwt(dout_rsci_biwt),
      .dout_rsci_bdwt(dout_rsci_bdwt),
      .dout_rsci_bcwt(dout_rsci_bcwt),
      .dout_rsci_ivld_run_sct(dout_rsci_ivld_run_sct),
      .dout_rsci_biwt_pff(dout_rsci_biwt_iff),
      .dout_rsci_oswt_pff(dout_rsci_oswt_pff),
      .dout_rsci_bcwt_pff(dout_rsci_bcwt_iff),
      .dout_rsci_irdy_oreg_pff(dout_rsci_irdy_oreg_pff)
    );
  branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_dout_rsci_dout_wait_dp
      branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_dout_rsci_dout_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_rsci_oswt(dout_rsci_oswt_pff),
      .dout_rsci_wen_comp(dout_rsci_wen_comp_reg),
      .dout_rsci_biwt(dout_rsci_biwt),
      .dout_rsci_bdwt(dout_rsci_bdwt),
      .dout_rsci_bcwt(dout_rsci_bcwt),
      .dout_rsci_biwt_pff(dout_rsci_biwt_iff),
      .dout_rsci_bcwt_pff(dout_rsci_bcwt_iff)
    );
  assign dout_rsci_wen_comp = dout_rsci_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_bias_rsci
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_bias_rsci
    (
  clk, rst, bias_rsc_dat, bias_rsc_vld, bias_rsc_rdy, run_wen, bias_rsci_oswt, bias_rsci_wen_comp,
      bias_rsci_ivld, bias_rsci_ivld_oreg, bias_rsci_idat_mxwt, bias_rsci_oswt_pff,
      bias_rsci_ivld_oreg_pff
);
  input clk;
  input rst;
  input [31:0] bias_rsc_dat;
  input bias_rsc_vld;
  output bias_rsc_rdy;
  input run_wen;
  input bias_rsci_oswt;
  output bias_rsci_wen_comp;
  output bias_rsci_ivld;
  input bias_rsci_ivld_oreg;
  output [25:0] bias_rsci_idat_mxwt;
  input bias_rsci_oswt_pff;
  input bias_rsci_ivld_oreg_pff;


  // Interconnect Declarations
  wire bias_rsci_biwt;
  wire bias_rsci_bdwt;
  wire bias_rsci_bcwt;
  wire bias_rsci_irdy_run_sct;
  wire [31:0] bias_rsci_idat;
  wire bias_rsc_is_idle;
  wire [25:0] bias_rsci_idat_mxwt_pconst;
  wire bias_rsci_wen_comp_reg;
  wire bias_rsci_biwt_iff;
  wire bias_rsci_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd22),
  .width(32'sd32),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1)) bias_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .rdy(bias_rsc_rdy),
      .vld(bias_rsc_vld),
      .dat(bias_rsc_dat),
      .irdy(bias_rsci_irdy_run_sct),
      .ivld(bias_rsci_ivld),
      .idat(bias_rsci_idat),
      .is_idle(bias_rsc_is_idle)
    );
  branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_bias_rsci_bias_wait_ctrl
      branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_bias_rsci_bias_wait_ctrl_inst
      (
      .run_wen(run_wen),
      .bias_rsci_oswt(bias_rsci_oswt),
      .bias_rsci_ivld_oreg(bias_rsci_ivld_oreg),
      .bias_rsci_biwt(bias_rsci_biwt),
      .bias_rsci_bdwt(bias_rsci_bdwt),
      .bias_rsci_bcwt(bias_rsci_bcwt),
      .bias_rsci_irdy_run_sct(bias_rsci_irdy_run_sct),
      .bias_rsci_biwt_pff(bias_rsci_biwt_iff),
      .bias_rsci_oswt_pff(bias_rsci_oswt_pff),
      .bias_rsci_bcwt_pff(bias_rsci_bcwt_iff),
      .bias_rsci_ivld_oreg_pff(bias_rsci_ivld_oreg_pff)
    );
  branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_bias_rsci_bias_wait_dp
      branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_bias_rsci_bias_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .bias_rsci_oswt(bias_rsci_oswt_pff),
      .bias_rsci_wen_comp(bias_rsci_wen_comp_reg),
      .bias_rsci_idat_mxwt(bias_rsci_idat_mxwt_pconst),
      .bias_rsci_biwt(bias_rsci_biwt),
      .bias_rsci_bdwt(bias_rsci_bdwt),
      .bias_rsci_bcwt(bias_rsci_bcwt),
      .bias_rsci_idat(bias_rsci_idat),
      .bias_rsci_biwt_pff(bias_rsci_biwt_iff),
      .bias_rsci_bcwt_pff(bias_rsci_bcwt_iff)
    );
  assign bias_rsci_idat_mxwt = bias_rsci_idat_mxwt_pconst;
  assign bias_rsci_wen_comp = bias_rsci_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_din_rsci
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_din_rsci
    (
  clk, rst, din_rsc_dat, din_rsc_vld, din_rsc_rdy, run_wen, din_rsci_oswt, din_rsci_wen_comp,
      din_rsci_ivld, din_rsci_ivld_oreg, din_rsci_idat_mxwt, din_rsci_oswt_pff, din_rsci_ivld_oreg_pff
);
  input clk;
  input rst;
  input [22:0] din_rsc_dat;
  input din_rsc_vld;
  output din_rsc_rdy;
  input run_wen;
  input din_rsci_oswt;
  output din_rsci_wen_comp;
  output din_rsci_ivld;
  input din_rsci_ivld_oreg;
  output [22:0] din_rsci_idat_mxwt;
  input din_rsci_oswt_pff;
  input din_rsci_ivld_oreg_pff;


  // Interconnect Declarations
  wire din_rsci_biwt;
  wire din_rsci_bdwt;
  wire din_rsci_bcwt;
  wire din_rsci_irdy_run_sct;
  wire [22:0] din_rsci_idat;
  wire din_rsc_is_idle;
  wire din_rsci_wen_comp_reg;
  wire din_rsci_biwt_iff;
  wire din_rsci_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd21),
  .width(32'sd23),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1)) din_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .rdy(din_rsc_rdy),
      .vld(din_rsc_vld),
      .dat(din_rsc_dat),
      .irdy(din_rsci_irdy_run_sct),
      .ivld(din_rsci_ivld),
      .idat(din_rsci_idat),
      .is_idle(din_rsc_is_idle)
    );
  branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_din_rsci_din_wait_ctrl
      branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_din_rsci_din_wait_ctrl_inst
      (
      .run_wen(run_wen),
      .din_rsci_oswt(din_rsci_oswt),
      .din_rsci_ivld_oreg(din_rsci_ivld_oreg),
      .din_rsci_biwt(din_rsci_biwt),
      .din_rsci_bdwt(din_rsci_bdwt),
      .din_rsci_bcwt(din_rsci_bcwt),
      .din_rsci_irdy_run_sct(din_rsci_irdy_run_sct),
      .din_rsci_biwt_pff(din_rsci_biwt_iff),
      .din_rsci_oswt_pff(din_rsci_oswt_pff),
      .din_rsci_bcwt_pff(din_rsci_bcwt_iff),
      .din_rsci_ivld_oreg_pff(din_rsci_ivld_oreg_pff)
    );
  branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_din_rsci_din_wait_dp
      branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_din_rsci_din_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsci_oswt(din_rsci_oswt_pff),
      .din_rsci_wen_comp(din_rsci_wen_comp_reg),
      .din_rsci_idat_mxwt(din_rsci_idat_mxwt),
      .din_rsci_biwt(din_rsci_biwt),
      .din_rsci_bdwt(din_rsci_bdwt),
      .din_rsci_bcwt(din_rsci_bcwt),
      .din_rsci_idat(din_rsci_idat),
      .din_rsci_biwt_pff(din_rsci_biwt_iff),
      .din_rsci_bcwt_pff(din_rsci_bcwt_iff)
    );
  assign din_rsci_wen_comp = din_rsci_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_dout_rsci
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_dout_rsci
    (
  clk, rst, dout_rsc_dat, dout_rsc_vld, dout_rsc_rdy, run_wen, dout_rsci_oswt, dout_rsci_wen_comp,
      dout_rsci_irdy, dout_rsci_irdy_oreg, dout_rsci_idat, dout_rsci_oswt_pff, dout_rsci_irdy_oreg_pff
);
  input clk;
  input rst;
  output [7:0] dout_rsc_dat;
  output dout_rsc_vld;
  input dout_rsc_rdy;
  input run_wen;
  input dout_rsci_oswt;
  output dout_rsci_wen_comp;
  output dout_rsci_irdy;
  input dout_rsci_irdy_oreg;
  input [7:0] dout_rsci_idat;
  input dout_rsci_oswt_pff;
  input dout_rsci_irdy_oreg_pff;


  // Interconnect Declarations
  wire dout_rsci_biwt;
  wire dout_rsci_bdwt;
  wire dout_rsci_bcwt;
  wire dout_rsci_ivld_run_sct;
  wire dout_rsc_is_idle;
  wire dout_rsci_wen_comp_reg;
  wire dout_rsci_biwt_iff;
  wire dout_rsci_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  ccs_out_buf_wait_v5 #(.rscid(32'sd25),
  .width(32'sd8),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1),
  .rst_val(32'sd0)) dout_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .irdy(dout_rsci_irdy),
      .ivld(dout_rsci_ivld_run_sct),
      .idat(dout_rsci_idat),
      .rdy(dout_rsc_rdy),
      .vld(dout_rsc_vld),
      .dat(dout_rsc_dat),
      .is_idle(dout_rsc_is_idle)
    );
  branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_dout_rsci_dout_wait_ctrl
      branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_dout_rsci_dout_wait_ctrl_inst
      (
      .run_wen(run_wen),
      .dout_rsci_oswt(dout_rsci_oswt),
      .dout_rsci_irdy_oreg(dout_rsci_irdy_oreg),
      .dout_rsci_biwt(dout_rsci_biwt),
      .dout_rsci_bdwt(dout_rsci_bdwt),
      .dout_rsci_bcwt(dout_rsci_bcwt),
      .dout_rsci_ivld_run_sct(dout_rsci_ivld_run_sct),
      .dout_rsci_biwt_pff(dout_rsci_biwt_iff),
      .dout_rsci_oswt_pff(dout_rsci_oswt_pff),
      .dout_rsci_bcwt_pff(dout_rsci_bcwt_iff),
      .dout_rsci_irdy_oreg_pff(dout_rsci_irdy_oreg_pff)
    );
  branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_dout_rsci_dout_wait_dp
      branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_dout_rsci_dout_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_rsci_oswt(dout_rsci_oswt_pff),
      .dout_rsci_wen_comp(dout_rsci_wen_comp_reg),
      .dout_rsci_biwt(dout_rsci_biwt),
      .dout_rsci_bdwt(dout_rsci_bdwt),
      .dout_rsci_bcwt(dout_rsci_bcwt),
      .dout_rsci_biwt_pff(dout_rsci_biwt_iff),
      .dout_rsci_bcwt_pff(dout_rsci_bcwt_iff)
    );
  assign dout_rsci_wen_comp = dout_rsci_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_din_rsci
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_din_rsci
    (
  clk, rst, din_rsc_dat, din_rsc_vld, din_rsc_rdy, run_wen, din_rsci_oswt, din_rsci_wen_comp,
      din_rsci_ivld, din_rsci_ivld_oreg, din_rsci_idat_mxwt, din_rsci_oswt_pff, din_rsci_ivld_oreg_pff
);
  input clk;
  input rst;
  input [25:0] din_rsc_dat;
  input din_rsc_vld;
  output din_rsc_rdy;
  input run_wen;
  input din_rsci_oswt;
  output din_rsci_wen_comp;
  output din_rsci_ivld;
  input din_rsci_ivld_oreg;
  output [25:0] din_rsci_idat_mxwt;
  input din_rsci_oswt_pff;
  input din_rsci_ivld_oreg_pff;


  // Interconnect Declarations
  wire din_rsci_biwt;
  wire din_rsci_bdwt;
  wire din_rsci_bcwt;
  wire din_rsci_irdy_run_sct;
  wire [25:0] din_rsci_idat;
  wire din_rsc_is_idle;
  wire din_rsci_wen_comp_reg;
  wire din_rsci_biwt_iff;
  wire din_rsci_bcwt_iff;


  // Interconnect Declarations for Component Instantiations 
  ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd24),
  .width(32'sd26),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1)) din_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .rdy(din_rsc_rdy),
      .vld(din_rsc_vld),
      .dat(din_rsc_dat),
      .irdy(din_rsci_irdy_run_sct),
      .ivld(din_rsci_ivld),
      .idat(din_rsci_idat),
      .is_idle(din_rsc_is_idle)
    );
  branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_din_rsci_din_wait_ctrl
      branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_din_rsci_din_wait_ctrl_inst
      (
      .run_wen(run_wen),
      .din_rsci_oswt(din_rsci_oswt),
      .din_rsci_ivld_oreg(din_rsci_ivld_oreg),
      .din_rsci_biwt(din_rsci_biwt),
      .din_rsci_bdwt(din_rsci_bdwt),
      .din_rsci_bcwt(din_rsci_bcwt),
      .din_rsci_irdy_run_sct(din_rsci_irdy_run_sct),
      .din_rsci_biwt_pff(din_rsci_biwt_iff),
      .din_rsci_oswt_pff(din_rsci_oswt_pff),
      .din_rsci_bcwt_pff(din_rsci_bcwt_iff),
      .din_rsci_ivld_oreg_pff(din_rsci_ivld_oreg_pff)
    );
  branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_din_rsci_din_wait_dp
      branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_din_rsci_din_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsci_oswt(din_rsci_oswt_pff),
      .din_rsci_wen_comp(din_rsci_wen_comp_reg),
      .din_rsci_idat_mxwt(din_rsci_idat_mxwt),
      .din_rsci_biwt(din_rsci_biwt),
      .din_rsci_bdwt(din_rsci_bdwt),
      .din_rsci_bcwt(din_rsci_bcwt),
      .din_rsci_idat(din_rsci_idat),
      .din_rsci_biwt_pff(din_rsci_biwt_iff),
      .din_rsci_bcwt_pff(din_rsci_bcwt_iff)
    );
  assign din_rsci_wen_comp = din_rsci_wen_comp_reg;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core
    (
  clk, rst, AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_dat, AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_vld,
      AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_rdy
);
  input clk;
  input rst;
  output [31:0] AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_dat;
  output AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_vld;
  input AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_rdy;


  // Interconnect Declarations
  wire core_wten;
  wire AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp;
  wire AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy;
  wire AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg;
  wire [11:0] FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out_mxwt;
  reg [4:0] AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat_6_2;
  reg AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat_0;
  reg [5:0] AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat_13_8;
  wire [1:0] fsm_output;
  wire [2:0] FMAP_PSUM_ICHAN_for_acc_1_tmp;
  wire [3:0] nl_FMAP_PSUM_ICHAN_for_acc_1_tmp;
  wire or_dcpl_1;
  reg FMAP_PSUM_HEIGHT_stage_0;
  reg FMAP_PSUM_HEIGHT_stage_0_2;
  wire FMAP_PSUM_ICHAN_for_if_and_cse;
  reg reg_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_oswt_cse;
  wire [1:0] FMAP_PSUM_ICHAN_for_outChan_2_0_lpi_2_dfm_1_0_1;
  reg [4:0] FMAP_PSUM_HEIGHT_r_4_0_sva;
  reg [4:0] FMAP_PSUM_WIDTH_c_4_0_sva;
  reg lfst_exit_FMAP_PSUM_WIDTH_sva;
  reg [1:0] FMAP_PSUM_ICHAN_for_outChan_2_0_lpi_2_1_0;
  wire lfst_exit_FMAP_PSUM_WIDTH_sva_dfm_1;
  wire [4:0] FMAP_PSUM_HEIGHT_r_4_0_sva_2;
  wire [5:0] nl_FMAP_PSUM_HEIGHT_r_4_0_sva_2;
  wire [4:0] FMAP_PSUM_WIDTH_c_4_0_sva_3;
  wire [5:0] nl_FMAP_PSUM_WIDTH_c_4_0_sva_3;
  wire FMAP_PSUM_HEIGHT_acc_itm_2_1;
  wire FMAP_PSUM_WIDTH_acc_itm_2_1;

  wire[4:0] FMAP_PSUM_WIDTH_mux_nl;
  wire[4:0] FMAP_PSUM_WIDTH_c_mux_nl;
  wire[2:0] FMAP_PSUM_HEIGHT_acc_nl;
  wire[3:0] nl_FMAP_PSUM_HEIGHT_acc_nl;
  wire[2:0] FMAP_PSUM_WIDTH_acc_nl;
  wire[3:0] nl_FMAP_PSUM_WIDTH_acc_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [31:0] nl_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_inst_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat;
  assign nl_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_inst_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat
      = signext_32_14({AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat_13_8 , 1'b1
      , AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat_6_2 , 1'b0 , AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat_0});
  wire  nl_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_core_fsm_inst_FMAP_PSUM_HEIGHT_C_0_tr0;
  assign nl_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_core_fsm_inst_FMAP_PSUM_HEIGHT_C_0_tr0
      = ~(FMAP_PSUM_HEIGHT_stage_0 | FMAP_PSUM_HEIGHT_stage_0_2);
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_dat(AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_dat),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_vld(AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_vld),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_rdy(AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_rdy),
      .core_wen(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_oswt(reg_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_oswt_cse),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat(nl_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_inst_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat[31:0])
    );
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_wait_dp
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_irdy_oreg)
    );
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp),
      .core_wten(core_wten),
      .FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_oswt(FMAP_PSUM_HEIGHT_stage_0_2),
      .FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_addr_core(FMAP_PSUM_ICHAN_for_outChan_2_0_lpi_2_dfm_1_0_1),
      .FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out_mxwt(FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out_mxwt)
    );
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_staller
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_staller_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wten(core_wten),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp)
    );
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_core_fsm
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_core_fsm_inst
      (
      .clk(clk),
      .rst(rst),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp(AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp),
      .fsm_output(fsm_output),
      .FMAP_PSUM_HEIGHT_C_0_tr0(nl_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_core_fsm_inst_FMAP_PSUM_HEIGHT_C_0_tr0)
    );
  assign FMAP_PSUM_ICHAN_for_if_and_cse = AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp
      & (~((~ FMAP_PSUM_HEIGHT_stage_0_2) | (fsm_output[0])));
  assign lfst_exit_FMAP_PSUM_WIDTH_sva_dfm_1 = ~(FMAP_PSUM_HEIGHT_acc_itm_2_1 & (~
      FMAP_PSUM_WIDTH_acc_itm_2_1) & (FMAP_PSUM_ICHAN_for_acc_1_tmp[2]));
  assign FMAP_PSUM_ICHAN_for_outChan_2_0_lpi_2_dfm_1_0_1 = MUX_v_2_2_2(2'b00, FMAP_PSUM_ICHAN_for_outChan_2_0_lpi_2_1_0,
      lfst_exit_FMAP_PSUM_WIDTH_sva);
  assign nl_FMAP_PSUM_HEIGHT_r_4_0_sva_2 = FMAP_PSUM_HEIGHT_r_4_0_sva + 5'b00001;
  assign FMAP_PSUM_HEIGHT_r_4_0_sva_2 = nl_FMAP_PSUM_HEIGHT_r_4_0_sva_2[4:0];
  assign nl_FMAP_PSUM_WIDTH_c_4_0_sva_3 = FMAP_PSUM_WIDTH_c_4_0_sva + 5'b00001;
  assign FMAP_PSUM_WIDTH_c_4_0_sva_3 = nl_FMAP_PSUM_WIDTH_c_4_0_sva_3[4:0];
  assign nl_FMAP_PSUM_ICHAN_for_acc_1_tmp = 3'b001 + conv_u2s_2_3(FMAP_PSUM_ICHAN_for_outChan_2_0_lpi_2_dfm_1_0_1);
  assign FMAP_PSUM_ICHAN_for_acc_1_tmp = nl_FMAP_PSUM_ICHAN_for_acc_1_tmp[2:0];
  assign or_dcpl_1 = (~ (FMAP_PSUM_ICHAN_for_acc_1_tmp[2])) | FMAP_PSUM_WIDTH_acc_itm_2_1;
  assign nl_FMAP_PSUM_HEIGHT_acc_nl = 3'b001 + ({1'b1 , (FMAP_PSUM_HEIGHT_r_4_0_sva_2[4:3])});
  assign FMAP_PSUM_HEIGHT_acc_nl = nl_FMAP_PSUM_HEIGHT_acc_nl[2:0];
  assign FMAP_PSUM_HEIGHT_acc_itm_2_1 = readslicef_3_1_2(FMAP_PSUM_HEIGHT_acc_nl);
  assign nl_FMAP_PSUM_WIDTH_acc_nl = ({1'b1 , (FMAP_PSUM_WIDTH_c_4_0_sva_3[4:3])})
      + 3'b001;
  assign FMAP_PSUM_WIDTH_acc_nl = nl_FMAP_PSUM_WIDTH_acc_nl[2:0];
  assign FMAP_PSUM_WIDTH_acc_itm_2_1 = readslicef_3_1_2(FMAP_PSUM_WIDTH_acc_nl);
  always @(posedge clk) begin
    if ( FMAP_PSUM_ICHAN_for_if_and_cse ) begin
      AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat_13_8 <= FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out_mxwt[11:6];
      AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat_0 <= FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out_mxwt[0];
      AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_idat_6_2 <= FMAP_PSUM_ICHAN_for_read_rom_ID99580272_func0_fc_bias_shape_4_rom_map_1_cmp_data_out_mxwt[5:1];
    end
  end
  always @(posedge clk) begin
    if ( AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp ) begin
      FMAP_PSUM_HEIGHT_r_4_0_sva <= MUX_v_5_2_2(5'b00000, FMAP_PSUM_WIDTH_mux_nl,
          (fsm_output[1]));
      FMAP_PSUM_WIDTH_c_4_0_sva <= FMAP_PSUM_WIDTH_c_mux_nl & ({{4{lfst_exit_FMAP_PSUM_WIDTH_sva_dfm_1}},
          lfst_exit_FMAP_PSUM_WIDTH_sva_dfm_1}) & (signext_5_1(fsm_output[1]));
      FMAP_PSUM_ICHAN_for_outChan_2_0_lpi_2_1_0 <= FMAP_PSUM_ICHAN_for_acc_1_tmp[1:0];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      FMAP_PSUM_HEIGHT_stage_0 <= 1'b0;
      lfst_exit_FMAP_PSUM_WIDTH_sva <= 1'b0;
      FMAP_PSUM_HEIGHT_stage_0_2 <= 1'b0;
      reg_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_oswt_cse <= 1'b0;
    end
    else if ( AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_wen_comp ) begin
      FMAP_PSUM_HEIGHT_stage_0 <= ~((~(FMAP_PSUM_HEIGHT_stage_0 & (or_dcpl_1 | FMAP_PSUM_HEIGHT_acc_itm_2_1)))
          & (fsm_output[1]));
      lfst_exit_FMAP_PSUM_WIDTH_sva <= lfst_exit_FMAP_PSUM_WIDTH_sva_dfm_1 & (fsm_output[1]);
      FMAP_PSUM_HEIGHT_stage_0_2 <= FMAP_PSUM_HEIGHT_stage_0 & (fsm_output[1]);
      reg_AC_CH_ID99580272_func0_fc_bias_shape_4_rsci_oswt_cse <= FMAP_PSUM_HEIGHT_stage_0_2
          & (fsm_output[1]);
    end
  end
  assign FMAP_PSUM_WIDTH_mux_nl = MUX_v_5_2_2(FMAP_PSUM_HEIGHT_r_4_0_sva_2, FMAP_PSUM_HEIGHT_r_4_0_sva,
      or_dcpl_1);
  assign FMAP_PSUM_WIDTH_c_mux_nl = MUX_v_5_2_2(FMAP_PSUM_WIDTH_c_4_0_sva, FMAP_PSUM_WIDTH_c_4_0_sva_3,
      FMAP_PSUM_ICHAN_for_acc_1_tmp[2]);

  function automatic [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input  sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function automatic [4:0] MUX_v_5_2_2;
    input [4:0] input_0;
    input [4:0] input_1;
    input  sel;
    reg [4:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_5_2_2 = result;
  end
  endfunction


  function automatic [0:0] readslicef_3_1_2;
    input [2:0] vector;
    reg [2:0] tmp;
  begin
    tmp = vector >> 2;
    readslicef_3_1_2 = tmp[0:0];
  end
  endfunction


  function automatic [31:0] signext_32_14;
    input [13:0] vector;
  begin
    signext_32_14= {{18{vector[13]}}, vector};
  end
  endfunction


  function automatic [4:0] signext_5_1;
    input  vector;
  begin
    signext_5_1= {{4{vector}}, vector};
  end
  endfunction


  function automatic [2:0] conv_u2s_2_3 ;
    input [1:0]  vector ;
  begin
    conv_u2s_2_3 =  {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core
    (
  clk, rst, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_dat, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_vld,
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_rdy
);
  input clk;
  input rst;
  output [287:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_dat;
  output AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_vld;
  input AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_rdy;


  // Interconnect Declarations
  wire core_wten;
  wire AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp;
  wire AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy;
  wire AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg;
  wire [252:0] W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt;
  reg [21:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_287_266;
  reg [4:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_264_260;
  reg [1:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_258_257;
  reg [6:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_255_249;
  reg [3:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_247_244;
  reg [9:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_242_233;
  reg [2:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_231_229;
  reg AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_224;
  reg [8:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_222_214;
  reg [3:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_212_209;
  reg [4:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_207_203;
  reg [14:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_201_187;
  reg [19:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_185_166;
  reg [6:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_164_158;
  reg AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_156;
  reg AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_152;
  reg [7:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_150_143;
  reg [12:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_141_129;
  reg AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_127;
  reg [12:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_125_113;
  reg [2:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_111_109;
  reg [1:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_107_106;
  reg [18:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_104_86;
  reg [12:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_84_72;
  reg [1:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_70_69;
  reg [11:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_66_55;
  reg [9:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_53_44;
  reg [22:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_42_20;
  reg [8:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_18_10;
  reg [8:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_8_0;
  wire [1:0] fsm_output;
  wire [2:0] W_WIDTH_for_for_acc_1_tmp;
  wire [3:0] nl_W_WIDTH_for_for_acc_1_tmp;
  wire or_dcpl_1;
  reg W_HEIGHT_stage_0;
  reg W_HEIGHT_stage_0_2;
  wire W_WIDTH_for_for_and_cse;
  reg reg_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_oswt_cse;
  wire [1:0] W_WIDTH_for_for_outChan_2_0_lpi_2_dfm_1_0_1;
  reg [4:0] W_HEIGHT_row_4_0_sva;
  reg [4:0] W_WIDTH_col_4_0_sva;
  reg lfst_exit_W_WIDTH_sva;
  reg [1:0] W_WIDTH_for_for_outChan_2_0_lpi_2_1_0;
  wire lfst_exit_W_WIDTH_sva_dfm_1;
  wire [4:0] W_HEIGHT_row_4_0_sva_2;
  wire [5:0] nl_W_HEIGHT_row_4_0_sva_2;
  wire [4:0] W_WIDTH_col_4_0_sva_3;
  wire [5:0] nl_W_WIDTH_col_4_0_sva_3;
  wire W_HEIGHT_acc_itm_2_1;
  wire W_WIDTH_acc_itm_2_1;

  wire[4:0] W_WIDTH_mux_nl;
  wire[4:0] W_WIDTH_col_mux_nl;
  wire[2:0] W_HEIGHT_acc_nl;
  wire[3:0] nl_W_HEIGHT_acc_nl;
  wire[2:0] W_WIDTH_acc_nl;
  wire[3:0] nl_W_WIDTH_acc_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [287:0] nl_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_inst_AC_CH_ID104977024_func0_fc_weight000000;
  assign nl_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_inst_AC_CH_ID104977024_func0_fc_weight000000
      = {AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_287_266 , 1'b1
      , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_264_260 , 1'b0
      , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_258_257 , 1'b1
      , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_255_249 , 1'b0
      , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_247_244 , 1'b0
      , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_242_233 , 1'b0
      , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_231_229 , 4'b1101
      , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_224 , 1'b1 , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_222_214
      , 1'b0 , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_212_209
      , 1'b1 , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_207_203
      , 1'b1 , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_201_187
      , 1'b0 , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_185_166
      , 1'b1 , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_164_158
      , 1'b0 , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_156 , 3'b110
      , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_152 , 1'b0 , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_150_143
      , 1'b0 , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_141_129
      , 1'b1 , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_127 , 1'b0
      , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_125_113 , 1'b0
      , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_111_109 , 1'b0
      , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_107_106 , 1'b1
      , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_104_86 , 1'b0 ,
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_84_72 , 1'b0 , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_70_69
      , 2'b10 , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_66_55 ,
      1'b0 , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_53_44 , 1'b1
      , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_42_20 , 1'b0 ,
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_18_10 , 1'b0 , AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_8_0};
  wire  nl_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_core_fsm_inst_W_HEIGHT_C_0_tr0;
  assign nl_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_core_fsm_inst_W_HEIGHT_C_0_tr0
      = ~(W_HEIGHT_stage_0 | W_HEIGHT_stage_0_2);
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_dat(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_dat),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_vld(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_vld),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_rdy(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_rdy),
      .core_wen(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_oswt(reg_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_oswt_cse),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat(nl_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_inst_AC_CH_ID104977024_func0_fc_weight000000[287:0])
    );
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_wait_dp
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_irdy_oreg)
    );
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp),
      .core_wten(core_wten),
      .W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_oswt(W_HEIGHT_stage_0_2),
      .W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_addr_core(W_WIDTH_for_for_outChan_2_0_lpi_2_dfm_1_0_1),
      .W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt(W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt)
    );
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_staller
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_staller_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wten(core_wten),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp)
    );
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_core_fsm
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_core_fsm_inst
      (
      .clk(clk),
      .rst(rst),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp),
      .fsm_output(fsm_output),
      .W_HEIGHT_C_0_tr0(nl_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_core_fsm_inst_W_HEIGHT_C_0_tr0)
    );
  assign W_WIDTH_for_for_and_cse = AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp
      & (~((~ W_HEIGHT_stage_0_2) | (fsm_output[0])));
  assign lfst_exit_W_WIDTH_sva_dfm_1 = ~(W_HEIGHT_acc_itm_2_1 & (~ W_WIDTH_acc_itm_2_1)
      & (W_WIDTH_for_for_acc_1_tmp[2]));
  assign W_WIDTH_for_for_outChan_2_0_lpi_2_dfm_1_0_1 = MUX_v_2_2_2(2'b00, W_WIDTH_for_for_outChan_2_0_lpi_2_1_0,
      lfst_exit_W_WIDTH_sva);
  assign nl_W_HEIGHT_row_4_0_sva_2 = W_HEIGHT_row_4_0_sva + 5'b00001;
  assign W_HEIGHT_row_4_0_sva_2 = nl_W_HEIGHT_row_4_0_sva_2[4:0];
  assign nl_W_WIDTH_col_4_0_sva_3 = W_WIDTH_col_4_0_sva + 5'b00001;
  assign W_WIDTH_col_4_0_sva_3 = nl_W_WIDTH_col_4_0_sva_3[4:0];
  assign nl_W_WIDTH_for_for_acc_1_tmp = 3'b001 + conv_u2s_2_3(W_WIDTH_for_for_outChan_2_0_lpi_2_dfm_1_0_1);
  assign W_WIDTH_for_for_acc_1_tmp = nl_W_WIDTH_for_for_acc_1_tmp[2:0];
  assign or_dcpl_1 = (~ (W_WIDTH_for_for_acc_1_tmp[2])) | W_WIDTH_acc_itm_2_1;
  assign nl_W_HEIGHT_acc_nl = 3'b001 + ({1'b1 , (W_HEIGHT_row_4_0_sva_2[4:3])});
  assign W_HEIGHT_acc_nl = nl_W_HEIGHT_acc_nl[2:0];
  assign W_HEIGHT_acc_itm_2_1 = readslicef_3_1_2(W_HEIGHT_acc_nl);
  assign nl_W_WIDTH_acc_nl = ({1'b1 , (W_WIDTH_col_4_0_sva_3[4:3])}) + 3'b001;
  assign W_WIDTH_acc_nl = nl_W_WIDTH_acc_nl[2:0];
  assign W_WIDTH_acc_itm_2_1 = readslicef_3_1_2(W_WIDTH_acc_nl);
  always @(posedge clk) begin
    if ( W_WIDTH_for_for_and_cse ) begin
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_287_266 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[252:231];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_8_0 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[8:0];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_264_260 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[230:226];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_18_10 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[17:9];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_258_257 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[225:224];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_42_20 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[40:18];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_255_249 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[223:217];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_53_44 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[50:41];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_247_244 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[216:213];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_66_55 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[62:51];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_242_233 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[212:203];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_70_69 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[64:63];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_231_229 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[202:200];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_84_72 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[77:65];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_224 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[199];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_104_86 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[96:78];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_222_214 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[198:190];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_107_106 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[98:97];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_212_209 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[189:186];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_111_109 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[101:99];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_207_203 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[185:181];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_125_113 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[114:102];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_201_187 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[180:166];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_127 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[115];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_185_166 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[165:146];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_141_129 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[128:116];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_164_158 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[145:139];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_150_143 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[136:129];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_156 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[138];
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_idat_152 <= W_WIDTH_for_for_if_read_rom_C_1152_1_map_1_cmp_data_out_mxwt[137];
    end
  end
  always @(posedge clk) begin
    if ( AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp ) begin
      W_HEIGHT_row_4_0_sva <= MUX_v_5_2_2(5'b00000, W_WIDTH_mux_nl, (fsm_output[1]));
      W_WIDTH_col_4_0_sva <= W_WIDTH_col_mux_nl & ({{4{lfst_exit_W_WIDTH_sva_dfm_1}},
          lfst_exit_W_WIDTH_sva_dfm_1}) & (signext_5_1(fsm_output[1]));
      W_WIDTH_for_for_outChan_2_0_lpi_2_1_0 <= W_WIDTH_for_for_acc_1_tmp[1:0];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      W_HEIGHT_stage_0 <= 1'b0;
      lfst_exit_W_WIDTH_sva <= 1'b0;
      W_HEIGHT_stage_0_2 <= 1'b0;
      reg_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_oswt_cse <= 1'b0;
    end
    else if ( AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_wen_comp ) begin
      W_HEIGHT_stage_0 <= ~((~(W_HEIGHT_stage_0 & (or_dcpl_1 | W_HEIGHT_acc_itm_2_1)))
          & (fsm_output[1]));
      lfst_exit_W_WIDTH_sva <= lfst_exit_W_WIDTH_sva_dfm_1 & (fsm_output[1]);
      W_HEIGHT_stage_0_2 <= W_HEIGHT_stage_0 & (fsm_output[1]);
      reg_AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsci_oswt_cse <= W_HEIGHT_stage_0_2
          & (fsm_output[1]);
    end
  end
  assign W_WIDTH_mux_nl = MUX_v_5_2_2(W_HEIGHT_row_4_0_sva_2, W_HEIGHT_row_4_0_sva,
      or_dcpl_1);
  assign W_WIDTH_col_mux_nl = MUX_v_5_2_2(W_WIDTH_col_4_0_sva, W_WIDTH_col_4_0_sva_3,
      W_WIDTH_for_for_acc_1_tmp[2]);

  function automatic [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input  sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function automatic [4:0] MUX_v_5_2_2;
    input [4:0] input_0;
    input [4:0] input_1;
    input  sel;
    reg [4:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_5_2_2 = result;
  end
  endfunction


  function automatic [0:0] readslicef_3_1_2;
    input [2:0] vector;
    reg [2:0] tmp;
  begin
    tmp = vector >> 2;
    readslicef_3_1_2 = tmp[0:0];
  end
  endfunction


  function automatic [4:0] signext_5_1;
    input  vector;
  begin
    signext_5_1= {{4{vector}}, vector};
  end
  endfunction


  function automatic [2:0] conv_u2s_2_3 ;
    input [1:0]  vector ;
  begin
    conv_u2s_2_3 =  {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run
    (
  clk, rst, din_rsc_dat, din_rsc_vld, din_rsc_rdy, dout_rsc_dat, dout_rsc_vld, dout_rsc_rdy
);
  input clk;
  input rst;
  input [31:0] din_rsc_dat;
  input din_rsc_vld;
  output din_rsc_rdy;
  output [107:0] dout_rsc_dat;
  output dout_rsc_vld;
  input dout_rsc_rdy;


  // Interconnect Declarations
  reg run_wen;
  wire din_rsci_wen_comp;
  wire [31:0] din_rsci_idat_mxwt;
  wire dout_rsci_wen_comp;
  reg [7:0] dout_rsci_idat_106_99;
  reg [7:0] dout_rsci_idat_97_90;
  reg [7:0] dout_rsci_idat_88_81;
  reg [7:0] dout_rsci_idat_79_72;
  reg [7:0] dout_rsci_idat_70_63;
  reg [7:0] dout_rsci_idat_61_54;
  reg [7:0] dout_rsci_idat_52_45;
  reg [7:0] dout_rsci_idat_43_36;
  reg [7:0] dout_rsci_idat_34_27;
  reg [7:0] dout_rsci_idat_25_18;
  reg [7:0] dout_rsci_idat_16_9;
  reg [7:0] dout_rsci_idat_7_0;
  wire [5:0] fsm_output;
  wire and_dcpl_6;
  wire and_dcpl_9;
  wire and_dcpl_10;
  wire and_dcpl_11;
  wire and_dcpl_14;
  wire and_dcpl_15;
  wire and_dcpl_22;
  wire and_dcpl_25;
  wire and_dcpl_32;
  wire and_dcpl_33;
  wire and_dcpl_35;
  wire and_dcpl_36;
  wire and_dcpl_37;
  wire and_dcpl_39;
  wire and_dcpl_41;
  wire and_dcpl_43;
  wire and_dcpl_45;
  wire and_dcpl_47;
  wire and_dcpl_49;
  wire and_dcpl_60;
  wire not_tmp_24;
  wire not_tmp_25;
  wire not_tmp_26;
  wire not_tmp_27;
  wire not_tmp_28;
  wire not_tmp_29;
  wire not_tmp_30;
  wire not_tmp_31;
  wire nor_tmp_1;
  wire and_dcpl_69;
  wire mux_tmp_8;
  wire and_dcpl_71;
  wire mux_tmp_9;
  wire mux_tmp_10;
  wire mux_tmp_11;
  wire mux_tmp_12;
  wire mux_tmp_13;
  wire mux_tmp_14;
  wire mux_tmp_15;
  wire and_dcpl_88;
  wire and_dcpl_97;
  wire mux_tmp_24;
  wire and_dcpl_99;
  wire mux_tmp_25;
  wire mux_tmp_26;
  wire mux_tmp_27;
  wire mux_tmp_28;
  wire mux_tmp_29;
  wire mux_tmp_30;
  wire mux_tmp_31;
  reg FMAP_WIDTH_HWC_FMAP_WIDTH_HWC_and_itm;
  reg upper_1_0_sva;
  reg upper_1_0_sva_1;
  reg lower_1_0_sva;
  reg lower_1_1_sva;
  reg lower_1_0_sva_1;
  wire [1:0] d_buf_chan_d_bufPtr_lpi_3_dfm_mx0;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_0_sva_mx0w1;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_1_0_sva_1;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_1_sva_mx0w1;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_1_1_sva_1;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_2_sva_mx0w1;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_1_2_sva_1;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_3_sva_mx0w1;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_1_3_sva_1;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_4_sva_mx0w1;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_5_sva_mx0w1;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_6_sva_mx0w1;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_7_sva_mx0w1;
  reg [4:0] FMAP_HEIGHT_HWC_row_4_0_sva;
  reg [4:0] FMAP_WIDTH_HWC_col_4_0_sva;
  reg [1:0] d_buf_chan_d_bufPtr_lpi_2;
  reg d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_3_sva;
  reg d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_4_sva;
  reg d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_2_sva;
  reg d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_5_sva;
  reg d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_1_sva;
  reg d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_6_sva;
  reg d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_0_sva;
  reg d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_7_sva;
  reg d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_3_sva;
  reg d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_4_sva;
  reg d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_2_sva;
  reg d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_5_sva;
  reg d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_1_sva;
  reg d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_6_sva;
  reg d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_0_sva;
  reg d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_7_sva;
  reg operator_3_false_slc_operator_3_false_acc_5_svs_st;
  reg IN_CHAN_HWC_EXTRA_if_slc_IN_CHAN_HWC_EXTRA_if_acc_2_svs_st;
  wire [1:0] d_buf_chan_d_bufPtr_lpi_3_dfm_1_mx0w1;
  wire IN_CHAN_HWC_if_and_cse;
  wire lower_and_cse;
  wire lower_and_1_cse;
  wire run_wen_rtff;
  reg reg_din_rsci_oswt_tmp;
  reg reg_dout_rsci_oswt_tmp;
  wire IN_CHAN_HWC_EXTRA_if_mux_2_rmff;
  wire IN_CHAN_HWC_if_mux_rmff;
  wire [31:0] dinTmp_data_lpi_3_dfm_mx0;
  wire [4:0] z_out;
  wire [5:0] nl_z_out;
  reg [1:0] d_buf_chan_d_bufPtr_sva;
  reg [31:0] dinTmp_data_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_11_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_11_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_11_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_11_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_12_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_12_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_12_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_12_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_10_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_10_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_10_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_10_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_13_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_13_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_13_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_13_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_9_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_9_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_9_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_9_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_14_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_14_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_14_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_14_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_8_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_8_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_8_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_8_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_15_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_15_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_15_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_15_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_7_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_7_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_7_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_7_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_16_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_16_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_16_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_16_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_6_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_6_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_6_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_6_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_17_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_17_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_17_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_17_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_5_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_5_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_5_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_5_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_18_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_18_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_18_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_18_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_4_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_4_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_4_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_4_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_19_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_19_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_19_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_19_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_3_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_3_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_3_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_3_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_20_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_20_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_20_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_20_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_2_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_2_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_2_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_2_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_21_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_21_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_21_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_21_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_1_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_1_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_1_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_1_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_22_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_22_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_22_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_22_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_0_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_0_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_0_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_0_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_23_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_23_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_23_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf0_data_23_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_11_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_11_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_11_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_11_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_12_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_12_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_12_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_12_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_10_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_10_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_10_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_10_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_13_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_13_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_13_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_13_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_9_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_9_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_9_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_9_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_14_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_14_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_14_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_14_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_8_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_8_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_8_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_8_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_15_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_15_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_15_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_15_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_7_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_7_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_7_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_7_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_16_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_16_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_16_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_16_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_6_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_6_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_6_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_6_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_17_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_17_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_17_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_17_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_5_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_5_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_5_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_5_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_18_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_18_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_18_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_18_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_4_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_4_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_4_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_4_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_19_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_19_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_19_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_19_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_3_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_3_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_3_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_3_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_20_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_20_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_20_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_20_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_2_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_2_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_2_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_2_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_21_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_21_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_21_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_21_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_1_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_1_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_1_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_1_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_22_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_22_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_22_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_22_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_0_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_0_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_0_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_0_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_23_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_23_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_23_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf1_data_23_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_11_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_11_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_11_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_11_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_12_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_12_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_12_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_12_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_10_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_10_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_10_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_10_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_13_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_13_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_13_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_13_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_9_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_9_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_9_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_9_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_14_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_14_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_14_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_14_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_8_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_8_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_8_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_8_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_15_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_15_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_15_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_15_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_7_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_7_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_7_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_7_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_16_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_16_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_16_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_16_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_6_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_6_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_6_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_6_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_17_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_17_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_17_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_17_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_5_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_5_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_5_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_5_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_18_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_18_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_18_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_18_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_4_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_4_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_4_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_4_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_19_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_19_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_19_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_19_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_3_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_3_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_3_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_3_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_20_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_20_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_20_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_20_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_2_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_2_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_2_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_2_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_21_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_21_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_21_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_21_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_1_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_1_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_1_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_1_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_22_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_22_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_22_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_22_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_0_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_0_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_0_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_0_34_27_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_23_16_9_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_23_25_18_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_23_7_0_lpi_2;
  reg [7:0] d_buf_chan_d_lineBuf2_data_23_34_27_lpi_2;
  reg [1:0] d_buf_chan_d_bufPtr_lpi_3;
  reg [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_16_9_sva;
  reg [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_25_18_sva;
  reg [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_7_0_sva;
  reg [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_34_27_sva;
  reg [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_16_9_sva;
  reg [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_25_18_sva;
  reg [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_7_0_sva;
  reg [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_34_27_sva;
  reg [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_16_9_sva;
  reg [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_25_18_sva;
  reg [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_7_0_sva;
  reg [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_34_27_sva;
  reg d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_7_sva;
  reg d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_6_sva;
  reg d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_5_sva;
  reg d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_4_sva;
  reg d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_3_sva;
  reg d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_2_sva;
  reg d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_1_sva;
  reg d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_0_sva;
  reg d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_7_sva;
  reg d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_6_sva;
  reg d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_5_sva;
  reg d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_4_sva;
  reg d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_3_sva;
  reg d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_2_sva;
  reg d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_1_sva;
  reg d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_0_sva;
  reg d_buf_chan_rd_wr_buffer_1_switch_lp_equal_tmp;
  reg [4:0] FMAP_WIDTH_HWC_col_4_0_sva_1;
  reg [7:0] bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_itm;
  reg [7:0] bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_1_itm;
  reg [7:0] bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_2_itm;
  reg [7:0] bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_3_itm;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_0_sva_mx0w1;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_1_sva_mx0w1;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_2_sva_mx0w1;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_3_sva_mx0w1;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_4_sva_mx0w1;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_5_sva_mx0w1;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_6_sva_mx0w1;
  wire d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_7_sva_mx0w1;
  wire [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_7_0_sva_1;
  wire d_buf_chan_rd_wr_buffer_1_switch_lp_equal_tmp_1;
  wire [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_7_0_sva_1;
  wire [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_7_0_sva_1;
  wire [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_16_9_sva_1;
  wire [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_16_9_sva_1;
  wire [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_16_9_sva_1;
  wire [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_25_18_sva_1;
  wire [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_25_18_sva_1;
  wire [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_25_18_sva_1;
  wire [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_34_27_sva_1;
  wire [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_34_27_sva_1;
  wire [7:0] d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_34_27_sva_1;
  wire bounds_apply_bounds_else_else_else_if_switch_lp_exs_5_0;
  wire bounds_apply_bounds_else_else_else_if_switch_lp_1_exs_5_0;
  wire d_buf_chan_rd_wr_buffer_case_1_if_and_20_cse;
  wire d_buf_chan_rd_wr_buffer_case_2_if_and_cse;
  wire d_buf_chan_d_lineBuf0_data_and_cse;
  wire d_buf_chan_d_lineBuf0_data_and_4_cse;
  wire d_buf_chan_d_lineBuf0_data_and_8_cse;
  wire d_buf_chan_d_lineBuf0_data_and_12_cse;
  wire d_buf_chan_d_lineBuf0_data_and_16_cse;
  wire d_buf_chan_d_lineBuf0_data_and_20_cse;
  wire d_buf_chan_d_lineBuf0_data_and_24_cse;
  wire d_buf_chan_d_lineBuf0_data_and_28_cse;
  wire d_buf_chan_d_lineBuf0_data_and_32_cse;
  wire d_buf_chan_d_lineBuf0_data_and_36_cse;
  wire d_buf_chan_d_lineBuf0_data_and_40_cse;
  wire d_buf_chan_d_lineBuf0_data_and_44_cse;
  wire d_buf_chan_d_lineBuf0_data_and_48_cse;
  wire d_buf_chan_d_lineBuf0_data_and_52_cse;
  wire d_buf_chan_d_lineBuf0_data_and_56_cse;
  wire d_buf_chan_d_lineBuf0_data_and_60_cse;
  wire d_buf_chan_d_lineBuf0_data_and_64_cse;
  wire d_buf_chan_d_lineBuf0_data_and_68_cse;
  wire d_buf_chan_d_lineBuf0_data_and_72_cse;
  wire d_buf_chan_d_lineBuf0_data_and_76_cse;
  wire d_buf_chan_d_lineBuf0_data_and_80_cse;
  wire d_buf_chan_d_lineBuf0_data_and_84_cse;
  wire d_buf_chan_d_lineBuf0_data_and_88_cse;
  wire d_buf_chan_d_lineBuf0_data_and_92_cse;
  wire d_buf_chan_d_lineBuf1_data_and_cse;
  wire d_buf_chan_d_lineBuf1_data_and_4_cse;
  wire d_buf_chan_d_lineBuf1_data_and_8_cse;
  wire d_buf_chan_d_lineBuf1_data_and_12_cse;
  wire d_buf_chan_d_lineBuf1_data_and_16_cse;
  wire d_buf_chan_d_lineBuf1_data_and_20_cse;
  wire d_buf_chan_d_lineBuf1_data_and_24_cse;
  wire d_buf_chan_d_lineBuf1_data_and_28_cse;
  wire d_buf_chan_d_lineBuf1_data_and_32_cse;
  wire d_buf_chan_d_lineBuf1_data_and_36_cse;
  wire d_buf_chan_d_lineBuf1_data_and_40_cse;
  wire d_buf_chan_d_lineBuf1_data_and_44_cse;
  wire d_buf_chan_d_lineBuf1_data_and_48_cse;
  wire d_buf_chan_d_lineBuf1_data_and_52_cse;
  wire d_buf_chan_d_lineBuf1_data_and_56_cse;
  wire d_buf_chan_d_lineBuf1_data_and_60_cse;
  wire d_buf_chan_d_lineBuf1_data_and_64_cse;
  wire d_buf_chan_d_lineBuf1_data_and_68_cse;
  wire d_buf_chan_d_lineBuf1_data_and_72_cse;
  wire d_buf_chan_d_lineBuf1_data_and_76_cse;
  wire d_buf_chan_d_lineBuf1_data_and_80_cse;
  wire d_buf_chan_d_lineBuf1_data_and_84_cse;
  wire d_buf_chan_d_lineBuf1_data_and_88_cse;
  wire d_buf_chan_d_lineBuf1_data_and_92_cse;
  wire d_buf_chan_d_lineBuf2_data_and_cse;
  wire d_buf_chan_d_lineBuf2_data_and_4_cse;
  wire d_buf_chan_d_lineBuf2_data_and_8_cse;
  wire d_buf_chan_d_lineBuf2_data_and_12_cse;
  wire d_buf_chan_d_lineBuf2_data_and_16_cse;
  wire d_buf_chan_d_lineBuf2_data_and_20_cse;
  wire d_buf_chan_d_lineBuf2_data_and_24_cse;
  wire d_buf_chan_d_lineBuf2_data_and_28_cse;
  wire d_buf_chan_d_lineBuf2_data_and_32_cse;
  wire d_buf_chan_d_lineBuf2_data_and_36_cse;
  wire d_buf_chan_d_lineBuf2_data_and_40_cse;
  wire d_buf_chan_d_lineBuf2_data_and_44_cse;
  wire d_buf_chan_d_lineBuf2_data_and_48_cse;
  wire d_buf_chan_d_lineBuf2_data_and_52_cse;
  wire d_buf_chan_d_lineBuf2_data_and_56_cse;
  wire d_buf_chan_d_lineBuf2_data_and_60_cse;
  wire d_buf_chan_d_lineBuf2_data_and_64_cse;
  wire d_buf_chan_d_lineBuf2_data_and_68_cse;
  wire d_buf_chan_d_lineBuf2_data_and_72_cse;
  wire d_buf_chan_d_lineBuf2_data_and_76_cse;
  wire d_buf_chan_d_lineBuf2_data_and_80_cse;
  wire d_buf_chan_d_lineBuf2_data_and_84_cse;
  wire d_buf_chan_d_lineBuf2_data_and_88_cse;
  wire d_buf_chan_d_lineBuf2_data_and_92_cse;
  wire IN_CHAN_HWC_EXTRA_if_acc_itm_2_1;

  wire FMAP_HEIGHT_HWC_mux_2_nl;
  wire FMAP_HEIGHT_HWC_mux_3_nl;
  wire mux_nl;
  wire mux_1_nl;
  wire mux_2_nl;
  wire mux_3_nl;
  wire mux_4_nl;
  wire mux_5_nl;
  wire mux_6_nl;
  wire mux_7_nl;
  wire mux_16_nl;
  wire nor_21_nl;
  wire or_469_nl;
  wire mux_17_nl;
  wire nor_22_nl;
  wire or_472_nl;
  wire mux_18_nl;
  wire nor_23_nl;
  wire or_474_nl;
  wire mux_19_nl;
  wire nor_24_nl;
  wire or_476_nl;
  wire mux_20_nl;
  wire nor_25_nl;
  wire or_479_nl;
  wire mux_21_nl;
  wire nor_26_nl;
  wire or_482_nl;
  wire mux_22_nl;
  wire nor_27_nl;
  wire or_484_nl;
  wire mux_23_nl;
  wire nor_28_nl;
  wire or_486_nl;
  wire and_1524_nl;
  wire and_1525_nl;
  wire[7:0] d_buf_chan_rd_wr_buffer_1_switch_lp_mux1h_7_nl;
  wire[7:0] d_buf_chan_rd_wr_buffer_1_switch_lp_mux1h_6_nl;
  wire[7:0] d_buf_chan_rd_wr_buffer_1_switch_lp_mux1h_5_nl;
  wire[7:0] d_buf_chan_rd_wr_buffer_1_switch_lp_mux1h_4_nl;
  wire d_buf_chan_rd_wr_buffer_d_buf_chan_rd_wr_buffer_nand_nl;
  wire[2:0] IN_CHAN_HWC_EXTRA_if_acc_nl;
  wire[3:0] nl_IN_CHAN_HWC_EXTRA_if_acc_nl;
  wire[1:0] d_buf_chan_rd_wr_buffer_if_acc_nl;
  wire[2:0] nl_d_buf_chan_rd_wr_buffer_if_acc_nl;
  wire and_796_nl;
  wire nor_12_nl;
  wire or_488_nl;
  wire nor_13_nl;
  wire or_490_nl;
  wire nor_14_nl;
  wire or_492_nl;
  wire nor_15_nl;
  wire or_494_nl;
  wire nor_16_nl;
  wire or_496_nl;
  wire nor_17_nl;
  wire or_498_nl;
  wire nor_18_nl;
  wire or_500_nl;
  wire nor_19_nl;
  wire or_502_nl;
  wire[4:0] FMAP_HEIGHT_HWC_mux_5_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [107:0] nl_branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_dout_rsci_inst_dout_rsci_idat;
  assign nl_branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_dout_rsci_inst_dout_rsci_idat
      = {1'b0 , dout_rsci_idat_106_99 , 1'b0 , dout_rsci_idat_97_90 , 1'b0 , dout_rsci_idat_88_81
      , 1'b0 , dout_rsci_idat_79_72 , 1'b0 , dout_rsci_idat_70_63 , 1'b0 , dout_rsci_idat_61_54
      , 1'b0 , dout_rsci_idat_52_45 , 1'b0 , dout_rsci_idat_43_36 , 1'b0 , dout_rsci_idat_34_27
      , 1'b0 , dout_rsci_idat_25_18 , 1'b0 , dout_rsci_idat_16_9 , 1'b0 , dout_rsci_idat_7_0};
  wire[5:0] operator_33_true_acc_nl;
  wire[6:0] nl_operator_33_true_acc_nl;
  wire  nl_branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_run_fsm_inst_FMAP_HEIGHT_HWC_C_1_tr0;
  assign nl_operator_33_true_acc_nl = 6'b100111 + conv_u2s_5_6(z_out);
  assign operator_33_true_acc_nl = nl_operator_33_true_acc_nl[5:0];
  assign nl_branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_run_fsm_inst_FMAP_HEIGHT_HWC_C_1_tr0
      = ~ (readslicef_6_1_5(operator_33_true_acc_nl));
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_din_rsci
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_din_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsc_dat(din_rsc_dat),
      .din_rsc_vld(din_rsc_vld),
      .din_rsc_rdy(din_rsc_rdy),
      .din_rsci_oswt(reg_din_rsci_oswt_tmp),
      .din_rsci_wen_comp(din_rsci_wen_comp),
      .din_rsci_idat_mxwt(din_rsci_idat_mxwt),
      .din_rsci_oswt_pff(IN_CHAN_HWC_EXTRA_if_mux_2_rmff)
    );
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_dout_rsci
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_dout_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_rsc_dat(dout_rsc_dat),
      .dout_rsc_vld(dout_rsc_vld),
      .dout_rsc_rdy(dout_rsc_rdy),
      .dout_rsci_oswt(reg_dout_rsci_oswt_tmp),
      .dout_rsci_wen_comp(dout_rsci_wen_comp),
      .dout_rsci_idat(nl_branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_dout_rsci_inst_dout_rsci_idat[107:0]),
      .dout_rsci_oswt_pff(IN_CHAN_HWC_if_mux_rmff)
    );
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_staller
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_staller_inst
      (
      .run_wen(run_wen_rtff),
      .din_rsci_wen_comp(din_rsci_wen_comp),
      .dout_rsci_wen_comp(dout_rsci_wen_comp)
    );
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_run_fsm
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_run_fsm_inst
      (
      .clk(clk),
      .rst(rst),
      .run_wen(run_wen),
      .fsm_output(fsm_output),
      .FMAP_WIDTH_HWC_C_2_tr0(FMAP_WIDTH_HWC_FMAP_WIDTH_HWC_and_itm),
      .FMAP_HEIGHT_HWC_C_1_tr0(nl_branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_run_fsm_inst_FMAP_HEIGHT_HWC_C_1_tr0)
    );
  assign lower_and_cse = run_wen & ((fsm_output[5]) | (fsm_output[0]));
  assign IN_CHAN_HWC_if_and_cse = run_wen & (~(operator_3_false_slc_operator_3_false_acc_5_svs_st
      | (~ (fsm_output[3]))));
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_20_cse = run_wen & (d_buf_chan_d_bufPtr_lpi_2==2'b01)
      & (fsm_output[3]);
  assign d_buf_chan_rd_wr_buffer_case_2_if_and_cse = run_wen & (d_buf_chan_d_bufPtr_lpi_2==2'b10)
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_cse = run_wen & and_dcpl_11 & and_dcpl_10
      & and_dcpl_9 & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_4_cse = run_wen & and_dcpl_15 & and_dcpl_14
      & and_dcpl_9 & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_8_cse = run_wen & and_dcpl_15 & and_dcpl_10
      & and_dcpl_9 & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_12_cse = run_wen & and_dcpl_11 & and_dcpl_14
      & and_dcpl_9 & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_16_cse = run_wen & and_dcpl_11 & and_dcpl_22
      & and_dcpl_9 & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_20_cse = run_wen & and_dcpl_15 & and_dcpl_25
      & and_dcpl_9 & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_24_cse = run_wen & and_dcpl_15 & and_dcpl_22
      & and_dcpl_9 & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_28_cse = run_wen & and_dcpl_11 & and_dcpl_25
      & and_dcpl_9 & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_32_cse = run_wen & and_dcpl_33 & and_dcpl_9
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_36_cse = run_wen & and_dcpl_37 & and_dcpl_35
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_40_cse = run_wen & and_dcpl_39 & and_dcpl_9
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_44_cse = run_wen & and_dcpl_41 & and_dcpl_35
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_48_cse = run_wen & and_dcpl_43 & and_dcpl_9
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_52_cse = run_wen & and_dcpl_45 & and_dcpl_35
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_56_cse = run_wen & and_dcpl_47 & and_dcpl_9
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_60_cse = run_wen & and_dcpl_49 & and_dcpl_35
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_64_cse = run_wen & and_dcpl_49 & and_dcpl_9
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_68_cse = run_wen & and_dcpl_47 & and_dcpl_35
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_72_cse = run_wen & and_dcpl_45 & and_dcpl_9
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_76_cse = run_wen & and_dcpl_43 & and_dcpl_35
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_80_cse = run_wen & and_dcpl_41 & and_dcpl_9
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_84_cse = run_wen & and_dcpl_39 & and_dcpl_35
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_88_cse = run_wen & and_dcpl_37 & and_dcpl_9
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf0_data_and_92_cse = run_wen & and_dcpl_6 & FMAP_WIDTH_HWC_FMAP_WIDTH_HWC_and_itm
      & (fsm_output[3]);
  assign mux_nl = MUX_s_1_2_2(not_tmp_25, d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_3_sva,
      d_buf_chan_d_bufPtr_lpi_2[1]);
  assign d_buf_chan_d_lineBuf1_data_and_cse = run_wen & mux_nl & and_dcpl_60 & (fsm_output[3]);
  assign mux_1_nl = MUX_s_1_2_2(not_tmp_26, d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_4_sva,
      d_buf_chan_d_bufPtr_lpi_2[1]);
  assign d_buf_chan_d_lineBuf1_data_and_4_cse = run_wen & mux_1_nl & and_dcpl_60
      & (fsm_output[3]);
  assign mux_2_nl = MUX_s_1_2_2(not_tmp_27, d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_2_sva,
      d_buf_chan_d_bufPtr_lpi_2[1]);
  assign d_buf_chan_d_lineBuf1_data_and_8_cse = run_wen & mux_2_nl & and_dcpl_60
      & (fsm_output[3]);
  assign mux_3_nl = MUX_s_1_2_2(not_tmp_28, d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_5_sva,
      d_buf_chan_d_bufPtr_lpi_2[1]);
  assign d_buf_chan_d_lineBuf1_data_and_12_cse = run_wen & mux_3_nl & and_dcpl_60
      & (fsm_output[3]);
  assign mux_4_nl = MUX_s_1_2_2(not_tmp_29, d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_1_sva,
      d_buf_chan_d_bufPtr_lpi_2[1]);
  assign d_buf_chan_d_lineBuf1_data_and_16_cse = run_wen & mux_4_nl & and_dcpl_60
      & (fsm_output[3]);
  assign mux_5_nl = MUX_s_1_2_2(not_tmp_30, d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_6_sva,
      d_buf_chan_d_bufPtr_lpi_2[1]);
  assign d_buf_chan_d_lineBuf1_data_and_20_cse = run_wen & mux_5_nl & and_dcpl_60
      & (fsm_output[3]);
  assign mux_6_nl = MUX_s_1_2_2(not_tmp_31, d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_0_sva,
      d_buf_chan_d_bufPtr_lpi_2[1]);
  assign d_buf_chan_d_lineBuf1_data_and_24_cse = run_wen & mux_6_nl & and_dcpl_60
      & (fsm_output[3]);
  assign mux_7_nl = MUX_s_1_2_2(nor_tmp_1, d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_7_sva,
      d_buf_chan_d_bufPtr_lpi_2[1]);
  assign d_buf_chan_d_lineBuf1_data_and_28_cse = run_wen & mux_7_nl & and_dcpl_60
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf1_data_and_32_cse = run_wen & mux_tmp_8 & and_dcpl_69
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf1_data_and_36_cse = run_wen & mux_tmp_9 & and_dcpl_71
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf1_data_and_40_cse = run_wen & mux_tmp_10 & and_dcpl_69
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf1_data_and_44_cse = run_wen & mux_tmp_11 & and_dcpl_71
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf1_data_and_48_cse = run_wen & mux_tmp_12 & and_dcpl_69
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf1_data_and_52_cse = run_wen & mux_tmp_13 & and_dcpl_71
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf1_data_and_56_cse = run_wen & mux_tmp_14 & and_dcpl_69
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf1_data_and_60_cse = run_wen & mux_tmp_15 & and_dcpl_71
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf1_data_and_64_cse = run_wen & mux_tmp_15 & and_dcpl_69
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf1_data_and_68_cse = run_wen & mux_tmp_14 & and_dcpl_71
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf1_data_and_72_cse = run_wen & mux_tmp_13 & and_dcpl_69
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf1_data_and_76_cse = run_wen & mux_tmp_12 & and_dcpl_71
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf1_data_and_80_cse = run_wen & mux_tmp_11 & and_dcpl_69
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf1_data_and_84_cse = run_wen & mux_tmp_10 & and_dcpl_71
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf1_data_and_88_cse = run_wen & mux_tmp_9 & and_dcpl_69
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf1_data_and_92_cse = run_wen & mux_tmp_8 & and_dcpl_71
      & (fsm_output[3]);
  assign nor_21_nl = ~((d_buf_chan_d_bufPtr_lpi_2[0]) | (FMAP_WIDTH_HWC_col_4_0_sva[2])
      | not_tmp_24);
  assign or_469_nl = (d_buf_chan_d_bufPtr_lpi_2[0]) | not_tmp_25;
  assign mux_16_nl = MUX_s_1_2_2(nor_21_nl, or_469_nl, d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_3_sva);
  assign d_buf_chan_d_lineBuf2_data_and_cse = run_wen & mux_16_nl & and_dcpl_88 &
      (fsm_output[3]);
  assign nor_22_nl = ~((d_buf_chan_d_bufPtr_lpi_2[0]) | (FMAP_WIDTH_HWC_col_4_0_sva[2:0]!=3'b100));
  assign or_472_nl = (d_buf_chan_d_bufPtr_lpi_2[0]) | not_tmp_26;
  assign mux_17_nl = MUX_s_1_2_2(nor_22_nl, or_472_nl, d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_4_sva);
  assign d_buf_chan_d_lineBuf2_data_and_4_cse = run_wen & mux_17_nl & and_dcpl_88
      & (fsm_output[3]);
  assign nor_23_nl = ~((d_buf_chan_d_bufPtr_lpi_2[0]) | (FMAP_WIDTH_HWC_col_4_0_sva[2:0]!=3'b010));
  assign or_474_nl = (d_buf_chan_d_bufPtr_lpi_2[0]) | not_tmp_27;
  assign mux_18_nl = MUX_s_1_2_2(nor_23_nl, or_474_nl, d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_2_sva);
  assign d_buf_chan_d_lineBuf2_data_and_8_cse = run_wen & mux_18_nl & and_dcpl_88
      & (fsm_output[3]);
  assign nor_24_nl = ~((d_buf_chan_d_bufPtr_lpi_2[0]) | (FMAP_WIDTH_HWC_col_4_0_sva[2:0]!=3'b101));
  assign or_476_nl = (d_buf_chan_d_bufPtr_lpi_2[0]) | not_tmp_28;
  assign mux_19_nl = MUX_s_1_2_2(nor_24_nl, or_476_nl, d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_5_sva);
  assign d_buf_chan_d_lineBuf2_data_and_12_cse = run_wen & mux_19_nl & and_dcpl_88
      & (fsm_output[3]);
  assign nor_25_nl = ~((d_buf_chan_d_bufPtr_lpi_2[0]) | (FMAP_WIDTH_HWC_col_4_0_sva[2:0]!=3'b001));
  assign or_479_nl = (d_buf_chan_d_bufPtr_lpi_2[0]) | not_tmp_29;
  assign mux_20_nl = MUX_s_1_2_2(nor_25_nl, or_479_nl, d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_1_sva);
  assign d_buf_chan_d_lineBuf2_data_and_16_cse = run_wen & mux_20_nl & and_dcpl_88
      & (fsm_output[3]);
  assign nor_26_nl = ~((d_buf_chan_d_bufPtr_lpi_2[0]) | (FMAP_WIDTH_HWC_col_4_0_sva[2:0]!=3'b110));
  assign or_482_nl = (d_buf_chan_d_bufPtr_lpi_2[0]) | not_tmp_30;
  assign mux_21_nl = MUX_s_1_2_2(nor_26_nl, or_482_nl, d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_6_sva);
  assign d_buf_chan_d_lineBuf2_data_and_20_cse = run_wen & mux_21_nl & and_dcpl_88
      & (fsm_output[3]);
  assign nor_27_nl = ~((d_buf_chan_d_bufPtr_lpi_2[0]) | (FMAP_WIDTH_HWC_col_4_0_sva[2:0]!=3'b000));
  assign or_484_nl = (d_buf_chan_d_bufPtr_lpi_2[0]) | not_tmp_31;
  assign mux_22_nl = MUX_s_1_2_2(nor_27_nl, or_484_nl, d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_0_sva);
  assign d_buf_chan_d_lineBuf2_data_and_24_cse = run_wen & mux_22_nl & and_dcpl_88
      & (fsm_output[3]);
  assign nor_28_nl = ~((d_buf_chan_d_bufPtr_lpi_2[0]) | (~ nor_tmp_1));
  assign or_486_nl = (d_buf_chan_d_bufPtr_lpi_2[0]) | nor_tmp_1;
  assign mux_23_nl = MUX_s_1_2_2(nor_28_nl, or_486_nl, d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_7_sva);
  assign d_buf_chan_d_lineBuf2_data_and_28_cse = run_wen & mux_23_nl & and_dcpl_88
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf2_data_and_32_cse = run_wen & mux_tmp_24 & and_dcpl_97
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf2_data_and_36_cse = run_wen & mux_tmp_25 & and_dcpl_99
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf2_data_and_40_cse = run_wen & mux_tmp_26 & and_dcpl_97
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf2_data_and_44_cse = run_wen & mux_tmp_27 & and_dcpl_99
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf2_data_and_48_cse = run_wen & mux_tmp_28 & and_dcpl_97
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf2_data_and_52_cse = run_wen & mux_tmp_29 & and_dcpl_99
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf2_data_and_56_cse = run_wen & mux_tmp_30 & and_dcpl_97
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf2_data_and_60_cse = run_wen & mux_tmp_31 & and_dcpl_99
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf2_data_and_64_cse = run_wen & mux_tmp_31 & and_dcpl_97
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf2_data_and_68_cse = run_wen & mux_tmp_30 & and_dcpl_99
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf2_data_and_72_cse = run_wen & mux_tmp_29 & and_dcpl_97
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf2_data_and_76_cse = run_wen & mux_tmp_28 & and_dcpl_99
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf2_data_and_80_cse = run_wen & mux_tmp_27 & and_dcpl_97
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf2_data_and_84_cse = run_wen & mux_tmp_26 & and_dcpl_99
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf2_data_and_88_cse = run_wen & mux_tmp_25 & and_dcpl_97
      & (fsm_output[3]);
  assign d_buf_chan_d_lineBuf2_data_and_92_cse = run_wen & mux_tmp_24 & and_dcpl_99
      & (fsm_output[3]);
  assign and_1524_nl = IN_CHAN_HWC_EXTRA_if_acc_itm_2_1 & (fsm_output[2]);
  assign IN_CHAN_HWC_EXTRA_if_mux_2_rmff = MUX_s_1_2_2(reg_din_rsci_oswt_tmp, and_1524_nl,
      run_wen);
  assign and_1525_nl = (~ operator_3_false_slc_operator_3_false_acc_5_svs_st) & (fsm_output[3]);
  assign IN_CHAN_HWC_if_mux_rmff = MUX_s_1_2_2(reg_dout_rsci_oswt_tmp, and_1525_nl,
      run_wen);
  assign lower_and_1_cse = run_wen & (fsm_output[1]);
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_0_sva_mx0w1 = d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_0_sva_mx0w1
      & (~ (FMAP_WIDTH_HWC_col_4_0_sva[3]));
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_0_sva_mx0w1 = d_buf_chan_rd_wr_buffer_case_1_if_and_stg_1_0_sva_1
      & (~ (FMAP_WIDTH_HWC_col_4_0_sva[2]));
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_1_sva_mx0w1 = d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_1_sva_mx0w1
      & (~ (FMAP_WIDTH_HWC_col_4_0_sva[3]));
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_1_sva_mx0w1 = d_buf_chan_rd_wr_buffer_case_1_if_and_stg_1_1_sva_1
      & (~ (FMAP_WIDTH_HWC_col_4_0_sva[2]));
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_2_sva_mx0w1 = d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_2_sva_mx0w1
      & (~ (FMAP_WIDTH_HWC_col_4_0_sva[3]));
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_2_sva_mx0w1 = d_buf_chan_rd_wr_buffer_case_1_if_and_stg_1_2_sva_1
      & (~ (FMAP_WIDTH_HWC_col_4_0_sva[2]));
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_3_sva_mx0w1 = d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_3_sva_mx0w1
      & (~ (FMAP_WIDTH_HWC_col_4_0_sva[3]));
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_3_sva_mx0w1 = d_buf_chan_rd_wr_buffer_case_1_if_and_stg_1_3_sva_1
      & (~ (FMAP_WIDTH_HWC_col_4_0_sva[2]));
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_4_sva_mx0w1 = d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_4_sva_mx0w1
      & (~ (FMAP_WIDTH_HWC_col_4_0_sva[3]));
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_4_sva_mx0w1 = d_buf_chan_rd_wr_buffer_case_1_if_and_stg_1_0_sva_1
      & (FMAP_WIDTH_HWC_col_4_0_sva[2]);
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_5_sva_mx0w1 = d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_5_sva_mx0w1
      & (~ (FMAP_WIDTH_HWC_col_4_0_sva[3]));
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_5_sva_mx0w1 = d_buf_chan_rd_wr_buffer_case_1_if_and_stg_1_1_sva_1
      & (FMAP_WIDTH_HWC_col_4_0_sva[2]);
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_6_sva_mx0w1 = d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_6_sva_mx0w1
      & (~ (FMAP_WIDTH_HWC_col_4_0_sva[3]));
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_6_sva_mx0w1 = d_buf_chan_rd_wr_buffer_case_1_if_and_stg_1_2_sva_1
      & (FMAP_WIDTH_HWC_col_4_0_sva[2]);
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_7_sva_mx0w1 = d_buf_chan_rd_wr_buffer_case_1_if_and_stg_1_3_sva_1
      & (FMAP_WIDTH_HWC_col_4_0_sva[2]);
  assign d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_7_sva_mx0w1 = d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_7_sva_mx0w1
      & (~ (FMAP_WIDTH_HWC_col_4_0_sva[3]));
  assign d_buf_chan_rd_wr_buffer_d_buf_chan_rd_wr_buffer_nand_nl = ~((d_buf_chan_d_bufPtr_lpi_3_dfm_mx0==2'b11));
  assign d_buf_chan_d_bufPtr_lpi_3_dfm_1_mx0w1 = MUX_v_2_2_2(2'b00, d_buf_chan_d_bufPtr_lpi_3_dfm_mx0,
      d_buf_chan_rd_wr_buffer_d_buf_chan_rd_wr_buffer_nand_nl);
  assign dinTmp_data_lpi_3_dfm_mx0 = MUX_v_32_2_2(dinTmp_data_lpi_2, din_rsci_idat_mxwt,
      IN_CHAN_HWC_EXTRA_if_slc_IN_CHAN_HWC_EXTRA_if_acc_2_svs_st);
  assign d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_7_0_sva_1
      = MUX_v_8_24_2(d_buf_chan_d_lineBuf1_data_0_7_0_lpi_2, d_buf_chan_d_lineBuf1_data_1_7_0_lpi_2,
      d_buf_chan_d_lineBuf1_data_2_7_0_lpi_2, d_buf_chan_d_lineBuf1_data_3_7_0_lpi_2,
      d_buf_chan_d_lineBuf1_data_4_7_0_lpi_2, d_buf_chan_d_lineBuf1_data_5_7_0_lpi_2,
      d_buf_chan_d_lineBuf1_data_6_7_0_lpi_2, d_buf_chan_d_lineBuf1_data_7_7_0_lpi_2,
      d_buf_chan_d_lineBuf1_data_8_7_0_lpi_2, d_buf_chan_d_lineBuf1_data_9_7_0_lpi_2,
      d_buf_chan_d_lineBuf1_data_10_7_0_lpi_2, d_buf_chan_d_lineBuf1_data_11_7_0_lpi_2,
      d_buf_chan_d_lineBuf1_data_12_7_0_lpi_2, d_buf_chan_d_lineBuf1_data_13_7_0_lpi_2,
      d_buf_chan_d_lineBuf1_data_14_7_0_lpi_2, d_buf_chan_d_lineBuf1_data_15_7_0_lpi_2,
      d_buf_chan_d_lineBuf1_data_16_7_0_lpi_2, d_buf_chan_d_lineBuf1_data_17_7_0_lpi_2,
      d_buf_chan_d_lineBuf1_data_18_7_0_lpi_2, d_buf_chan_d_lineBuf1_data_19_7_0_lpi_2,
      d_buf_chan_d_lineBuf1_data_20_7_0_lpi_2, d_buf_chan_d_lineBuf1_data_21_7_0_lpi_2,
      d_buf_chan_d_lineBuf1_data_22_7_0_lpi_2, d_buf_chan_d_lineBuf1_data_23_7_0_lpi_2,
      FMAP_WIDTH_HWC_col_4_0_sva);
  assign d_buf_chan_rd_wr_buffer_1_switch_lp_equal_tmp_1 = ~((d_buf_chan_d_bufPtr_lpi_3_dfm_1_mx0w1!=2'b00));
  assign d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_7_0_sva_1
      = MUX_v_8_24_2(d_buf_chan_d_lineBuf2_data_0_7_0_lpi_2, d_buf_chan_d_lineBuf2_data_1_7_0_lpi_2,
      d_buf_chan_d_lineBuf2_data_2_7_0_lpi_2, d_buf_chan_d_lineBuf2_data_3_7_0_lpi_2,
      d_buf_chan_d_lineBuf2_data_4_7_0_lpi_2, d_buf_chan_d_lineBuf2_data_5_7_0_lpi_2,
      d_buf_chan_d_lineBuf2_data_6_7_0_lpi_2, d_buf_chan_d_lineBuf2_data_7_7_0_lpi_2,
      d_buf_chan_d_lineBuf2_data_8_7_0_lpi_2, d_buf_chan_d_lineBuf2_data_9_7_0_lpi_2,
      d_buf_chan_d_lineBuf2_data_10_7_0_lpi_2, d_buf_chan_d_lineBuf2_data_11_7_0_lpi_2,
      d_buf_chan_d_lineBuf2_data_12_7_0_lpi_2, d_buf_chan_d_lineBuf2_data_13_7_0_lpi_2,
      d_buf_chan_d_lineBuf2_data_14_7_0_lpi_2, d_buf_chan_d_lineBuf2_data_15_7_0_lpi_2,
      d_buf_chan_d_lineBuf2_data_16_7_0_lpi_2, d_buf_chan_d_lineBuf2_data_17_7_0_lpi_2,
      d_buf_chan_d_lineBuf2_data_18_7_0_lpi_2, d_buf_chan_d_lineBuf2_data_19_7_0_lpi_2,
      d_buf_chan_d_lineBuf2_data_20_7_0_lpi_2, d_buf_chan_d_lineBuf2_data_21_7_0_lpi_2,
      d_buf_chan_d_lineBuf2_data_22_7_0_lpi_2, d_buf_chan_d_lineBuf2_data_23_7_0_lpi_2,
      FMAP_WIDTH_HWC_col_4_0_sva);
  assign d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_7_0_sva_1
      = MUX_v_8_24_2(d_buf_chan_d_lineBuf0_data_0_7_0_lpi_2, d_buf_chan_d_lineBuf0_data_1_7_0_lpi_2,
      d_buf_chan_d_lineBuf0_data_2_7_0_lpi_2, d_buf_chan_d_lineBuf0_data_3_7_0_lpi_2,
      d_buf_chan_d_lineBuf0_data_4_7_0_lpi_2, d_buf_chan_d_lineBuf0_data_5_7_0_lpi_2,
      d_buf_chan_d_lineBuf0_data_6_7_0_lpi_2, d_buf_chan_d_lineBuf0_data_7_7_0_lpi_2,
      d_buf_chan_d_lineBuf0_data_8_7_0_lpi_2, d_buf_chan_d_lineBuf0_data_9_7_0_lpi_2,
      d_buf_chan_d_lineBuf0_data_10_7_0_lpi_2, d_buf_chan_d_lineBuf0_data_11_7_0_lpi_2,
      d_buf_chan_d_lineBuf0_data_12_7_0_lpi_2, d_buf_chan_d_lineBuf0_data_13_7_0_lpi_2,
      d_buf_chan_d_lineBuf0_data_14_7_0_lpi_2, d_buf_chan_d_lineBuf0_data_15_7_0_lpi_2,
      d_buf_chan_d_lineBuf0_data_16_7_0_lpi_2, d_buf_chan_d_lineBuf0_data_17_7_0_lpi_2,
      d_buf_chan_d_lineBuf0_data_18_7_0_lpi_2, d_buf_chan_d_lineBuf0_data_19_7_0_lpi_2,
      d_buf_chan_d_lineBuf0_data_20_7_0_lpi_2, d_buf_chan_d_lineBuf0_data_21_7_0_lpi_2,
      d_buf_chan_d_lineBuf0_data_22_7_0_lpi_2, d_buf_chan_d_lineBuf0_data_23_7_0_lpi_2,
      FMAP_WIDTH_HWC_col_4_0_sva);
  assign d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_16_9_sva_1
      = MUX_v_8_24_2(d_buf_chan_d_lineBuf1_data_0_16_9_lpi_2, d_buf_chan_d_lineBuf1_data_1_16_9_lpi_2,
      d_buf_chan_d_lineBuf1_data_2_16_9_lpi_2, d_buf_chan_d_lineBuf1_data_3_16_9_lpi_2,
      d_buf_chan_d_lineBuf1_data_4_16_9_lpi_2, d_buf_chan_d_lineBuf1_data_5_16_9_lpi_2,
      d_buf_chan_d_lineBuf1_data_6_16_9_lpi_2, d_buf_chan_d_lineBuf1_data_7_16_9_lpi_2,
      d_buf_chan_d_lineBuf1_data_8_16_9_lpi_2, d_buf_chan_d_lineBuf1_data_9_16_9_lpi_2,
      d_buf_chan_d_lineBuf1_data_10_16_9_lpi_2, d_buf_chan_d_lineBuf1_data_11_16_9_lpi_2,
      d_buf_chan_d_lineBuf1_data_12_16_9_lpi_2, d_buf_chan_d_lineBuf1_data_13_16_9_lpi_2,
      d_buf_chan_d_lineBuf1_data_14_16_9_lpi_2, d_buf_chan_d_lineBuf1_data_15_16_9_lpi_2,
      d_buf_chan_d_lineBuf1_data_16_16_9_lpi_2, d_buf_chan_d_lineBuf1_data_17_16_9_lpi_2,
      d_buf_chan_d_lineBuf1_data_18_16_9_lpi_2, d_buf_chan_d_lineBuf1_data_19_16_9_lpi_2,
      d_buf_chan_d_lineBuf1_data_20_16_9_lpi_2, d_buf_chan_d_lineBuf1_data_21_16_9_lpi_2,
      d_buf_chan_d_lineBuf1_data_22_16_9_lpi_2, d_buf_chan_d_lineBuf1_data_23_16_9_lpi_2,
      FMAP_WIDTH_HWC_col_4_0_sva);
  assign d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_16_9_sva_1
      = MUX_v_8_24_2(d_buf_chan_d_lineBuf2_data_0_16_9_lpi_2, d_buf_chan_d_lineBuf2_data_1_16_9_lpi_2,
      d_buf_chan_d_lineBuf2_data_2_16_9_lpi_2, d_buf_chan_d_lineBuf2_data_3_16_9_lpi_2,
      d_buf_chan_d_lineBuf2_data_4_16_9_lpi_2, d_buf_chan_d_lineBuf2_data_5_16_9_lpi_2,
      d_buf_chan_d_lineBuf2_data_6_16_9_lpi_2, d_buf_chan_d_lineBuf2_data_7_16_9_lpi_2,
      d_buf_chan_d_lineBuf2_data_8_16_9_lpi_2, d_buf_chan_d_lineBuf2_data_9_16_9_lpi_2,
      d_buf_chan_d_lineBuf2_data_10_16_9_lpi_2, d_buf_chan_d_lineBuf2_data_11_16_9_lpi_2,
      d_buf_chan_d_lineBuf2_data_12_16_9_lpi_2, d_buf_chan_d_lineBuf2_data_13_16_9_lpi_2,
      d_buf_chan_d_lineBuf2_data_14_16_9_lpi_2, d_buf_chan_d_lineBuf2_data_15_16_9_lpi_2,
      d_buf_chan_d_lineBuf2_data_16_16_9_lpi_2, d_buf_chan_d_lineBuf2_data_17_16_9_lpi_2,
      d_buf_chan_d_lineBuf2_data_18_16_9_lpi_2, d_buf_chan_d_lineBuf2_data_19_16_9_lpi_2,
      d_buf_chan_d_lineBuf2_data_20_16_9_lpi_2, d_buf_chan_d_lineBuf2_data_21_16_9_lpi_2,
      d_buf_chan_d_lineBuf2_data_22_16_9_lpi_2, d_buf_chan_d_lineBuf2_data_23_16_9_lpi_2,
      FMAP_WIDTH_HWC_col_4_0_sva);
  assign d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_16_9_sva_1
      = MUX_v_8_24_2(d_buf_chan_d_lineBuf0_data_0_16_9_lpi_2, d_buf_chan_d_lineBuf0_data_1_16_9_lpi_2,
      d_buf_chan_d_lineBuf0_data_2_16_9_lpi_2, d_buf_chan_d_lineBuf0_data_3_16_9_lpi_2,
      d_buf_chan_d_lineBuf0_data_4_16_9_lpi_2, d_buf_chan_d_lineBuf0_data_5_16_9_lpi_2,
      d_buf_chan_d_lineBuf0_data_6_16_9_lpi_2, d_buf_chan_d_lineBuf0_data_7_16_9_lpi_2,
      d_buf_chan_d_lineBuf0_data_8_16_9_lpi_2, d_buf_chan_d_lineBuf0_data_9_16_9_lpi_2,
      d_buf_chan_d_lineBuf0_data_10_16_9_lpi_2, d_buf_chan_d_lineBuf0_data_11_16_9_lpi_2,
      d_buf_chan_d_lineBuf0_data_12_16_9_lpi_2, d_buf_chan_d_lineBuf0_data_13_16_9_lpi_2,
      d_buf_chan_d_lineBuf0_data_14_16_9_lpi_2, d_buf_chan_d_lineBuf0_data_15_16_9_lpi_2,
      d_buf_chan_d_lineBuf0_data_16_16_9_lpi_2, d_buf_chan_d_lineBuf0_data_17_16_9_lpi_2,
      d_buf_chan_d_lineBuf0_data_18_16_9_lpi_2, d_buf_chan_d_lineBuf0_data_19_16_9_lpi_2,
      d_buf_chan_d_lineBuf0_data_20_16_9_lpi_2, d_buf_chan_d_lineBuf0_data_21_16_9_lpi_2,
      d_buf_chan_d_lineBuf0_data_22_16_9_lpi_2, d_buf_chan_d_lineBuf0_data_23_16_9_lpi_2,
      FMAP_WIDTH_HWC_col_4_0_sva);
  assign d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_25_18_sva_1
      = MUX_v_8_24_2(d_buf_chan_d_lineBuf1_data_0_25_18_lpi_2, d_buf_chan_d_lineBuf1_data_1_25_18_lpi_2,
      d_buf_chan_d_lineBuf1_data_2_25_18_lpi_2, d_buf_chan_d_lineBuf1_data_3_25_18_lpi_2,
      d_buf_chan_d_lineBuf1_data_4_25_18_lpi_2, d_buf_chan_d_lineBuf1_data_5_25_18_lpi_2,
      d_buf_chan_d_lineBuf1_data_6_25_18_lpi_2, d_buf_chan_d_lineBuf1_data_7_25_18_lpi_2,
      d_buf_chan_d_lineBuf1_data_8_25_18_lpi_2, d_buf_chan_d_lineBuf1_data_9_25_18_lpi_2,
      d_buf_chan_d_lineBuf1_data_10_25_18_lpi_2, d_buf_chan_d_lineBuf1_data_11_25_18_lpi_2,
      d_buf_chan_d_lineBuf1_data_12_25_18_lpi_2, d_buf_chan_d_lineBuf1_data_13_25_18_lpi_2,
      d_buf_chan_d_lineBuf1_data_14_25_18_lpi_2, d_buf_chan_d_lineBuf1_data_15_25_18_lpi_2,
      d_buf_chan_d_lineBuf1_data_16_25_18_lpi_2, d_buf_chan_d_lineBuf1_data_17_25_18_lpi_2,
      d_buf_chan_d_lineBuf1_data_18_25_18_lpi_2, d_buf_chan_d_lineBuf1_data_19_25_18_lpi_2,
      d_buf_chan_d_lineBuf1_data_20_25_18_lpi_2, d_buf_chan_d_lineBuf1_data_21_25_18_lpi_2,
      d_buf_chan_d_lineBuf1_data_22_25_18_lpi_2, d_buf_chan_d_lineBuf1_data_23_25_18_lpi_2,
      FMAP_WIDTH_HWC_col_4_0_sva);
  assign d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_25_18_sva_1
      = MUX_v_8_24_2(d_buf_chan_d_lineBuf2_data_0_25_18_lpi_2, d_buf_chan_d_lineBuf2_data_1_25_18_lpi_2,
      d_buf_chan_d_lineBuf2_data_2_25_18_lpi_2, d_buf_chan_d_lineBuf2_data_3_25_18_lpi_2,
      d_buf_chan_d_lineBuf2_data_4_25_18_lpi_2, d_buf_chan_d_lineBuf2_data_5_25_18_lpi_2,
      d_buf_chan_d_lineBuf2_data_6_25_18_lpi_2, d_buf_chan_d_lineBuf2_data_7_25_18_lpi_2,
      d_buf_chan_d_lineBuf2_data_8_25_18_lpi_2, d_buf_chan_d_lineBuf2_data_9_25_18_lpi_2,
      d_buf_chan_d_lineBuf2_data_10_25_18_lpi_2, d_buf_chan_d_lineBuf2_data_11_25_18_lpi_2,
      d_buf_chan_d_lineBuf2_data_12_25_18_lpi_2, d_buf_chan_d_lineBuf2_data_13_25_18_lpi_2,
      d_buf_chan_d_lineBuf2_data_14_25_18_lpi_2, d_buf_chan_d_lineBuf2_data_15_25_18_lpi_2,
      d_buf_chan_d_lineBuf2_data_16_25_18_lpi_2, d_buf_chan_d_lineBuf2_data_17_25_18_lpi_2,
      d_buf_chan_d_lineBuf2_data_18_25_18_lpi_2, d_buf_chan_d_lineBuf2_data_19_25_18_lpi_2,
      d_buf_chan_d_lineBuf2_data_20_25_18_lpi_2, d_buf_chan_d_lineBuf2_data_21_25_18_lpi_2,
      d_buf_chan_d_lineBuf2_data_22_25_18_lpi_2, d_buf_chan_d_lineBuf2_data_23_25_18_lpi_2,
      FMAP_WIDTH_HWC_col_4_0_sva);
  assign d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_25_18_sva_1
      = MUX_v_8_24_2(d_buf_chan_d_lineBuf0_data_0_25_18_lpi_2, d_buf_chan_d_lineBuf0_data_1_25_18_lpi_2,
      d_buf_chan_d_lineBuf0_data_2_25_18_lpi_2, d_buf_chan_d_lineBuf0_data_3_25_18_lpi_2,
      d_buf_chan_d_lineBuf0_data_4_25_18_lpi_2, d_buf_chan_d_lineBuf0_data_5_25_18_lpi_2,
      d_buf_chan_d_lineBuf0_data_6_25_18_lpi_2, d_buf_chan_d_lineBuf0_data_7_25_18_lpi_2,
      d_buf_chan_d_lineBuf0_data_8_25_18_lpi_2, d_buf_chan_d_lineBuf0_data_9_25_18_lpi_2,
      d_buf_chan_d_lineBuf0_data_10_25_18_lpi_2, d_buf_chan_d_lineBuf0_data_11_25_18_lpi_2,
      d_buf_chan_d_lineBuf0_data_12_25_18_lpi_2, d_buf_chan_d_lineBuf0_data_13_25_18_lpi_2,
      d_buf_chan_d_lineBuf0_data_14_25_18_lpi_2, d_buf_chan_d_lineBuf0_data_15_25_18_lpi_2,
      d_buf_chan_d_lineBuf0_data_16_25_18_lpi_2, d_buf_chan_d_lineBuf0_data_17_25_18_lpi_2,
      d_buf_chan_d_lineBuf0_data_18_25_18_lpi_2, d_buf_chan_d_lineBuf0_data_19_25_18_lpi_2,
      d_buf_chan_d_lineBuf0_data_20_25_18_lpi_2, d_buf_chan_d_lineBuf0_data_21_25_18_lpi_2,
      d_buf_chan_d_lineBuf0_data_22_25_18_lpi_2, d_buf_chan_d_lineBuf0_data_23_25_18_lpi_2,
      FMAP_WIDTH_HWC_col_4_0_sva);
  assign d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_34_27_sva_1
      = MUX_v_8_24_2(d_buf_chan_d_lineBuf1_data_0_34_27_lpi_2, d_buf_chan_d_lineBuf1_data_1_34_27_lpi_2,
      d_buf_chan_d_lineBuf1_data_2_34_27_lpi_2, d_buf_chan_d_lineBuf1_data_3_34_27_lpi_2,
      d_buf_chan_d_lineBuf1_data_4_34_27_lpi_2, d_buf_chan_d_lineBuf1_data_5_34_27_lpi_2,
      d_buf_chan_d_lineBuf1_data_6_34_27_lpi_2, d_buf_chan_d_lineBuf1_data_7_34_27_lpi_2,
      d_buf_chan_d_lineBuf1_data_8_34_27_lpi_2, d_buf_chan_d_lineBuf1_data_9_34_27_lpi_2,
      d_buf_chan_d_lineBuf1_data_10_34_27_lpi_2, d_buf_chan_d_lineBuf1_data_11_34_27_lpi_2,
      d_buf_chan_d_lineBuf1_data_12_34_27_lpi_2, d_buf_chan_d_lineBuf1_data_13_34_27_lpi_2,
      d_buf_chan_d_lineBuf1_data_14_34_27_lpi_2, d_buf_chan_d_lineBuf1_data_15_34_27_lpi_2,
      d_buf_chan_d_lineBuf1_data_16_34_27_lpi_2, d_buf_chan_d_lineBuf1_data_17_34_27_lpi_2,
      d_buf_chan_d_lineBuf1_data_18_34_27_lpi_2, d_buf_chan_d_lineBuf1_data_19_34_27_lpi_2,
      d_buf_chan_d_lineBuf1_data_20_34_27_lpi_2, d_buf_chan_d_lineBuf1_data_21_34_27_lpi_2,
      d_buf_chan_d_lineBuf1_data_22_34_27_lpi_2, d_buf_chan_d_lineBuf1_data_23_34_27_lpi_2,
      FMAP_WIDTH_HWC_col_4_0_sva);
  assign d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_34_27_sva_1
      = MUX_v_8_24_2(d_buf_chan_d_lineBuf2_data_0_34_27_lpi_2, d_buf_chan_d_lineBuf2_data_1_34_27_lpi_2,
      d_buf_chan_d_lineBuf2_data_2_34_27_lpi_2, d_buf_chan_d_lineBuf2_data_3_34_27_lpi_2,
      d_buf_chan_d_lineBuf2_data_4_34_27_lpi_2, d_buf_chan_d_lineBuf2_data_5_34_27_lpi_2,
      d_buf_chan_d_lineBuf2_data_6_34_27_lpi_2, d_buf_chan_d_lineBuf2_data_7_34_27_lpi_2,
      d_buf_chan_d_lineBuf2_data_8_34_27_lpi_2, d_buf_chan_d_lineBuf2_data_9_34_27_lpi_2,
      d_buf_chan_d_lineBuf2_data_10_34_27_lpi_2, d_buf_chan_d_lineBuf2_data_11_34_27_lpi_2,
      d_buf_chan_d_lineBuf2_data_12_34_27_lpi_2, d_buf_chan_d_lineBuf2_data_13_34_27_lpi_2,
      d_buf_chan_d_lineBuf2_data_14_34_27_lpi_2, d_buf_chan_d_lineBuf2_data_15_34_27_lpi_2,
      d_buf_chan_d_lineBuf2_data_16_34_27_lpi_2, d_buf_chan_d_lineBuf2_data_17_34_27_lpi_2,
      d_buf_chan_d_lineBuf2_data_18_34_27_lpi_2, d_buf_chan_d_lineBuf2_data_19_34_27_lpi_2,
      d_buf_chan_d_lineBuf2_data_20_34_27_lpi_2, d_buf_chan_d_lineBuf2_data_21_34_27_lpi_2,
      d_buf_chan_d_lineBuf2_data_22_34_27_lpi_2, d_buf_chan_d_lineBuf2_data_23_34_27_lpi_2,
      FMAP_WIDTH_HWC_col_4_0_sva);
  assign d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_34_27_sva_1
      = MUX_v_8_24_2(d_buf_chan_d_lineBuf0_data_0_34_27_lpi_2, d_buf_chan_d_lineBuf0_data_1_34_27_lpi_2,
      d_buf_chan_d_lineBuf0_data_2_34_27_lpi_2, d_buf_chan_d_lineBuf0_data_3_34_27_lpi_2,
      d_buf_chan_d_lineBuf0_data_4_34_27_lpi_2, d_buf_chan_d_lineBuf0_data_5_34_27_lpi_2,
      d_buf_chan_d_lineBuf0_data_6_34_27_lpi_2, d_buf_chan_d_lineBuf0_data_7_34_27_lpi_2,
      d_buf_chan_d_lineBuf0_data_8_34_27_lpi_2, d_buf_chan_d_lineBuf0_data_9_34_27_lpi_2,
      d_buf_chan_d_lineBuf0_data_10_34_27_lpi_2, d_buf_chan_d_lineBuf0_data_11_34_27_lpi_2,
      d_buf_chan_d_lineBuf0_data_12_34_27_lpi_2, d_buf_chan_d_lineBuf0_data_13_34_27_lpi_2,
      d_buf_chan_d_lineBuf0_data_14_34_27_lpi_2, d_buf_chan_d_lineBuf0_data_15_34_27_lpi_2,
      d_buf_chan_d_lineBuf0_data_16_34_27_lpi_2, d_buf_chan_d_lineBuf0_data_17_34_27_lpi_2,
      d_buf_chan_d_lineBuf0_data_18_34_27_lpi_2, d_buf_chan_d_lineBuf0_data_19_34_27_lpi_2,
      d_buf_chan_d_lineBuf0_data_20_34_27_lpi_2, d_buf_chan_d_lineBuf0_data_21_34_27_lpi_2,
      d_buf_chan_d_lineBuf0_data_22_34_27_lpi_2, d_buf_chan_d_lineBuf0_data_23_34_27_lpi_2,
      FMAP_WIDTH_HWC_col_4_0_sva);
  assign nl_IN_CHAN_HWC_EXTRA_if_acc_nl = ({1'b1 , (FMAP_HEIGHT_HWC_row_4_0_sva[4:3])})
      + 3'b001;
  assign IN_CHAN_HWC_EXTRA_if_acc_nl = nl_IN_CHAN_HWC_EXTRA_if_acc_nl[2:0];
  assign IN_CHAN_HWC_EXTRA_if_acc_itm_2_1 = readslicef_3_1_2(IN_CHAN_HWC_EXTRA_if_acc_nl);
  assign nl_d_buf_chan_rd_wr_buffer_if_acc_nl = 2'b01 + d_buf_chan_d_bufPtr_lpi_3;
  assign d_buf_chan_rd_wr_buffer_if_acc_nl = nl_d_buf_chan_rd_wr_buffer_if_acc_nl[1:0];
  assign and_796_nl = and_dcpl_36 & (~ (FMAP_WIDTH_HWC_col_4_0_sva[1])) & (~((FMAP_WIDTH_HWC_col_4_0_sva[2])
      | (FMAP_WIDTH_HWC_col_4_0_sva[4])));
  assign d_buf_chan_d_bufPtr_lpi_3_dfm_mx0 = MUX_v_2_2_2(d_buf_chan_d_bufPtr_lpi_3,
      d_buf_chan_rd_wr_buffer_if_acc_nl, and_796_nl);
  assign bounds_apply_bounds_else_else_else_if_switch_lp_exs_5_0 = ~(lower_1_0_sva
      & (~(lower_1_1_sva | lower_1_0_sva_1)));
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_1_0_sva_1 = ~((FMAP_WIDTH_HWC_col_4_0_sva[1:0]!=2'b00));
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_1_1_sva_1 = (FMAP_WIDTH_HWC_col_4_0_sva[1:0]==2'b01);
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_1_2_sva_1 = (FMAP_WIDTH_HWC_col_4_0_sva[1:0]==2'b10);
  assign d_buf_chan_rd_wr_buffer_case_1_if_and_stg_1_3_sva_1 = (FMAP_WIDTH_HWC_col_4_0_sva[1:0]==2'b11);
  assign bounds_apply_bounds_else_else_else_if_switch_lp_1_exs_5_0 = ~(upper_1_0_sva
      & (~ upper_1_0_sva_1));
  assign and_dcpl_6 = ~((d_buf_chan_d_bufPtr_lpi_2!=2'b00));
  assign and_dcpl_9 = and_dcpl_6 & (~ (FMAP_WIDTH_HWC_col_4_0_sva[4]));
  assign and_dcpl_10 = (FMAP_WIDTH_HWC_col_4_0_sva[2:1]==2'b01);
  assign and_dcpl_11 = (FMAP_WIDTH_HWC_col_4_0_sva[3]) & (FMAP_WIDTH_HWC_col_4_0_sva[0]);
  assign and_dcpl_14 = (FMAP_WIDTH_HWC_col_4_0_sva[2:1]==2'b10);
  assign and_dcpl_15 = (FMAP_WIDTH_HWC_col_4_0_sva[3]) & (~ (FMAP_WIDTH_HWC_col_4_0_sva[0]));
  assign and_dcpl_22 = ~((FMAP_WIDTH_HWC_col_4_0_sva[2:1]!=2'b00));
  assign and_dcpl_25 = (FMAP_WIDTH_HWC_col_4_0_sva[2:1]==2'b11);
  assign and_dcpl_32 = (~ (FMAP_WIDTH_HWC_col_4_0_sva[3])) & (FMAP_WIDTH_HWC_col_4_0_sva[0]);
  assign and_dcpl_33 = and_dcpl_32 & and_dcpl_25;
  assign and_dcpl_35 = and_dcpl_6 & (FMAP_WIDTH_HWC_col_4_0_sva[4]);
  assign and_dcpl_36 = ~((FMAP_WIDTH_HWC_col_4_0_sva[3]) | (FMAP_WIDTH_HWC_col_4_0_sva[0]));
  assign and_dcpl_37 = and_dcpl_36 & and_dcpl_22;
  assign and_dcpl_39 = and_dcpl_36 & and_dcpl_25;
  assign and_dcpl_41 = and_dcpl_32 & and_dcpl_22;
  assign and_dcpl_43 = and_dcpl_32 & and_dcpl_14;
  assign and_dcpl_45 = and_dcpl_36 & and_dcpl_10;
  assign and_dcpl_47 = and_dcpl_36 & and_dcpl_14;
  assign and_dcpl_49 = and_dcpl_32 & and_dcpl_10;
  assign and_dcpl_60 = (FMAP_WIDTH_HWC_col_4_0_sva[3]) & (d_buf_chan_d_bufPtr_lpi_2[0])
      & (~ (FMAP_WIDTH_HWC_col_4_0_sva[4]));
  assign not_tmp_24 = ~((FMAP_WIDTH_HWC_col_4_0_sva[1:0]==2'b11));
  assign not_tmp_25 = ~((FMAP_WIDTH_HWC_col_4_0_sva[2]) | not_tmp_24);
  assign not_tmp_26 = ~((FMAP_WIDTH_HWC_col_4_0_sva[2:0]!=3'b100));
  assign not_tmp_27 = ~((FMAP_WIDTH_HWC_col_4_0_sva[2:0]!=3'b010));
  assign not_tmp_28 = ~((FMAP_WIDTH_HWC_col_4_0_sva[2:0]!=3'b101));
  assign not_tmp_29 = ~((FMAP_WIDTH_HWC_col_4_0_sva[2:0]!=3'b001));
  assign not_tmp_30 = ~((FMAP_WIDTH_HWC_col_4_0_sva[2:0]!=3'b110));
  assign not_tmp_31 = ~((FMAP_WIDTH_HWC_col_4_0_sva[2:0]!=3'b000));
  assign nor_tmp_1 = (FMAP_WIDTH_HWC_col_4_0_sva[2:0]==3'b111);
  assign and_dcpl_69 = (d_buf_chan_d_bufPtr_lpi_2[0]) & (~ (FMAP_WIDTH_HWC_col_4_0_sva[4]));
  assign mux_tmp_8 = MUX_s_1_2_2(and_dcpl_33, d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_7_sva,
      d_buf_chan_d_bufPtr_lpi_2[1]);
  assign and_dcpl_71 = (d_buf_chan_d_bufPtr_lpi_2[0]) & (FMAP_WIDTH_HWC_col_4_0_sva[4]);
  assign mux_tmp_9 = MUX_s_1_2_2(and_dcpl_37, d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_0_sva,
      d_buf_chan_d_bufPtr_lpi_2[1]);
  assign mux_tmp_10 = MUX_s_1_2_2(and_dcpl_39, d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_6_sva,
      d_buf_chan_d_bufPtr_lpi_2[1]);
  assign mux_tmp_11 = MUX_s_1_2_2(and_dcpl_41, d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_1_sva,
      d_buf_chan_d_bufPtr_lpi_2[1]);
  assign mux_tmp_12 = MUX_s_1_2_2(and_dcpl_43, d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_5_sva,
      d_buf_chan_d_bufPtr_lpi_2[1]);
  assign mux_tmp_13 = MUX_s_1_2_2(and_dcpl_45, d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_2_sva,
      d_buf_chan_d_bufPtr_lpi_2[1]);
  assign mux_tmp_14 = MUX_s_1_2_2(and_dcpl_47, d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_4_sva,
      d_buf_chan_d_bufPtr_lpi_2[1]);
  assign mux_tmp_15 = MUX_s_1_2_2(and_dcpl_49, d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_3_sva,
      d_buf_chan_d_bufPtr_lpi_2[1]);
  assign and_dcpl_88 = (FMAP_WIDTH_HWC_col_4_0_sva[3]) & (d_buf_chan_d_bufPtr_lpi_2[1])
      & (~ (FMAP_WIDTH_HWC_col_4_0_sva[4]));
  assign and_dcpl_97 = (d_buf_chan_d_bufPtr_lpi_2[1]) & (~ (FMAP_WIDTH_HWC_col_4_0_sva[4]));
  assign nor_12_nl = ~((d_buf_chan_d_bufPtr_lpi_2[0]) | (FMAP_WIDTH_HWC_col_4_0_sva[3:0]!=4'b0111));
  assign or_488_nl = (d_buf_chan_d_bufPtr_lpi_2[0]) | and_dcpl_33;
  assign mux_tmp_24 = MUX_s_1_2_2(nor_12_nl, or_488_nl, d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_7_sva);
  assign and_dcpl_99 = (d_buf_chan_d_bufPtr_lpi_2[1]) & (FMAP_WIDTH_HWC_col_4_0_sva[4]);
  assign nor_13_nl = ~((d_buf_chan_d_bufPtr_lpi_2[0]) | (FMAP_WIDTH_HWC_col_4_0_sva[3:0]!=4'b0000));
  assign or_490_nl = (d_buf_chan_d_bufPtr_lpi_2[0]) | and_dcpl_37;
  assign mux_tmp_25 = MUX_s_1_2_2(nor_13_nl, or_490_nl, d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_0_sva);
  assign nor_14_nl = ~((d_buf_chan_d_bufPtr_lpi_2[0]) | (FMAP_WIDTH_HWC_col_4_0_sva[3:0]!=4'b0110));
  assign or_492_nl = (d_buf_chan_d_bufPtr_lpi_2[0]) | and_dcpl_39;
  assign mux_tmp_26 = MUX_s_1_2_2(nor_14_nl, or_492_nl, d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_6_sva);
  assign nor_15_nl = ~((d_buf_chan_d_bufPtr_lpi_2[0]) | (FMAP_WIDTH_HWC_col_4_0_sva[3:0]!=4'b0001));
  assign or_494_nl = (d_buf_chan_d_bufPtr_lpi_2[0]) | and_dcpl_41;
  assign mux_tmp_27 = MUX_s_1_2_2(nor_15_nl, or_494_nl, d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_1_sva);
  assign nor_16_nl = ~((d_buf_chan_d_bufPtr_lpi_2[0]) | (FMAP_WIDTH_HWC_col_4_0_sva[3:0]!=4'b0101));
  assign or_496_nl = (d_buf_chan_d_bufPtr_lpi_2[0]) | and_dcpl_43;
  assign mux_tmp_28 = MUX_s_1_2_2(nor_16_nl, or_496_nl, d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_5_sva);
  assign nor_17_nl = ~((d_buf_chan_d_bufPtr_lpi_2[0]) | (FMAP_WIDTH_HWC_col_4_0_sva[3:0]!=4'b0010));
  assign or_498_nl = (d_buf_chan_d_bufPtr_lpi_2[0]) | and_dcpl_45;
  assign mux_tmp_29 = MUX_s_1_2_2(nor_17_nl, or_498_nl, d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_2_sva);
  assign nor_18_nl = ~((d_buf_chan_d_bufPtr_lpi_2[0]) | (FMAP_WIDTH_HWC_col_4_0_sva[3:0]!=4'b0100));
  assign or_500_nl = (d_buf_chan_d_bufPtr_lpi_2[0]) | and_dcpl_47;
  assign mux_tmp_30 = MUX_s_1_2_2(nor_18_nl, or_500_nl, d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_4_sva);
  assign nor_19_nl = ~((d_buf_chan_d_bufPtr_lpi_2[0]) | (FMAP_WIDTH_HWC_col_4_0_sva[3:0]!=4'b0011));
  assign or_502_nl = (d_buf_chan_d_bufPtr_lpi_2[0]) | and_dcpl_49;
  assign mux_tmp_31 = MUX_s_1_2_2(nor_19_nl, or_502_nl, d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_3_sva);
  always @(posedge clk) begin
    if ( rst ) begin
      lower_1_0_sva <= 1'b0;
      FMAP_HEIGHT_HWC_row_4_0_sva <= 5'b00000;
    end
    else if ( lower_and_cse ) begin
      lower_1_0_sva <= lower_1_0_sva_1 & (~ (fsm_output[0]));
      FMAP_HEIGHT_HWC_row_4_0_sva <= MUX_v_5_2_2(5'b00000, z_out, (fsm_output[5]));
    end
  end
  always @(posedge clk) begin
    if ( run_wen ) begin
      d_buf_chan_d_bufPtr_lpi_3 <= d_buf_chan_d_bufPtr_lpi_2;
      bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_3_itm
          <= MUX_v_8_2_2(8'b00000000, d_buf_chan_rd_wr_buffer_1_switch_lp_mux1h_7_nl,
          bounds_apply_bounds_else_else_else_if_switch_lp_exs_5_0);
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_7_0_sva
          <= d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_7_0_sva_1;
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_7_0_sva
          <= d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_7_0_sva_1;
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_7_0_sva
          <= d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_7_0_sva_1;
      bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_2_itm
          <= MUX_v_8_2_2(8'b00000000, d_buf_chan_rd_wr_buffer_1_switch_lp_mux1h_6_nl,
          bounds_apply_bounds_else_else_else_if_switch_lp_exs_5_0);
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_16_9_sva
          <= d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_16_9_sva_1;
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_16_9_sva
          <= d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_16_9_sva_1;
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_16_9_sva
          <= d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_16_9_sva_1;
      bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_1_itm
          <= MUX_v_8_2_2(8'b00000000, d_buf_chan_rd_wr_buffer_1_switch_lp_mux1h_5_nl,
          bounds_apply_bounds_else_else_else_if_switch_lp_exs_5_0);
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_25_18_sva
          <= d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_25_18_sva_1;
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_25_18_sva
          <= d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_25_18_sva_1;
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_25_18_sva
          <= d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_25_18_sva_1;
      bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_itm
          <= MUX_v_8_2_2(8'b00000000, d_buf_chan_rd_wr_buffer_1_switch_lp_mux1h_4_nl,
          bounds_apply_bounds_else_else_else_if_switch_lp_exs_5_0);
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_34_27_sva
          <= d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_34_27_sva_1;
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_34_27_sva
          <= d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_34_27_sva_1;
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_34_27_sva
          <= d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_34_27_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      lower_1_1_sva <= 1'b0;
      upper_1_0_sva <= 1'b0;
      d_buf_chan_d_bufPtr_sva <= 2'b10;
      d_buf_chan_rd_wr_buffer_1_switch_lp_equal_tmp <= 1'b0;
      operator_3_false_slc_operator_3_false_acc_5_svs_st <= 1'b0;
      IN_CHAN_HWC_EXTRA_if_slc_IN_CHAN_HWC_EXTRA_if_acc_2_svs_st <= 1'b0;
    end
    else if ( run_wen ) begin
      lower_1_1_sva <= FMAP_HEIGHT_HWC_mux_2_nl & (~ (fsm_output[0]));
      upper_1_0_sva <= FMAP_HEIGHT_HWC_mux_3_nl & (~ (fsm_output[0]));
      d_buf_chan_d_bufPtr_sva <= d_buf_chan_d_bufPtr_lpi_2;
      d_buf_chan_rd_wr_buffer_1_switch_lp_equal_tmp <= d_buf_chan_rd_wr_buffer_1_switch_lp_equal_tmp_1;
      operator_3_false_slc_operator_3_false_acc_5_svs_st <= (FMAP_HEIGHT_HWC_row_4_0_sva)
          < 1'b1;
      IN_CHAN_HWC_EXTRA_if_slc_IN_CHAN_HWC_EXTRA_if_acc_2_svs_st <= IN_CHAN_HWC_EXTRA_if_acc_itm_2_1;
    end
  end
  always @(posedge clk) begin
    if ( IN_CHAN_HWC_if_and_cse ) begin
      dout_rsci_idat_7_0 <= bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_3_itm;
      dout_rsci_idat_106_99 <= MUX_v_8_2_2(8'b00000000, (dinTmp_data_lpi_3_dfm_mx0[31:24]),
          bounds_apply_bounds_else_else_else_if_switch_lp_1_exs_5_0);
      dout_rsci_idat_16_9 <= bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_2_itm;
      dout_rsci_idat_97_90 <= MUX_v_8_2_2(8'b00000000, (dinTmp_data_lpi_3_dfm_mx0[23:16]),
          bounds_apply_bounds_else_else_else_if_switch_lp_1_exs_5_0);
      dout_rsci_idat_25_18 <= bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_1_itm;
      dout_rsci_idat_88_81 <= MUX_v_8_2_2(8'b00000000, (dinTmp_data_lpi_3_dfm_mx0[15:8]),
          bounds_apply_bounds_else_else_else_if_switch_lp_1_exs_5_0);
      dout_rsci_idat_34_27 <= bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_itm;
      dout_rsci_idat_79_72 <= MUX_v_8_2_2(8'b00000000, (dinTmp_data_lpi_3_dfm_mx0[7:0]),
          bounds_apply_bounds_else_else_else_if_switch_lp_1_exs_5_0);
      dout_rsci_idat_43_36 <= MUX1HOT_v_8_3_2(d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_7_0_sva,
          d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_7_0_sva,
          d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_7_0_sva,
          {d_buf_chan_rd_wr_buffer_1_switch_lp_equal_tmp , (d_buf_chan_d_bufPtr_lpi_2[0])
          , (d_buf_chan_d_bufPtr_lpi_2[1])});
      dout_rsci_idat_70_63 <= MUX1HOT_v_8_3_2(d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_34_27_sva,
          d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_34_27_sva,
          d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_34_27_sva,
          {d_buf_chan_rd_wr_buffer_1_switch_lp_equal_tmp , (d_buf_chan_d_bufPtr_lpi_2[0])
          , (d_buf_chan_d_bufPtr_lpi_2[1])});
      dout_rsci_idat_52_45 <= MUX1HOT_v_8_3_2(d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_16_9_sva,
          d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_16_9_sva,
          d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_16_9_sva,
          {d_buf_chan_rd_wr_buffer_1_switch_lp_equal_tmp , (d_buf_chan_d_bufPtr_lpi_2[0])
          , (d_buf_chan_d_bufPtr_lpi_2[1])});
      dout_rsci_idat_61_54 <= MUX1HOT_v_8_3_2(d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_25_18_sva,
          d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_25_18_sva,
          d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_25_18_sva,
          {d_buf_chan_rd_wr_buffer_1_switch_lp_equal_tmp , (d_buf_chan_d_bufPtr_lpi_2[0])
          , (d_buf_chan_d_bufPtr_lpi_2[1])});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_0_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_0_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_1_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_1_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_2_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_2_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_3_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_3_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_4_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_4_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_5_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_5_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_6_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_6_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_7_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_7_sva <= 1'b0;
    end
    else if ( d_buf_chan_rd_wr_buffer_case_1_if_and_20_cse ) begin
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_0_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_0_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_0_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_0_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_1_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_1_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_1_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_1_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_2_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_2_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_2_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_2_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_3_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_3_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_3_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_3_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_4_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_4_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_4_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_4_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_5_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_5_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_5_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_5_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_6_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_6_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_6_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_6_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_7_sva <= d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_7_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_7_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_7_sva_mx0w1;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_0_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_0_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_1_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_1_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_2_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_2_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_3_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_3_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_4_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_4_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_5_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_5_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_6_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_6_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_7_sva <= 1'b0;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_7_sva <= 1'b0;
    end
    else if ( d_buf_chan_rd_wr_buffer_case_2_if_and_cse ) begin
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_0_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_0_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_0_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_0_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_1_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_1_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_1_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_1_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_2_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_2_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_2_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_2_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_3_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_3_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_3_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_3_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_4_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_4_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_4_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_4_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_5_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_5_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_5_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_5_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_6_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_3_6_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_6_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_6_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_7_sva <= d_buf_chan_rd_wr_buffer_case_2_if_and_stg_3_7_sva_mx0w1;
      d_buf_chan_rd_wr_buffer_case_2_if_and_stg_2_7_sva <= d_buf_chan_rd_wr_buffer_case_1_if_and_stg_2_7_sva_mx0w1;
    end
  end
  always @(posedge clk) begin
    if ( run_wen & IN_CHAN_HWC_EXTRA_if_slc_IN_CHAN_HWC_EXTRA_if_acc_2_svs_st & (fsm_output[3])
        ) begin
      dinTmp_data_lpi_2 <= din_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      d_buf_chan_d_bufPtr_lpi_2 <= 2'b00;
    end
    else if ( run_wen & (fsm_output[5:3]==3'b000) ) begin
      d_buf_chan_d_bufPtr_lpi_2 <= MUX_v_2_2_2(d_buf_chan_d_bufPtr_sva, d_buf_chan_d_bufPtr_lpi_3_dfm_1_mx0w1,
          fsm_output[2]);
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_cse ) begin
      d_buf_chan_d_lineBuf0_data_11_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_11_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_11_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_11_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_4_cse ) begin
      d_buf_chan_d_lineBuf0_data_12_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_12_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_12_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_12_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_8_cse ) begin
      d_buf_chan_d_lineBuf0_data_10_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_10_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_10_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_10_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_12_cse ) begin
      d_buf_chan_d_lineBuf0_data_13_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_13_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_13_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_13_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_16_cse ) begin
      d_buf_chan_d_lineBuf0_data_9_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_9_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_9_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_9_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_20_cse ) begin
      d_buf_chan_d_lineBuf0_data_14_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_14_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_14_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_14_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_24_cse ) begin
      d_buf_chan_d_lineBuf0_data_8_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_8_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_8_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_8_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_28_cse ) begin
      d_buf_chan_d_lineBuf0_data_15_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_15_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_15_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_15_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_32_cse ) begin
      d_buf_chan_d_lineBuf0_data_7_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_7_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_7_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_7_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_36_cse ) begin
      d_buf_chan_d_lineBuf0_data_16_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_16_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_16_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_16_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_40_cse ) begin
      d_buf_chan_d_lineBuf0_data_6_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_6_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_6_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_6_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_44_cse ) begin
      d_buf_chan_d_lineBuf0_data_17_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_17_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_17_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_17_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_48_cse ) begin
      d_buf_chan_d_lineBuf0_data_5_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_5_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_5_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_5_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_52_cse ) begin
      d_buf_chan_d_lineBuf0_data_18_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_18_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_18_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_18_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_56_cse ) begin
      d_buf_chan_d_lineBuf0_data_4_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_4_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_4_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_4_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_60_cse ) begin
      d_buf_chan_d_lineBuf0_data_19_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_19_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_19_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_19_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_64_cse ) begin
      d_buf_chan_d_lineBuf0_data_3_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_3_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_3_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_3_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_68_cse ) begin
      d_buf_chan_d_lineBuf0_data_20_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_20_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_20_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_20_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_72_cse ) begin
      d_buf_chan_d_lineBuf0_data_2_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_2_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_2_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_2_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_76_cse ) begin
      d_buf_chan_d_lineBuf0_data_21_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_21_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_21_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_21_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_80_cse ) begin
      d_buf_chan_d_lineBuf0_data_1_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_1_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_1_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_1_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_84_cse ) begin
      d_buf_chan_d_lineBuf0_data_22_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_22_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_22_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_22_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_88_cse ) begin
      d_buf_chan_d_lineBuf0_data_0_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_0_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_0_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_0_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf0_data_and_92_cse ) begin
      d_buf_chan_d_lineBuf0_data_23_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf0_data_23_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf0_data_23_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf0_data_23_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_cse ) begin
      d_buf_chan_d_lineBuf1_data_11_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_11_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_11_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_11_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_4_cse ) begin
      d_buf_chan_d_lineBuf1_data_12_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_12_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_12_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_12_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_8_cse ) begin
      d_buf_chan_d_lineBuf1_data_10_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_10_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_10_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_10_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_12_cse ) begin
      d_buf_chan_d_lineBuf1_data_13_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_13_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_13_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_13_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_16_cse ) begin
      d_buf_chan_d_lineBuf1_data_9_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_9_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_9_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_9_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_20_cse ) begin
      d_buf_chan_d_lineBuf1_data_14_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_14_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_14_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_14_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_24_cse ) begin
      d_buf_chan_d_lineBuf1_data_8_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_8_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_8_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_8_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_28_cse ) begin
      d_buf_chan_d_lineBuf1_data_15_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_15_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_15_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_15_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_32_cse ) begin
      d_buf_chan_d_lineBuf1_data_7_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_7_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_7_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_7_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_36_cse ) begin
      d_buf_chan_d_lineBuf1_data_16_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_16_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_16_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_16_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_40_cse ) begin
      d_buf_chan_d_lineBuf1_data_6_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_6_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_6_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_6_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_44_cse ) begin
      d_buf_chan_d_lineBuf1_data_17_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_17_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_17_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_17_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_48_cse ) begin
      d_buf_chan_d_lineBuf1_data_5_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_5_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_5_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_5_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_52_cse ) begin
      d_buf_chan_d_lineBuf1_data_18_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_18_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_18_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_18_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_56_cse ) begin
      d_buf_chan_d_lineBuf1_data_4_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_4_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_4_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_4_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_60_cse ) begin
      d_buf_chan_d_lineBuf1_data_19_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_19_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_19_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_19_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_64_cse ) begin
      d_buf_chan_d_lineBuf1_data_3_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_3_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_3_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_3_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_68_cse ) begin
      d_buf_chan_d_lineBuf1_data_20_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_20_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_20_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_20_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_72_cse ) begin
      d_buf_chan_d_lineBuf1_data_2_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_2_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_2_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_2_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_76_cse ) begin
      d_buf_chan_d_lineBuf1_data_21_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_21_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_21_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_21_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_80_cse ) begin
      d_buf_chan_d_lineBuf1_data_1_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_1_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_1_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_1_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_84_cse ) begin
      d_buf_chan_d_lineBuf1_data_22_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_22_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_22_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_22_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_88_cse ) begin
      d_buf_chan_d_lineBuf1_data_0_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_0_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_0_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_0_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf1_data_and_92_cse ) begin
      d_buf_chan_d_lineBuf1_data_23_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf1_data_23_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf1_data_23_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf1_data_23_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_cse ) begin
      d_buf_chan_d_lineBuf2_data_11_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_11_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_11_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_11_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_4_cse ) begin
      d_buf_chan_d_lineBuf2_data_12_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_12_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_12_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_12_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_8_cse ) begin
      d_buf_chan_d_lineBuf2_data_10_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_10_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_10_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_10_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_12_cse ) begin
      d_buf_chan_d_lineBuf2_data_13_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_13_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_13_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_13_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_16_cse ) begin
      d_buf_chan_d_lineBuf2_data_9_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_9_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_9_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_9_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_20_cse ) begin
      d_buf_chan_d_lineBuf2_data_14_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_14_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_14_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_14_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_24_cse ) begin
      d_buf_chan_d_lineBuf2_data_8_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_8_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_8_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_8_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_28_cse ) begin
      d_buf_chan_d_lineBuf2_data_15_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_15_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_15_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_15_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_32_cse ) begin
      d_buf_chan_d_lineBuf2_data_7_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_7_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_7_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_7_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_36_cse ) begin
      d_buf_chan_d_lineBuf2_data_16_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_16_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_16_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_16_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_40_cse ) begin
      d_buf_chan_d_lineBuf2_data_6_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_6_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_6_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_6_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_44_cse ) begin
      d_buf_chan_d_lineBuf2_data_17_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_17_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_17_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_17_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_48_cse ) begin
      d_buf_chan_d_lineBuf2_data_5_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_5_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_5_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_5_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_52_cse ) begin
      d_buf_chan_d_lineBuf2_data_18_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_18_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_18_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_18_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_56_cse ) begin
      d_buf_chan_d_lineBuf2_data_4_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_4_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_4_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_4_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_60_cse ) begin
      d_buf_chan_d_lineBuf2_data_19_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_19_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_19_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_19_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_64_cse ) begin
      d_buf_chan_d_lineBuf2_data_3_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_3_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_3_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_3_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_68_cse ) begin
      d_buf_chan_d_lineBuf2_data_20_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_20_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_20_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_20_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_72_cse ) begin
      d_buf_chan_d_lineBuf2_data_2_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_2_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_2_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_2_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_76_cse ) begin
      d_buf_chan_d_lineBuf2_data_21_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_21_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_21_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_21_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_80_cse ) begin
      d_buf_chan_d_lineBuf2_data_1_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_1_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_1_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_1_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_84_cse ) begin
      d_buf_chan_d_lineBuf2_data_22_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_22_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_22_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_22_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_88_cse ) begin
      d_buf_chan_d_lineBuf2_data_0_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_0_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_0_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_0_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( d_buf_chan_d_lineBuf2_data_and_92_cse ) begin
      d_buf_chan_d_lineBuf2_data_23_16_9_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[15:8];
      d_buf_chan_d_lineBuf2_data_23_25_18_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[23:16];
      d_buf_chan_d_lineBuf2_data_23_7_0_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[7:0];
      d_buf_chan_d_lineBuf2_data_23_34_27_lpi_2 <= dinTmp_data_lpi_3_dfm_mx0[31:24];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      reg_din_rsci_oswt_tmp <= 1'b0;
      reg_dout_rsci_oswt_tmp <= 1'b0;
      run_wen <= 1'b1;
    end
    else begin
      reg_din_rsci_oswt_tmp <= IN_CHAN_HWC_EXTRA_if_mux_2_rmff;
      reg_dout_rsci_oswt_tmp <= IN_CHAN_HWC_if_mux_rmff;
      run_wen <= run_wen_rtff;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      lower_1_0_sva_1 <= 1'b0;
      upper_1_0_sva_1 <= 1'b0;
    end
    else if ( lower_and_1_cse ) begin
      lower_1_0_sva_1 <= ~((FMAP_HEIGHT_HWC_row_4_0_sva!=5'b00000));
      upper_1_0_sva_1 <= (FMAP_HEIGHT_HWC_row_4_0_sva==5'b10111);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      FMAP_WIDTH_HWC_col_4_0_sva <= 5'b00000;
    end
    else if ( run_wen & ((fsm_output[4]) | (fsm_output[1])) ) begin
      FMAP_WIDTH_HWC_col_4_0_sva <= MUX_v_5_2_2(5'b00000, FMAP_WIDTH_HWC_col_4_0_sva_1,
          (fsm_output[4]));
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      FMAP_WIDTH_HWC_FMAP_WIDTH_HWC_and_itm <= 1'b0;
    end
    else if ( run_wen & (fsm_output[2]) ) begin
      FMAP_WIDTH_HWC_FMAP_WIDTH_HWC_and_itm <= (z_out==5'b11000);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      FMAP_WIDTH_HWC_col_4_0_sva_1 <= 5'b00000;
    end
    else if ( run_wen & (~ (fsm_output[3])) ) begin
      FMAP_WIDTH_HWC_col_4_0_sva_1 <= z_out;
    end
  end
  assign FMAP_HEIGHT_HWC_mux_2_nl = MUX_s_1_2_2(lower_1_1_sva, lower_1_0_sva, fsm_output[5]);
  assign FMAP_HEIGHT_HWC_mux_3_nl = MUX_s_1_2_2(upper_1_0_sva, upper_1_0_sva_1, fsm_output[5]);
  assign d_buf_chan_rd_wr_buffer_1_switch_lp_mux1h_7_nl = MUX1HOT_v_8_3_2(d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_7_0_sva_1,
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_7_0_sva_1,
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_7_0_sva_1,
      {d_buf_chan_rd_wr_buffer_1_switch_lp_equal_tmp_1 , (d_buf_chan_d_bufPtr_lpi_3_dfm_1_mx0w1[0])
      , (d_buf_chan_d_bufPtr_lpi_3_dfm_1_mx0w1[1])});
  assign d_buf_chan_rd_wr_buffer_1_switch_lp_mux1h_6_nl = MUX1HOT_v_8_3_2(d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_16_9_sva_1,
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_16_9_sva_1,
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_16_9_sva_1,
      {d_buf_chan_rd_wr_buffer_1_switch_lp_equal_tmp_1 , (d_buf_chan_d_bufPtr_lpi_3_dfm_1_mx0w1[0])
      , (d_buf_chan_d_bufPtr_lpi_3_dfm_1_mx0w1[1])});
  assign d_buf_chan_rd_wr_buffer_1_switch_lp_mux1h_5_nl = MUX1HOT_v_8_3_2(d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_25_18_sva_1,
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_25_18_sva_1,
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_25_18_sva_1,
      {d_buf_chan_rd_wr_buffer_1_switch_lp_equal_tmp_1 , (d_buf_chan_d_bufPtr_lpi_3_dfm_1_mx0w1[0])
      , (d_buf_chan_d_bufPtr_lpi_3_dfm_1_mx0w1[1])});
  assign d_buf_chan_rd_wr_buffer_1_switch_lp_mux1h_4_nl = MUX1HOT_v_8_3_2(d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf1_data_36_35_0_1_34_0_slc_34_27_sva_1,
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf2_data_36_35_0_1_34_0_slc_34_27_sva_1,
      d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_rd_wr_buffer_case_0_d_buf_chan_rd_wr_buffer_switch_lp_slc_d_buf_chan_d_lineBuf0_data_36_35_0_1_34_0_slc_34_27_sva_1,
      {d_buf_chan_rd_wr_buffer_1_switch_lp_equal_tmp_1 , (d_buf_chan_d_bufPtr_lpi_3_dfm_1_mx0w1[0])
      , (d_buf_chan_d_bufPtr_lpi_3_dfm_1_mx0w1[1])});
  assign FMAP_HEIGHT_HWC_mux_5_nl = MUX_v_5_2_2(FMAP_HEIGHT_HWC_row_4_0_sva, FMAP_WIDTH_HWC_col_4_0_sva,
      fsm_output[2]);
  assign nl_z_out = FMAP_HEIGHT_HWC_mux_5_nl + 5'b00001;
  assign z_out = nl_z_out[4:0];

  function automatic [7:0] MUX1HOT_v_8_3_2;
    input [7:0] input_2;
    input [7:0] input_1;
    input [7:0] input_0;
    input [2:0] sel;
    reg [7:0] result;
  begin
    result = input_0 & {8{sel[0]}};
    result = result | (input_1 & {8{sel[1]}});
    result = result | (input_2 & {8{sel[2]}});
    MUX1HOT_v_8_3_2 = result;
  end
  endfunction


  function automatic  MUX_s_1_2_2;
    input  input_0;
    input  input_1;
    input  sel;
    reg  result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function automatic [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input  sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input  sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction


  function automatic [4:0] MUX_v_5_2_2;
    input [4:0] input_0;
    input [4:0] input_1;
    input  sel;
    reg [4:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_5_2_2 = result;
  end
  endfunction


  function automatic [7:0] MUX_v_8_24_2;
    input [7:0] input_0;
    input [7:0] input_1;
    input [7:0] input_2;
    input [7:0] input_3;
    input [7:0] input_4;
    input [7:0] input_5;
    input [7:0] input_6;
    input [7:0] input_7;
    input [7:0] input_8;
    input [7:0] input_9;
    input [7:0] input_10;
    input [7:0] input_11;
    input [7:0] input_12;
    input [7:0] input_13;
    input [7:0] input_14;
    input [7:0] input_15;
    input [7:0] input_16;
    input [7:0] input_17;
    input [7:0] input_18;
    input [7:0] input_19;
    input [7:0] input_20;
    input [7:0] input_21;
    input [7:0] input_22;
    input [7:0] input_23;
    input [4:0] sel;
    reg [7:0] result;
  begin
    case (sel)
      5'b00000 : begin
        result = input_0;
      end
      5'b00001 : begin
        result = input_1;
      end
      5'b00010 : begin
        result = input_2;
      end
      5'b00011 : begin
        result = input_3;
      end
      5'b00100 : begin
        result = input_4;
      end
      5'b00101 : begin
        result = input_5;
      end
      5'b00110 : begin
        result = input_6;
      end
      5'b00111 : begin
        result = input_7;
      end
      5'b01000 : begin
        result = input_8;
      end
      5'b01001 : begin
        result = input_9;
      end
      5'b01010 : begin
        result = input_10;
      end
      5'b01011 : begin
        result = input_11;
      end
      5'b01100 : begin
        result = input_12;
      end
      5'b01101 : begin
        result = input_13;
      end
      5'b01110 : begin
        result = input_14;
      end
      5'b01111 : begin
        result = input_15;
      end
      5'b10000 : begin
        result = input_16;
      end
      5'b10001 : begin
        result = input_17;
      end
      5'b10010 : begin
        result = input_18;
      end
      5'b10011 : begin
        result = input_19;
      end
      5'b10100 : begin
        result = input_20;
      end
      5'b10101 : begin
        result = input_21;
      end
      5'b10110 : begin
        result = input_22;
      end
      default : begin
        result = input_23;
      end
    endcase
    MUX_v_8_24_2 = result;
  end
  endfunction


  function automatic [7:0] MUX_v_8_2_2;
    input [7:0] input_0;
    input [7:0] input_1;
    input  sel;
    reg [7:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_8_2_2 = result;
  end
  endfunction


  function automatic [0:0] readslicef_3_1_2;
    input [2:0] vector;
    reg [2:0] tmp;
  begin
    tmp = vector >> 2;
    readslicef_3_1_2 = tmp[0:0];
  end
  endfunction


  function automatic [0:0] readslicef_6_1_5;
    input [5:0] vector;
    reg [5:0] tmp;
  begin
    tmp = vector >> 5;
    readslicef_6_1_5 = tmp[0:0];
  end
  endfunction


  function automatic [5:0] conv_u2s_5_6 ;
    input [4:0]  vector ;
  begin
    conv_u2s_5_6 =  {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run
    (
  clk, rst, din_rsc_dat, din_rsc_vld, din_rsc_rdy, kernelIn_rsc_dat, kernelIn_rsc_vld,
      kernelIn_rsc_rdy, dout_rsc_dat, dout_rsc_vld, dout_rsc_rdy, KERNEL_X_acc_37_cmp_a,
      KERNEL_X_acc_37_cmp_b, KERNEL_X_acc_37_cmp_c, KERNEL_X_acc_37_cmp_d, KERNEL_X_acc_37_cmp_z,
      KERNEL_X_acc_37_cmp_1_a, KERNEL_X_acc_37_cmp_1_b, KERNEL_X_acc_37_cmp_1_c,
      KERNEL_X_acc_37_cmp_1_d, KERNEL_X_acc_37_cmp_1_z, KERNEL_X_acc_37_cmp_2_a,
      KERNEL_X_acc_37_cmp_2_b, KERNEL_X_acc_37_cmp_2_c, KERNEL_X_acc_37_cmp_2_d,
      KERNEL_X_acc_37_cmp_2_z, KERNEL_X_acc_37_cmp_3_a, KERNEL_X_acc_37_cmp_3_b,
      KERNEL_X_acc_37_cmp_3_c, KERNEL_X_acc_37_cmp_3_d, KERNEL_X_acc_37_cmp_3_z,
      KERNEL_X_acc_37_cmp_4_a, KERNEL_X_acc_37_cmp_4_b, KERNEL_X_acc_37_cmp_4_c,
      KERNEL_X_acc_37_cmp_4_d, KERNEL_X_acc_37_cmp_4_z, KERNEL_X_acc_37_cmp_5_a,
      KERNEL_X_acc_37_cmp_5_b, KERNEL_X_acc_37_cmp_5_c, KERNEL_X_acc_37_cmp_5_d,
      KERNEL_X_acc_37_cmp_5_z, KERNEL_X_acc_37_cmp_6_a, KERNEL_X_acc_37_cmp_6_b,
      KERNEL_X_acc_37_cmp_6_c, KERNEL_X_acc_37_cmp_6_d, KERNEL_X_acc_37_cmp_6_z,
      KERNEL_X_acc_37_cmp_7_a, KERNEL_X_acc_37_cmp_7_b, KERNEL_X_acc_37_cmp_7_c,
      KERNEL_X_acc_37_cmp_7_d, KERNEL_X_acc_37_cmp_7_z, KERNEL_X_acc_37_cmp_8_a,
      KERNEL_X_acc_37_cmp_8_b, KERNEL_X_acc_37_cmp_8_c, KERNEL_X_acc_37_cmp_8_d,
      KERNEL_X_acc_37_cmp_8_z, KERNEL_X_acc_37_cmp_9_a, KERNEL_X_acc_37_cmp_9_b,
      KERNEL_X_acc_37_cmp_9_c, KERNEL_X_acc_37_cmp_9_d, KERNEL_X_acc_37_cmp_9_z,
      KERNEL_X_acc_37_cmp_10_a, KERNEL_X_acc_37_cmp_10_b, KERNEL_X_acc_37_cmp_10_c,
      KERNEL_X_acc_37_cmp_10_d, KERNEL_X_acc_37_cmp_10_z, KERNEL_X_acc_37_cmp_11_a,
      KERNEL_X_acc_37_cmp_11_b, KERNEL_X_acc_37_cmp_11_c, KERNEL_X_acc_37_cmp_11_d,
      KERNEL_X_acc_37_cmp_11_z, KERNEL_X_acc_37_cmp_12_a, KERNEL_X_acc_37_cmp_12_b,
      KERNEL_X_acc_37_cmp_12_c, KERNEL_X_acc_37_cmp_12_d, KERNEL_X_acc_37_cmp_12_z,
      KERNEL_X_acc_37_cmp_13_a, KERNEL_X_acc_37_cmp_13_b, KERNEL_X_acc_37_cmp_13_c,
      KERNEL_X_acc_37_cmp_13_d, KERNEL_X_acc_37_cmp_13_z, KERNEL_X_acc_37_cmp_14_a,
      KERNEL_X_acc_37_cmp_14_b, KERNEL_X_acc_37_cmp_14_c, KERNEL_X_acc_37_cmp_14_d,
      KERNEL_X_acc_37_cmp_14_z, KERNEL_X_acc_37_cmp_15_a, KERNEL_X_acc_37_cmp_15_b,
      KERNEL_X_acc_37_cmp_15_c, KERNEL_X_acc_37_cmp_15_d, KERNEL_X_acc_37_cmp_15_z,
      KERNEL_X_acc_37_cmp_16_a, KERNEL_X_acc_37_cmp_16_b, KERNEL_X_acc_37_cmp_16_c,
      KERNEL_X_acc_37_cmp_16_d, KERNEL_X_acc_37_cmp_16_z, KERNEL_X_acc_37_cmp_17_a,
      KERNEL_X_acc_37_cmp_17_b, KERNEL_X_acc_37_cmp_17_c, KERNEL_X_acc_37_cmp_17_d,
      KERNEL_X_acc_37_cmp_17_z
);
  input clk;
  input rst;
  input [107:0] din_rsc_dat;
  input din_rsc_vld;
  output din_rsc_rdy;
  input [287:0] kernelIn_rsc_dat;
  input kernelIn_rsc_vld;
  output kernelIn_rsc_rdy;
  output [22:0] dout_rsc_dat;
  output dout_rsc_vld;
  input dout_rsc_rdy;
  output [7:0] KERNEL_X_acc_37_cmp_a;
  output [8:0] KERNEL_X_acc_37_cmp_b;
  output [7:0] KERNEL_X_acc_37_cmp_c;
  output [8:0] KERNEL_X_acc_37_cmp_d;
  input [18:0] KERNEL_X_acc_37_cmp_z;
  output [7:0] KERNEL_X_acc_37_cmp_1_a;
  output [8:0] KERNEL_X_acc_37_cmp_1_b;
  output [7:0] KERNEL_X_acc_37_cmp_1_c;
  output [8:0] KERNEL_X_acc_37_cmp_1_d;
  input [18:0] KERNEL_X_acc_37_cmp_1_z;
  output [7:0] KERNEL_X_acc_37_cmp_2_a;
  output [8:0] KERNEL_X_acc_37_cmp_2_b;
  output [7:0] KERNEL_X_acc_37_cmp_2_c;
  output [8:0] KERNEL_X_acc_37_cmp_2_d;
  input [18:0] KERNEL_X_acc_37_cmp_2_z;
  output [7:0] KERNEL_X_acc_37_cmp_3_a;
  output [8:0] KERNEL_X_acc_37_cmp_3_b;
  output [7:0] KERNEL_X_acc_37_cmp_3_c;
  output [8:0] KERNEL_X_acc_37_cmp_3_d;
  input [18:0] KERNEL_X_acc_37_cmp_3_z;
  output [7:0] KERNEL_X_acc_37_cmp_4_a;
  output [8:0] KERNEL_X_acc_37_cmp_4_b;
  output [7:0] KERNEL_X_acc_37_cmp_4_c;
  output [8:0] KERNEL_X_acc_37_cmp_4_d;
  input [18:0] KERNEL_X_acc_37_cmp_4_z;
  output [7:0] KERNEL_X_acc_37_cmp_5_a;
  output [8:0] KERNEL_X_acc_37_cmp_5_b;
  output [7:0] KERNEL_X_acc_37_cmp_5_c;
  output [8:0] KERNEL_X_acc_37_cmp_5_d;
  input [18:0] KERNEL_X_acc_37_cmp_5_z;
  output [7:0] KERNEL_X_acc_37_cmp_6_a;
  output [8:0] KERNEL_X_acc_37_cmp_6_b;
  output [7:0] KERNEL_X_acc_37_cmp_6_c;
  output [8:0] KERNEL_X_acc_37_cmp_6_d;
  input [18:0] KERNEL_X_acc_37_cmp_6_z;
  output [7:0] KERNEL_X_acc_37_cmp_7_a;
  output [8:0] KERNEL_X_acc_37_cmp_7_b;
  output [7:0] KERNEL_X_acc_37_cmp_7_c;
  output [8:0] KERNEL_X_acc_37_cmp_7_d;
  input [18:0] KERNEL_X_acc_37_cmp_7_z;
  output [7:0] KERNEL_X_acc_37_cmp_8_a;
  output [8:0] KERNEL_X_acc_37_cmp_8_b;
  output [7:0] KERNEL_X_acc_37_cmp_8_c;
  output [8:0] KERNEL_X_acc_37_cmp_8_d;
  input [18:0] KERNEL_X_acc_37_cmp_8_z;
  output [7:0] KERNEL_X_acc_37_cmp_9_a;
  output [8:0] KERNEL_X_acc_37_cmp_9_b;
  output [7:0] KERNEL_X_acc_37_cmp_9_c;
  output [8:0] KERNEL_X_acc_37_cmp_9_d;
  input [18:0] KERNEL_X_acc_37_cmp_9_z;
  output [7:0] KERNEL_X_acc_37_cmp_10_a;
  output [8:0] KERNEL_X_acc_37_cmp_10_b;
  output [7:0] KERNEL_X_acc_37_cmp_10_c;
  output [8:0] KERNEL_X_acc_37_cmp_10_d;
  input [18:0] KERNEL_X_acc_37_cmp_10_z;
  output [7:0] KERNEL_X_acc_37_cmp_11_a;
  output [8:0] KERNEL_X_acc_37_cmp_11_b;
  output [7:0] KERNEL_X_acc_37_cmp_11_c;
  output [8:0] KERNEL_X_acc_37_cmp_11_d;
  input [18:0] KERNEL_X_acc_37_cmp_11_z;
  output [7:0] KERNEL_X_acc_37_cmp_12_a;
  output [8:0] KERNEL_X_acc_37_cmp_12_b;
  output [7:0] KERNEL_X_acc_37_cmp_12_c;
  output [8:0] KERNEL_X_acc_37_cmp_12_d;
  input [18:0] KERNEL_X_acc_37_cmp_12_z;
  output [7:0] KERNEL_X_acc_37_cmp_13_a;
  output [8:0] KERNEL_X_acc_37_cmp_13_b;
  output [7:0] KERNEL_X_acc_37_cmp_13_c;
  output [8:0] KERNEL_X_acc_37_cmp_13_d;
  input [18:0] KERNEL_X_acc_37_cmp_13_z;
  output [7:0] KERNEL_X_acc_37_cmp_14_a;
  output [8:0] KERNEL_X_acc_37_cmp_14_b;
  output [7:0] KERNEL_X_acc_37_cmp_14_c;
  output [8:0] KERNEL_X_acc_37_cmp_14_d;
  input [18:0] KERNEL_X_acc_37_cmp_14_z;
  output [7:0] KERNEL_X_acc_37_cmp_15_a;
  output [8:0] KERNEL_X_acc_37_cmp_15_b;
  output [7:0] KERNEL_X_acc_37_cmp_15_c;
  output [8:0] KERNEL_X_acc_37_cmp_15_d;
  input [18:0] KERNEL_X_acc_37_cmp_15_z;
  output [7:0] KERNEL_X_acc_37_cmp_16_a;
  output [8:0] KERNEL_X_acc_37_cmp_16_b;
  output [7:0] KERNEL_X_acc_37_cmp_16_c;
  output [8:0] KERNEL_X_acc_37_cmp_16_d;
  input [18:0] KERNEL_X_acc_37_cmp_16_z;
  output [7:0] KERNEL_X_acc_37_cmp_17_a;
  output [8:0] KERNEL_X_acc_37_cmp_17_b;
  output [7:0] KERNEL_X_acc_37_cmp_17_c;
  output [8:0] KERNEL_X_acc_37_cmp_17_d;
  input [18:0] KERNEL_X_acc_37_cmp_17_z;


  // Interconnect Declarations
  reg run_wen;
  wire din_rsci_wen_comp;
  wire [107:0] din_rsci_idat_mxwt;
  wire kernelIn_rsci_wen_comp;
  wire kernelIn_rsci_ivld;
  wire kernelIn_rsci_ivld_oreg;
  wire [287:0] kernelIn_rsci_idat_mxwt;
  wire dout_rsci_wen_comp;
  wire dout_rsci_irdy;
  wire dout_rsci_irdy_oreg;
  reg [21:0] dout_rsci_idat_21_0;
  wire [22:0] nl_dout_rsci_idat_21_0;
  wire [5:0] fsm_output;
  wire or_dcpl;
  wire or_tmp_126;
  wire or_tmp_150;
  wire and_70_cse;
  reg IN_CHAN_PACKED_if_2_slc_IN_CHAN_PACKED_acc_5_itm;
  wire [2:0] OUT_CHAN_outChan_2_0_sva_2;
  wire [3:0] nl_OUT_CHAN_outChan_2_0_sva_2;
  reg [3:0] window_d_colCnt_0_2_lpi_3_4_1;
  reg WINDOW_3_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_psp_sva;
  reg [3:0] window_d_colCnt_0_1_lpi_3_4_1;
  reg WINDOW_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_psp_sva;
  reg [3:0] window_d_colCnt_0_0_lpi_3_4_1;
  reg WINDOW_1_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_psp_sva;
  wire [3:0] window_d_colCnt_0_2_lpi_3_dfm_4_1_1;
  wire window_d_colCnt_0_2_lpi_3_dfm_0_1;
  wire flags_sol_sva_1;
  wire window_d_flush_0_2_lpi_3_dfm_mx0w0;
  reg window_d_flush_0_2_lpi_3;
  wire flags_eol_sva_1;
  wire [3:0] window_d_colCnt_0_1_lpi_3_dfm_4_1_1;
  wire window_d_colCnt_0_1_lpi_3_dfm_0_1;
  wire window_d_flush_0_1_lpi_3_dfm_mx0w0;
  reg window_d_flush_0_1_lpi_3;
  wire [3:0] window_d_colCnt_0_0_lpi_3_dfm_4_1_1;
  wire window_d_colCnt_0_0_lpi_3_dfm_0_1;
  wire window_d_flush_0_0_lpi_3_dfm_mx0w0;
  reg window_d_flush_0_0_lpi_3;
  reg OUT_CHAN_stage_0_1;
  reg window_d_solReg_0_0_0_lpi_3;
  reg window_d_solReg_0_1_0_lpi_3;
  reg window_d_solReg_0_2_0_lpi_3;
  reg OUT_CHAN_stage_0_2;
  reg operator_10_false_1_slc_operator_10_false_1_acc_2_svs_st;
  reg [4:0] FMAP_WIDTH_col_4_0_sva;
  reg reg_window_d_eolReg_0_0_0_cse;
  wire window_d_solReg_and_cse;
  wire window_d_eolReg_and_cse;
  wire window_d_reg_regs_d_and_cse;
  wire ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_cse;
  wire flags_eol_and_cse;
  wire and_38_cse;
  wire and_8_cse;
  wire or_25_cse;
  wire FMAP_HEIGHT_row_or_cse;
  reg [35:0] window_d_reg_regs_d_0_2_1_sva;
  reg [35:0] bounds_apply_bounds_win_d_0_lpi_3_dfm;
  reg [35:0] bounds_apply_bounds_win_d_2_1_lpi_3_dfm;
  reg [35:0] window_d_reg_regs_d_0_0_1_sva;
  reg [35:0] bounds_apply_bounds_win_d_0_1_lpi_3_dfm;
  reg [35:0] bounds_apply_bounds_win_d_2_2_lpi_3_dfm;
  reg [35:0] window_d_reg_regs_d_0_1_1_sva;
  reg [35:0] bounds_apply_bounds_win_d_0_2_lpi_3_dfm;
  reg [35:0] bounds_apply_bounds_win_d_2_lpi_3_dfm;
  wire run_wen_rtff;
  reg reg_din_rsci_oswt_tmp;
  reg reg_kernelIn_rsci_oswt_tmp;
  reg reg_dout_rsci_oswt_tmp;
  wire IN_CHAN_PACKED_if_mux_1_rmff;
  wire OUT_CHAN_PACK_KERNEL_RD_mux_rmff;
  wire OUT_CHAN_mux_rmff;
  reg [107:0] dinTmp_d_data_lpi_3;
  wire bounds_apply_bounds_else_else_else_if_switch_lp_1_bounds_apply_bounds_else_else_else_if_switch_lp_1_nand_itm_3;
  wire [4:0] z_out_1;
  wire [5:0] nl_z_out_1;
  reg [4:0] FMAP_HEIGHT_row_4_0_sva;
  reg window_d_solReg_0_0_1_lpi_3;
  reg window_d_solReg_0_1_1_lpi_3;
  reg window_d_solReg_0_2_1_lpi_3;
  reg flags_eol_sva;
  reg [4:0] mgc_0_8_pmx_1_lpi_3_dfm;
  reg [4:0] mgc_0_8_pmx_2_lpi_3_dfm;
  reg [4:0] mgc_0_8_pmx_lpi_3_dfm;
  reg [18:0] KERNEL_X_acc_19_1;
  reg [18:0] KERNEL_X_acc_20_1;
  reg [18:0] KERNEL_X_acc_21_1;
  reg [18:0] KERNEL_X_acc_22_1;
  reg [18:0] KERNEL_X_acc_23_1;
  reg [18:0] KERNEL_X_acc_24_1;
  reg [18:0] KERNEL_X_acc_25_1;
  reg [18:0] KERNEL_X_acc_26_1;
  reg [18:0] KERNEL_X_acc_27_1;
  reg [18:0] KERNEL_X_acc_28_1;
  reg [18:0] KERNEL_X_acc_29_1;
  reg [18:0] KERNEL_X_acc_30_1;
  reg [18:0] KERNEL_X_acc_31_1;
  reg [18:0] KERNEL_X_acc_32_1;
  reg [18:0] KERNEL_X_acc_33_1;
  reg [18:0] KERNEL_X_acc_34_1;
  reg [18:0] KERNEL_X_acc_35_1;
  reg [18:0] KERNEL_X_acc_36_1;
  reg bounds_apply_bounds_else_else_else_if_switch_lp_1_bounds_apply_bounds_else_else_else_if_switch_lp_1_nand_itm;
  reg [1:0] OUT_CHAN_outChan_2_0_sva_1_0;
  wire [107:0] dinTmp_d_data_lpi_3_dfm_mx0;
  wire IN_CHAN_PACKED_if_2_slc_IN_CHAN_PACKED_acc_5_itm_mx0w2;
  wire window_d_flush_and_cse;
  wire bounds_apply_bounds_win_d_and_cse;
  wire bounds_apply_bounds_win_d_and_3_cse;
  wire FMAP_WIDTH_acc_itm_5_1;
  wire z_out_2;

  wire[21:0] KERNEL_X_acc_55_nl;
  wire[25:0] nl_KERNEL_X_acc_55_nl;
  wire[21:0] KERNEL_X_acc_59_nl;
  wire[25:0] nl_KERNEL_X_acc_59_nl;
  wire FMAP_HEIGHT_row_not_1_nl;
  wire FMAP_HEIGHT_row_not_2_nl;
  wire and_106_nl;
  wire or_61_nl;
  wire and_110_nl;
  wire window_d_flush_mux_nl;
  wire ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_11_nl;
  wire window_d_flush_mux_1_nl;
  wire ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_8_nl;
  wire window_d_flush_mux_2_nl;
  wire ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_5_nl;
  wire ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_mux_nl;
  wire WINDOW_1_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_nl;
  wire ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_mux1h_4_nl;
  wire WINDOW_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_nl;
  wire ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_mux1h_6_nl;
  wire WINDOW_3_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_nl;
  wire[35:0] bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_nl;
  wire bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_nand_nl;
  wire[35:0] bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_3_nl;
  wire bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_nand_1_nl;
  wire[35:0] bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_4_nl;
  wire bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_nand_2_nl;
  wire IN_CHAN_PACKED_if_2_mux_nl;
  wire[5:0] IN_CHAN_PACKED_acc_nl;
  wire[6:0] nl_IN_CHAN_PACKED_acc_nl;
  wire ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_nand_2_nl;
  wire[4:0] WINDOW_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_acc_1_nl;
  wire[5:0] nl_WINDOW_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_acc_1_nl;
  wire ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_nand_1_nl;
  wire[4:0] WINDOW_1_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_acc_1_nl;
  wire[5:0] nl_WINDOW_1_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_acc_1_nl;
  wire ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_nand_nl;
  wire OUT_CHAN_mux_1_nl;
  wire OUT_CHAN_mux_2_nl;
  wire flags_sol_not_12_nl;
  wire flags_sol_not_6_nl;
  wire flags_sol_not_8_nl;
  wire[5:0] FMAP_WIDTH_acc_nl;
  wire[6:0] nl_FMAP_WIDTH_acc_nl;
  wire[2:0] operator_10_false_1_acc_nl;
  wire[4:0] nl_operator_10_false_1_acc_nl;
  wire[1:0] operator_10_false_1_mux_2_nl;
  wire[1:0] operator_10_false_1_mux_3_nl;
  wire[4:0] ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_mux1h_1_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [22:0] nl_branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_dout_rsci_inst_dout_rsci_idat;
  assign nl_branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_dout_rsci_inst_dout_rsci_idat
      = {{1{dout_rsci_idat_21_0[21]}}, dout_rsci_idat_21_0};
  wire  nl_branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_run_fsm_inst_OUT_CHAN_C_0_tr0;
  assign nl_branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_run_fsm_inst_OUT_CHAN_C_0_tr0
      = ~(OUT_CHAN_stage_0_1 | IN_CHAN_PACKED_if_2_slc_IN_CHAN_PACKED_acc_5_itm |
      OUT_CHAN_stage_0_2);
  wire  nl_branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_run_fsm_inst_FMAP_WIDTH_C_2_tr0;
  assign nl_branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_run_fsm_inst_FMAP_WIDTH_C_2_tr0
      = ~ FMAP_WIDTH_acc_itm_5_1;
  wire  nl_branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_run_fsm_inst_FMAP_HEIGHT_C_0_tr0;
  assign nl_branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_run_fsm_inst_FMAP_HEIGHT_C_0_tr0
      = ~ z_out_2;
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_din_rsci
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_din_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsc_dat(din_rsc_dat),
      .din_rsc_vld(din_rsc_vld),
      .din_rsc_rdy(din_rsc_rdy),
      .din_rsci_oswt(reg_din_rsci_oswt_tmp),
      .din_rsci_wen_comp(din_rsci_wen_comp),
      .din_rsci_idat_mxwt(din_rsci_idat_mxwt),
      .din_rsci_oswt_pff(IN_CHAN_PACKED_if_mux_1_rmff)
    );
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_wait_dp
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .kernelIn_rsci_ivld(kernelIn_rsci_ivld),
      .kernelIn_rsci_ivld_oreg(kernelIn_rsci_ivld_oreg),
      .dout_rsci_irdy(dout_rsci_irdy),
      .dout_rsci_irdy_oreg(dout_rsci_irdy_oreg)
    );
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_kernelIn_rsci
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_kernelIn_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .kernelIn_rsc_dat(kernelIn_rsc_dat),
      .kernelIn_rsc_vld(kernelIn_rsc_vld),
      .kernelIn_rsc_rdy(kernelIn_rsc_rdy),
      .run_wen(run_wen),
      .kernelIn_rsci_oswt(reg_kernelIn_rsci_oswt_tmp),
      .kernelIn_rsci_wen_comp(kernelIn_rsci_wen_comp),
      .kernelIn_rsci_ivld(kernelIn_rsci_ivld),
      .kernelIn_rsci_ivld_oreg(kernelIn_rsci_ivld_oreg),
      .kernelIn_rsci_idat_mxwt(kernelIn_rsci_idat_mxwt),
      .kernelIn_rsci_oswt_pff(OUT_CHAN_PACK_KERNEL_RD_mux_rmff),
      .kernelIn_rsci_ivld_oreg_pff(kernelIn_rsci_ivld)
    );
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_dout_rsci
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_dout_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_rsc_dat(dout_rsc_dat),
      .dout_rsc_vld(dout_rsc_vld),
      .dout_rsc_rdy(dout_rsc_rdy),
      .run_wen(run_wen),
      .dout_rsci_oswt(reg_dout_rsci_oswt_tmp),
      .dout_rsci_wen_comp(dout_rsci_wen_comp),
      .dout_rsci_irdy(dout_rsci_irdy),
      .dout_rsci_irdy_oreg(dout_rsci_irdy_oreg),
      .dout_rsci_idat(nl_branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_dout_rsci_inst_dout_rsci_idat[22:0]),
      .dout_rsci_oswt_pff(OUT_CHAN_mux_rmff),
      .dout_rsci_irdy_oreg_pff(dout_rsci_irdy)
    );
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_staller
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_staller_inst
      (
      .run_wen(run_wen_rtff),
      .din_rsci_wen_comp(din_rsci_wen_comp),
      .kernelIn_rsci_wen_comp(kernelIn_rsci_wen_comp),
      .dout_rsci_wen_comp(dout_rsci_wen_comp)
    );
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_run_fsm
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_run_fsm_inst
      (
      .clk(clk),
      .rst(rst),
      .run_wen(run_wen),
      .fsm_output(fsm_output),
      .FMAP_WIDTH_C_1_tr0(IN_CHAN_PACKED_if_2_slc_IN_CHAN_PACKED_acc_5_itm),
      .OUT_CHAN_C_0_tr0(nl_branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_run_fsm_inst_OUT_CHAN_C_0_tr0),
      .FMAP_WIDTH_C_2_tr0(nl_branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_run_fsm_inst_FMAP_WIDTH_C_2_tr0),
      .FMAP_HEIGHT_C_0_tr0(nl_branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_run_fsm_inst_FMAP_HEIGHT_C_0_tr0)
    );
  assign window_d_eolReg_and_cse = run_wen & ((fsm_output[4]) | FMAP_HEIGHT_row_or_cse);
  assign window_d_solReg_and_cse = run_wen & (or_25_cse | and_8_cse);
  assign and_8_cse = FMAP_WIDTH_acc_itm_5_1 & (fsm_output[4]);
  assign FMAP_HEIGHT_row_or_cse = (fsm_output[5]) | (fsm_output[0]);
  assign and_38_cse = z_out_2 & (fsm_output[5]);
  assign or_25_cse = and_38_cse | (fsm_output[0]);
  assign and_106_nl = z_out_2 & (fsm_output[1]);
  assign IN_CHAN_PACKED_if_mux_1_rmff = MUX_s_1_2_2(reg_din_rsci_oswt_tmp, and_106_nl,
      run_wen);
  assign or_61_nl = (or_dcpl & IN_CHAN_PACKED_if_2_slc_IN_CHAN_PACKED_acc_5_itm &
      (fsm_output[3])) | ((~ IN_CHAN_PACKED_if_2_slc_IN_CHAN_PACKED_acc_5_itm) &
      (fsm_output[2]));
  assign OUT_CHAN_PACK_KERNEL_RD_mux_rmff = MUX_s_1_2_2(reg_kernelIn_rsci_oswt_tmp,
      or_61_nl, run_wen);
  assign and_110_nl = OUT_CHAN_stage_0_2 & (fsm_output[3]);
  assign OUT_CHAN_mux_rmff = MUX_s_1_2_2(reg_dout_rsci_oswt_tmp, and_110_nl, run_wen);
  assign window_d_flush_and_cse = run_wen & ((fsm_output[2:1]!=2'b00) | FMAP_HEIGHT_row_or_cse);
  assign window_d_reg_regs_d_and_cse = run_wen & ((fsm_output[0]) | or_tmp_126);
  assign ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_cse
      = run_wen & ((fsm_output[0]) | (fsm_output[1]) | (fsm_output[4]) | (fsm_output[5]));
  assign bounds_apply_bounds_win_d_and_cse = run_wen & ((fsm_output[1]) | or_tmp_150
      | and_70_cse);
  assign bounds_apply_bounds_else_else_else_if_switch_lp_1_bounds_apply_bounds_else_else_else_if_switch_lp_1_nand_itm_3
      = ~(reg_window_d_eolReg_0_0_0_cse & (~ flags_eol_sva_1));
  assign flags_eol_and_cse = run_wen & (fsm_output[1]);
  assign bounds_apply_bounds_win_d_and_3_cse = run_wen & (~ (fsm_output[3]));
  assign window_d_flush_0_2_lpi_3_dfm_mx0w0 = window_d_flush_0_2_lpi_3 | flags_eol_sva_1;
  assign window_d_flush_0_1_lpi_3_dfm_mx0w0 = window_d_flush_0_1_lpi_3 | flags_eol_sva_1;
  assign window_d_flush_0_0_lpi_3_dfm_mx0w0 = window_d_flush_0_0_lpi_3 | flags_eol_sva_1;
  assign dinTmp_d_data_lpi_3_dfm_mx0 = MUX_v_108_2_2(dinTmp_d_data_lpi_3, din_rsci_idat_mxwt,
      operator_10_false_1_slc_operator_10_false_1_acc_2_svs_st);
  assign flags_eol_sva_1 = (FMAP_WIDTH_col_4_0_sva==5'b10111);
  assign IN_CHAN_PACKED_if_2_slc_IN_CHAN_PACKED_acc_5_itm_mx0w2 = IN_CHAN_PACKED_if_2_slc_IN_CHAN_PACKED_acc_5_itm
      & or_dcpl;
  assign flags_sol_not_12_nl = ~ flags_sol_sva_1;
  assign window_d_colCnt_0_2_lpi_3_dfm_4_1_1 = MUX_v_4_2_2(4'b0000, window_d_colCnt_0_2_lpi_3_4_1,
      flags_sol_not_12_nl);
  assign window_d_colCnt_0_2_lpi_3_dfm_0_1 = WINDOW_3_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_psp_sva
      & (~ flags_sol_sva_1);
  assign flags_sol_sva_1 = ~((FMAP_WIDTH_col_4_0_sva!=5'b00000));
  assign flags_sol_not_6_nl = ~ flags_sol_sva_1;
  assign window_d_colCnt_0_1_lpi_3_dfm_4_1_1 = MUX_v_4_2_2(4'b0000, window_d_colCnt_0_1_lpi_3_4_1,
      flags_sol_not_6_nl);
  assign window_d_colCnt_0_1_lpi_3_dfm_0_1 = WINDOW_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_psp_sva
      & (~ flags_sol_sva_1);
  assign flags_sol_not_8_nl = ~ flags_sol_sva_1;
  assign window_d_colCnt_0_0_lpi_3_dfm_4_1_1 = MUX_v_4_2_2(4'b0000, window_d_colCnt_0_0_lpi_3_4_1,
      flags_sol_not_8_nl);
  assign window_d_colCnt_0_0_lpi_3_dfm_0_1 = WINDOW_1_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_psp_sva
      & (~ flags_sol_sva_1);
  assign nl_OUT_CHAN_outChan_2_0_sva_2 = 3'b001 + conv_u2s_2_3(OUT_CHAN_outChan_2_0_sva_1_0);
  assign OUT_CHAN_outChan_2_0_sva_2 = nl_OUT_CHAN_outChan_2_0_sva_2[2:0];
  assign or_dcpl = ~(OUT_CHAN_stage_0_1 & (OUT_CHAN_outChan_2_0_sva_2[2]));
  assign and_70_cse = (~ z_out_2) & (fsm_output[5]);
  assign or_tmp_126 = and_38_cse | and_8_cse;
  assign or_tmp_150 = and_38_cse | (fsm_output[0]) | (fsm_output[4]);
  assign nl_FMAP_WIDTH_acc_nl = 6'b100111 + conv_u2s_5_6(z_out_1);
  assign FMAP_WIDTH_acc_nl = nl_FMAP_WIDTH_acc_nl[5:0];
  assign FMAP_WIDTH_acc_itm_5_1 = readslicef_6_1_5(FMAP_WIDTH_acc_nl);
  assign KERNEL_X_acc_37_cmp_a = kernelIn_rsci_idat_mxwt[135:128];
  assign KERNEL_X_acc_37_cmp_b = window_d_reg_regs_d_0_2_1_sva[17:9];
  assign KERNEL_X_acc_37_cmp_c = kernelIn_rsci_idat_mxwt[55:48];
  assign KERNEL_X_acc_37_cmp_d = bounds_apply_bounds_win_d_0_lpi_3_dfm[8:0];
  assign KERNEL_X_acc_37_cmp_1_a = kernelIn_rsci_idat_mxwt[167:160];
  assign KERNEL_X_acc_37_cmp_1_b = bounds_apply_bounds_win_d_2_1_lpi_3_dfm[26:18];
  assign KERNEL_X_acc_37_cmp_1_c = kernelIn_rsci_idat_mxwt[159:152];
  assign KERNEL_X_acc_37_cmp_1_d = window_d_reg_regs_d_0_0_1_sva[26:18];
  assign KERNEL_X_acc_37_cmp_2_a = kernelIn_rsci_idat_mxwt[151:144];
  assign KERNEL_X_acc_37_cmp_2_b = bounds_apply_bounds_win_d_0_1_lpi_3_dfm[26:18];
  assign KERNEL_X_acc_37_cmp_2_c = kernelIn_rsci_idat_mxwt[191:184];
  assign KERNEL_X_acc_37_cmp_2_d = bounds_apply_bounds_win_d_2_2_lpi_3_dfm[26:18];
  assign KERNEL_X_acc_37_cmp_3_a = kernelIn_rsci_idat_mxwt[183:176];
  assign KERNEL_X_acc_37_cmp_3_b = window_d_reg_regs_d_0_1_1_sva[26:18];
  assign KERNEL_X_acc_37_cmp_3_c = kernelIn_rsci_idat_mxwt[175:168];
  assign KERNEL_X_acc_37_cmp_3_d = bounds_apply_bounds_win_d_0_2_lpi_3_dfm[26:18];
  assign KERNEL_X_acc_37_cmp_4_a = kernelIn_rsci_idat_mxwt[215:208];
  assign KERNEL_X_acc_37_cmp_4_b = bounds_apply_bounds_win_d_2_lpi_3_dfm[26:18];
  assign KERNEL_X_acc_37_cmp_4_c = kernelIn_rsci_idat_mxwt[207:200];
  assign KERNEL_X_acc_37_cmp_4_d = window_d_reg_regs_d_0_2_1_sva[26:18];
  assign KERNEL_X_acc_37_cmp_5_a = kernelIn_rsci_idat_mxwt[271:264];
  assign KERNEL_X_acc_37_cmp_5_b = bounds_apply_bounds_win_d_0_lpi_3_dfm[35:27];
  assign KERNEL_X_acc_37_cmp_5_c = kernelIn_rsci_idat_mxwt[239:232];
  assign KERNEL_X_acc_37_cmp_5_d = bounds_apply_bounds_win_d_2_1_lpi_3_dfm[35:27];
  assign KERNEL_X_acc_37_cmp_6_a = kernelIn_rsci_idat_mxwt[231:224];
  assign KERNEL_X_acc_37_cmp_6_b = window_d_reg_regs_d_0_0_1_sva[35:27];
  assign KERNEL_X_acc_37_cmp_6_c = kernelIn_rsci_idat_mxwt[223:216];
  assign KERNEL_X_acc_37_cmp_6_d = bounds_apply_bounds_win_d_0_1_lpi_3_dfm[35:27];
  assign KERNEL_X_acc_37_cmp_7_a = kernelIn_rsci_idat_mxwt[263:256];
  assign KERNEL_X_acc_37_cmp_7_b = bounds_apply_bounds_win_d_2_2_lpi_3_dfm[35:27];
  assign KERNEL_X_acc_37_cmp_7_c = kernelIn_rsci_idat_mxwt[255:248];
  assign KERNEL_X_acc_37_cmp_7_d = window_d_reg_regs_d_0_1_1_sva[35:27];
  assign KERNEL_X_acc_37_cmp_8_a = kernelIn_rsci_idat_mxwt[247:240];
  assign KERNEL_X_acc_37_cmp_8_b = bounds_apply_bounds_win_d_0_2_lpi_3_dfm[35:27];
  assign KERNEL_X_acc_37_cmp_8_c = kernelIn_rsci_idat_mxwt[287:280];
  assign KERNEL_X_acc_37_cmp_8_d = bounds_apply_bounds_win_d_2_lpi_3_dfm[35:27];
  assign KERNEL_X_acc_37_cmp_9_a = kernelIn_rsci_idat_mxwt[279:272];
  assign KERNEL_X_acc_37_cmp_9_b = window_d_reg_regs_d_0_2_1_sva[35:27];
  assign KERNEL_X_acc_37_cmp_9_c = kernelIn_rsci_idat_mxwt[199:192];
  assign KERNEL_X_acc_37_cmp_9_d = bounds_apply_bounds_win_d_0_lpi_3_dfm[26:18];
  assign KERNEL_X_acc_37_cmp_10_a = kernelIn_rsci_idat_mxwt[23:16];
  assign KERNEL_X_acc_37_cmp_10_b = bounds_apply_bounds_win_d_2_1_lpi_3_dfm[8:0];
  assign KERNEL_X_acc_37_cmp_10_c = kernelIn_rsci_idat_mxwt[15:8];
  assign KERNEL_X_acc_37_cmp_10_d = window_d_reg_regs_d_0_0_1_sva[8:0];
  assign KERNEL_X_acc_37_cmp_11_a = kernelIn_rsci_idat_mxwt[7:0];
  assign KERNEL_X_acc_37_cmp_11_b = bounds_apply_bounds_win_d_0_1_lpi_3_dfm[8:0];
  assign KERNEL_X_acc_37_cmp_11_c = kernelIn_rsci_idat_mxwt[47:40];
  assign KERNEL_X_acc_37_cmp_11_d = bounds_apply_bounds_win_d_2_2_lpi_3_dfm[8:0];
  assign KERNEL_X_acc_37_cmp_12_a = kernelIn_rsci_idat_mxwt[39:32];
  assign KERNEL_X_acc_37_cmp_12_b = window_d_reg_regs_d_0_1_1_sva[8:0];
  assign KERNEL_X_acc_37_cmp_12_c = kernelIn_rsci_idat_mxwt[31:24];
  assign KERNEL_X_acc_37_cmp_12_d = bounds_apply_bounds_win_d_0_2_lpi_3_dfm[8:0];
  assign KERNEL_X_acc_37_cmp_13_a = kernelIn_rsci_idat_mxwt[71:64];
  assign KERNEL_X_acc_37_cmp_13_b = bounds_apply_bounds_win_d_2_lpi_3_dfm[8:0];
  assign KERNEL_X_acc_37_cmp_13_c = kernelIn_rsci_idat_mxwt[63:56];
  assign KERNEL_X_acc_37_cmp_13_d = window_d_reg_regs_d_0_2_1_sva[8:0];
  assign KERNEL_X_acc_37_cmp_14_a = kernelIn_rsci_idat_mxwt[127:120];
  assign KERNEL_X_acc_37_cmp_14_b = bounds_apply_bounds_win_d_0_lpi_3_dfm[17:9];
  assign KERNEL_X_acc_37_cmp_14_c = kernelIn_rsci_idat_mxwt[95:88];
  assign KERNEL_X_acc_37_cmp_14_d = bounds_apply_bounds_win_d_2_1_lpi_3_dfm[17:9];
  assign KERNEL_X_acc_37_cmp_15_a = kernelIn_rsci_idat_mxwt[87:80];
  assign KERNEL_X_acc_37_cmp_15_b = window_d_reg_regs_d_0_0_1_sva[17:9];
  assign KERNEL_X_acc_37_cmp_15_c = kernelIn_rsci_idat_mxwt[79:72];
  assign KERNEL_X_acc_37_cmp_15_d = bounds_apply_bounds_win_d_0_1_lpi_3_dfm[17:9];
  assign KERNEL_X_acc_37_cmp_16_a = kernelIn_rsci_idat_mxwt[119:112];
  assign KERNEL_X_acc_37_cmp_16_b = bounds_apply_bounds_win_d_2_2_lpi_3_dfm[17:9];
  assign KERNEL_X_acc_37_cmp_16_c = kernelIn_rsci_idat_mxwt[111:104];
  assign KERNEL_X_acc_37_cmp_16_d = window_d_reg_regs_d_0_1_1_sva[17:9];
  assign KERNEL_X_acc_37_cmp_17_a = kernelIn_rsci_idat_mxwt[103:96];
  assign KERNEL_X_acc_37_cmp_17_b = bounds_apply_bounds_win_d_0_2_lpi_3_dfm[17:9];
  assign KERNEL_X_acc_37_cmp_17_c = kernelIn_rsci_idat_mxwt[143:136];
  assign KERNEL_X_acc_37_cmp_17_d = bounds_apply_bounds_win_d_2_lpi_3_dfm[17:9];
  always @(posedge clk) begin
    if ( run_wen & operator_10_false_1_slc_operator_10_false_1_acc_2_svs_st & (fsm_output[2])
        ) begin
      dinTmp_d_data_lpi_3 <= din_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      reg_window_d_eolReg_0_0_0_cse <= 1'b0;
      FMAP_WIDTH_col_4_0_sva <= 5'b00000;
    end
    else if ( window_d_eolReg_and_cse ) begin
      reg_window_d_eolReg_0_0_0_cse <= flags_eol_sva & (~ FMAP_HEIGHT_row_or_cse);
      FMAP_WIDTH_col_4_0_sva <= MUX_v_5_2_2(5'b00000, z_out_1, FMAP_HEIGHT_row_not_2_nl);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      window_d_solReg_0_0_0_lpi_3 <= 1'b0;
      window_d_solReg_0_1_0_lpi_3 <= 1'b0;
      window_d_solReg_0_2_0_lpi_3 <= 1'b0;
    end
    else if ( window_d_solReg_and_cse ) begin
      window_d_solReg_0_0_0_lpi_3 <= WINDOW_1_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_psp_sva
          & (~ or_25_cse);
      window_d_solReg_0_1_0_lpi_3 <= WINDOW_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_psp_sva
          & (~ or_25_cse);
      window_d_solReg_0_2_0_lpi_3 <= WINDOW_3_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_psp_sva
          & (~ or_25_cse);
    end
  end
  always @(posedge clk) begin
    if ( run_wen ) begin
      KERNEL_X_acc_19_1 <= KERNEL_X_acc_37_cmp_z;
      KERNEL_X_acc_20_1 <= KERNEL_X_acc_37_cmp_17_z;
      KERNEL_X_acc_21_1 <= KERNEL_X_acc_37_cmp_16_z;
      KERNEL_X_acc_22_1 <= KERNEL_X_acc_37_cmp_15_z;
      KERNEL_X_acc_23_1 <= KERNEL_X_acc_37_cmp_14_z;
      KERNEL_X_acc_24_1 <= KERNEL_X_acc_37_cmp_13_z;
      KERNEL_X_acc_25_1 <= KERNEL_X_acc_37_cmp_12_z;
      KERNEL_X_acc_26_1 <= KERNEL_X_acc_37_cmp_11_z;
      KERNEL_X_acc_27_1 <= KERNEL_X_acc_37_cmp_10_z;
      KERNEL_X_acc_28_1 <= KERNEL_X_acc_37_cmp_9_z;
      KERNEL_X_acc_29_1 <= KERNEL_X_acc_37_cmp_8_z;
      KERNEL_X_acc_30_1 <= KERNEL_X_acc_37_cmp_7_z;
      KERNEL_X_acc_31_1 <= KERNEL_X_acc_37_cmp_6_z;
      KERNEL_X_acc_32_1 <= KERNEL_X_acc_37_cmp_5_z;
      KERNEL_X_acc_33_1 <= KERNEL_X_acc_37_cmp_4_z;
      KERNEL_X_acc_34_1 <= KERNEL_X_acc_37_cmp_3_z;
      KERNEL_X_acc_35_1 <= KERNEL_X_acc_37_cmp_2_z;
      KERNEL_X_acc_36_1 <= KERNEL_X_acc_37_cmp_1_z;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      window_d_solReg_0_0_1_lpi_3 <= 1'b0;
      window_d_solReg_0_1_1_lpi_3 <= 1'b0;
      window_d_solReg_0_2_1_lpi_3 <= 1'b0;
      window_d_colCnt_0_2_lpi_3_4_1 <= 4'b0000;
      window_d_colCnt_0_1_lpi_3_4_1 <= 4'b0000;
      window_d_colCnt_0_0_lpi_3_4_1 <= 4'b0000;
      bounds_apply_bounds_else_else_else_if_switch_lp_1_bounds_apply_bounds_else_else_else_if_switch_lp_1_nand_itm
          <= 1'b0;
      IN_CHAN_PACKED_if_2_slc_IN_CHAN_PACKED_acc_5_itm <= 1'b0;
      operator_10_false_1_slc_operator_10_false_1_acc_2_svs_st <= 1'b0;
      OUT_CHAN_stage_0_1 <= 1'b0;
      OUT_CHAN_stage_0_2 <= 1'b0;
    end
    else if ( run_wen ) begin
      window_d_solReg_0_0_1_lpi_3 <= window_d_solReg_0_0_0_lpi_3;
      window_d_solReg_0_1_1_lpi_3 <= window_d_solReg_0_1_0_lpi_3;
      window_d_solReg_0_2_1_lpi_3 <= window_d_solReg_0_2_0_lpi_3;
      window_d_colCnt_0_2_lpi_3_4_1 <= mgc_0_8_pmx_lpi_3_dfm[4:1];
      window_d_colCnt_0_1_lpi_3_4_1 <= mgc_0_8_pmx_2_lpi_3_dfm[4:1];
      window_d_colCnt_0_0_lpi_3_4_1 <= mgc_0_8_pmx_1_lpi_3_dfm[4:1];
      bounds_apply_bounds_else_else_else_if_switch_lp_1_bounds_apply_bounds_else_else_else_if_switch_lp_1_nand_itm
          <= bounds_apply_bounds_else_else_else_if_switch_lp_1_bounds_apply_bounds_else_else_else_if_switch_lp_1_nand_itm_3;
      IN_CHAN_PACKED_if_2_slc_IN_CHAN_PACKED_acc_5_itm <= IN_CHAN_PACKED_if_2_mux_nl
          | (fsm_output[2]);
      operator_10_false_1_slc_operator_10_false_1_acc_2_svs_st <= z_out_2;
      OUT_CHAN_stage_0_1 <= OUT_CHAN_mux_1_nl | (fsm_output[2]);
      OUT_CHAN_stage_0_2 <= OUT_CHAN_mux_2_nl & (~ (fsm_output[2]));
    end
  end
  always @(posedge clk) begin
    if ( run_wen & OUT_CHAN_stage_0_2 & (fsm_output[3]) ) begin
      dout_rsci_idat_21_0 <= nl_dout_rsci_idat_21_0[21:0];
    end
  end
  always @(posedge clk) begin
    if ( run_wen & FMAP_HEIGHT_row_or_cse ) begin
      FMAP_HEIGHT_row_4_0_sva <= MUX_v_5_2_2(5'b00000, z_out_1, FMAP_HEIGHT_row_not_1_nl);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      reg_din_rsci_oswt_tmp <= 1'b0;
      reg_kernelIn_rsci_oswt_tmp <= 1'b0;
      reg_dout_rsci_oswt_tmp <= 1'b0;
      run_wen <= 1'b1;
    end
    else begin
      reg_din_rsci_oswt_tmp <= IN_CHAN_PACKED_if_mux_1_rmff;
      reg_kernelIn_rsci_oswt_tmp <= OUT_CHAN_PACK_KERNEL_RD_mux_rmff;
      reg_dout_rsci_oswt_tmp <= OUT_CHAN_mux_rmff;
      run_wen <= run_wen_rtff;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      window_d_flush_0_2_lpi_3 <= 1'b0;
      window_d_flush_0_1_lpi_3 <= 1'b0;
      window_d_flush_0_0_lpi_3 <= 1'b0;
    end
    else if ( window_d_flush_and_cse ) begin
      window_d_flush_0_2_lpi_3 <= window_d_flush_mux_nl & (~ FMAP_HEIGHT_row_or_cse);
      window_d_flush_0_1_lpi_3 <= window_d_flush_mux_1_nl & (~ FMAP_HEIGHT_row_or_cse);
      window_d_flush_0_0_lpi_3 <= window_d_flush_mux_2_nl & (~ FMAP_HEIGHT_row_or_cse);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      window_d_reg_regs_d_0_0_1_sva <= 36'b000000000000000000000000000000000000;
      window_d_reg_regs_d_0_1_1_sva <= 36'b000000000000000000000000000000000000;
      window_d_reg_regs_d_0_2_1_sva <= 36'b000000000000000000000000000000000000;
    end
    else if ( window_d_reg_regs_d_and_cse ) begin
      window_d_reg_regs_d_0_0_1_sva <= MUX_v_36_2_2(bounds_apply_bounds_win_d_0_1_lpi_3_dfm,
          (dinTmp_d_data_lpi_3[35:0]), or_tmp_126);
      window_d_reg_regs_d_0_1_1_sva <= MUX_v_36_2_2(bounds_apply_bounds_win_d_0_2_lpi_3_dfm,
          (dinTmp_d_data_lpi_3[71:36]), or_tmp_126);
      window_d_reg_regs_d_0_2_1_sva <= MUX_v_36_2_2(bounds_apply_bounds_win_d_0_lpi_3_dfm,
          (dinTmp_d_data_lpi_3[107:72]), or_tmp_126);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      WINDOW_1_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_psp_sva
          <= 1'b0;
    end
    else if ( run_wen & ((fsm_output[1]) | (fsm_output[4]) | (fsm_output[5])) ) begin
      WINDOW_1_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_psp_sva
          <= ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_mux_nl
          | (fsm_output[5]);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      WINDOW_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_psp_sva
          <= 1'b0;
      WINDOW_3_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_psp_sva
          <= 1'b0;
    end
    else if ( ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_cse
        ) begin
      WINDOW_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_psp_sva
          <= ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_mux1h_4_nl
          | (fsm_output[5]);
      WINDOW_3_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_psp_sva
          <= ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_mux1h_6_nl
          | (fsm_output[5]);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      bounds_apply_bounds_win_d_0_1_lpi_3_dfm <= 36'b000000000000000000000000000000000000;
      bounds_apply_bounds_win_d_0_2_lpi_3_dfm <= 36'b000000000000000000000000000000000000;
      bounds_apply_bounds_win_d_0_lpi_3_dfm <= 36'b000000000000000000000000000000000000;
    end
    else if ( bounds_apply_bounds_win_d_and_cse ) begin
      bounds_apply_bounds_win_d_0_1_lpi_3_dfm <= MUX1HOT_v_36_3_2(bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_nl,
          window_d_reg_regs_d_0_0_1_sva, (dinTmp_d_data_lpi_3[35:0]), {(fsm_output[1])
          , or_tmp_150 , and_70_cse});
      bounds_apply_bounds_win_d_0_2_lpi_3_dfm <= MUX1HOT_v_36_3_2(bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_3_nl,
          window_d_reg_regs_d_0_1_1_sva, (dinTmp_d_data_lpi_3[71:36]), {(fsm_output[1])
          , or_tmp_150 , and_70_cse});
      bounds_apply_bounds_win_d_0_lpi_3_dfm <= MUX1HOT_v_36_3_2(bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_4_nl,
          window_d_reg_regs_d_0_2_1_sva, (dinTmp_d_data_lpi_3[107:72]), {(fsm_output[1])
          , or_tmp_150 , and_70_cse});
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      flags_eol_sva <= 1'b0;
      mgc_0_8_pmx_lpi_3_dfm <= 5'b00000;
      mgc_0_8_pmx_2_lpi_3_dfm <= 5'b00000;
      mgc_0_8_pmx_1_lpi_3_dfm <= 5'b00000;
    end
    else if ( flags_eol_and_cse ) begin
      flags_eol_sva <= flags_eol_sva_1;
      mgc_0_8_pmx_lpi_3_dfm <= MUX_v_5_2_2(5'b00000, z_out_1, ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_nand_2_nl);
      mgc_0_8_pmx_2_lpi_3_dfm <= MUX_v_5_2_2(5'b00000, WINDOW_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_acc_1_nl,
          ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_nand_1_nl);
      mgc_0_8_pmx_1_lpi_3_dfm <= MUX_v_5_2_2(5'b00000, WINDOW_1_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_acc_1_nl,
          ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_nand_nl);
    end
  end
  always @(posedge clk) begin
    if ( run_wen & (OUT_CHAN_stage_0_1 | (~ (fsm_output[3]))) ) begin
      OUT_CHAN_outChan_2_0_sva_1_0 <= MUX_v_2_2_2(2'b00, (OUT_CHAN_outChan_2_0_sva_2[1:0]),
          (fsm_output[3]));
    end
  end
  always @(posedge clk) begin
    if ( bounds_apply_bounds_win_d_and_3_cse ) begin
      bounds_apply_bounds_win_d_2_1_lpi_3_dfm <= MUX_v_36_2_2(36'b000000000000000000000000000000000000,
          (dinTmp_d_data_lpi_3_dfm_mx0[35:0]), bounds_apply_bounds_else_else_else_if_switch_lp_1_bounds_apply_bounds_else_else_else_if_switch_lp_1_nand_itm);
      bounds_apply_bounds_win_d_2_2_lpi_3_dfm <= MUX_v_36_2_2(36'b000000000000000000000000000000000000,
          (dinTmp_d_data_lpi_3_dfm_mx0[71:36]), OUT_CHAN_stage_0_1);
      bounds_apply_bounds_win_d_2_lpi_3_dfm <= MUX_v_36_2_2(36'b000000000000000000000000000000000000,
          (dinTmp_d_data_lpi_3_dfm_mx0[107:72]), OUT_CHAN_stage_0_2);
    end
  end
  assign FMAP_HEIGHT_row_not_2_nl = ~ FMAP_HEIGHT_row_or_cse;
  assign nl_IN_CHAN_PACKED_acc_nl = conv_u2s_5_6(FMAP_WIDTH_col_4_0_sva) + 6'b111111;
  assign IN_CHAN_PACKED_acc_nl = nl_IN_CHAN_PACKED_acc_nl[5:0];
  assign IN_CHAN_PACKED_if_2_mux_nl = MUX_s_1_2_2((readslicef_6_1_5(IN_CHAN_PACKED_acc_nl)),
      IN_CHAN_PACKED_if_2_slc_IN_CHAN_PACKED_acc_5_itm_mx0w2, fsm_output[3]);
  assign OUT_CHAN_mux_1_nl = MUX_s_1_2_2(bounds_apply_bounds_else_else_else_if_switch_lp_1_bounds_apply_bounds_else_else_else_if_switch_lp_1_nand_itm_3,
      IN_CHAN_PACKED_if_2_slc_IN_CHAN_PACKED_acc_5_itm_mx0w2, fsm_output[3]);
  assign OUT_CHAN_mux_2_nl = MUX_s_1_2_2(bounds_apply_bounds_else_else_else_if_switch_lp_1_bounds_apply_bounds_else_else_else_if_switch_lp_1_nand_itm_3,
      OUT_CHAN_stage_0_1, fsm_output[3]);
  assign nl_KERNEL_X_acc_55_nl = conv_s2s_19_22(KERNEL_X_acc_19_1) + conv_s2s_19_22(KERNEL_X_acc_20_1)
      + conv_s2s_19_22(KERNEL_X_acc_21_1) + conv_s2s_19_22(KERNEL_X_acc_22_1) + conv_s2s_19_22(KERNEL_X_acc_23_1)
      + conv_s2s_19_22(KERNEL_X_acc_24_1) + conv_s2s_19_22(KERNEL_X_acc_25_1) + conv_s2s_19_22(KERNEL_X_acc_26_1)
      + conv_s2s_19_22(KERNEL_X_acc_27_1);
  assign KERNEL_X_acc_55_nl = nl_KERNEL_X_acc_55_nl[21:0];
  assign nl_KERNEL_X_acc_59_nl = conv_s2s_19_22(KERNEL_X_acc_28_1) + conv_s2s_19_22(KERNEL_X_acc_29_1)
      + conv_s2s_19_22(KERNEL_X_acc_30_1) + conv_s2s_19_22(KERNEL_X_acc_31_1) + conv_s2s_19_22(KERNEL_X_acc_32_1)
      + conv_s2s_19_22(KERNEL_X_acc_33_1) + conv_s2s_19_22(KERNEL_X_acc_34_1) + conv_s2s_19_22(KERNEL_X_acc_35_1)
      + conv_s2s_19_22(KERNEL_X_acc_36_1);
  assign KERNEL_X_acc_59_nl = nl_KERNEL_X_acc_59_nl[21:0];
  assign nl_dout_rsci_idat_21_0  = KERNEL_X_acc_55_nl + KERNEL_X_acc_59_nl;
  assign FMAP_HEIGHT_row_not_1_nl = ~ (fsm_output[0]);
  assign ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_11_nl
      = window_d_flush_0_2_lpi_3 & (~ reg_window_d_eolReg_0_0_0_cse);
  assign window_d_flush_mux_nl = MUX_s_1_2_2(window_d_flush_0_2_lpi_3_dfm_mx0w0,
      ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_11_nl,
      fsm_output[2]);
  assign ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_8_nl
      = window_d_flush_0_1_lpi_3 & (~ reg_window_d_eolReg_0_0_0_cse);
  assign window_d_flush_mux_1_nl = MUX_s_1_2_2(window_d_flush_0_1_lpi_3_dfm_mx0w0,
      ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_8_nl,
      fsm_output[2]);
  assign ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_5_nl
      = window_d_flush_0_0_lpi_3 & (~ reg_window_d_eolReg_0_0_0_cse);
  assign window_d_flush_mux_2_nl = MUX_s_1_2_2(window_d_flush_0_0_lpi_3_dfm_mx0w0,
      ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_5_nl,
      fsm_output[2]);
  assign WINDOW_1_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_nl
      = flags_sol_sva_1 & (~ window_d_flush_0_0_lpi_3_dfm_mx0w0);
  assign ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_mux_nl
      = MUX_s_1_2_2(WINDOW_1_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_nl,
      (mgc_0_8_pmx_1_lpi_3_dfm[0]), fsm_output[4]);
  assign WINDOW_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_nl
      = flags_sol_sva_1 & (~ window_d_flush_0_1_lpi_3_dfm_mx0w0);
  assign ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_mux1h_4_nl
      = MUX1HOT_s_1_3_2(WINDOW_1_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_psp_sva,
      WINDOW_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_nl,
      (mgc_0_8_pmx_2_lpi_3_dfm[0]), {(fsm_output[0]) , (fsm_output[1]) , (fsm_output[4])});
  assign WINDOW_3_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_nl
      = flags_sol_sva_1 & (~ window_d_flush_0_2_lpi_3_dfm_mx0w0);
  assign ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_mux1h_6_nl
      = MUX1HOT_s_1_3_2(WINDOW_1_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_psp_sva,
      WINDOW_3_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_and_1_nl,
      (mgc_0_8_pmx_lpi_3_dfm[0]), {(fsm_output[0]) , (fsm_output[1]) , (fsm_output[4])});
  assign bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_nand_nl
      = ~(window_d_solReg_0_0_0_lpi_3 & (~ window_d_solReg_0_0_1_lpi_3));
  assign bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_nl
      = MUX_v_36_2_2(36'b000000000000000000000000000000000000, bounds_apply_bounds_win_d_0_1_lpi_3_dfm,
      bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_nand_nl);
  assign bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_nand_1_nl
      = ~(window_d_solReg_0_1_0_lpi_3 & (~ window_d_solReg_0_1_1_lpi_3));
  assign bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_3_nl
      = MUX_v_36_2_2(36'b000000000000000000000000000000000000, bounds_apply_bounds_win_d_0_2_lpi_3_dfm,
      bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_nand_1_nl);
  assign bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_nand_2_nl
      = ~(window_d_solReg_0_2_0_lpi_3 & (~ window_d_solReg_0_2_1_lpi_3));
  assign bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_and_4_nl
      = MUX_v_36_2_2(36'b000000000000000000000000000000000000, bounds_apply_bounds_win_d_0_lpi_3_dfm,
      bounds_apply_bounds_else_else_else_if_switch_lp_bounds_apply_bounds_else_else_else_if_switch_lp_nand_2_nl);
  assign ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_nand_2_nl
      = ~((window_d_colCnt_0_2_lpi_3_dfm_4_1_1[3]) & (window_d_colCnt_0_2_lpi_3_dfm_4_1_1[1])
      & (window_d_colCnt_0_2_lpi_3_dfm_4_1_1[0]) & window_d_colCnt_0_2_lpi_3_dfm_0_1
      & (~ (window_d_colCnt_0_2_lpi_3_dfm_4_1_1[2])));
  assign nl_WINDOW_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_acc_1_nl
      = ({window_d_colCnt_0_1_lpi_3_dfm_4_1_1 , window_d_colCnt_0_1_lpi_3_dfm_0_1})
      + 5'b00001;
  assign WINDOW_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_acc_1_nl
      = nl_WINDOW_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_acc_1_nl[4:0];
  assign ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_nand_1_nl
      = ~((window_d_colCnt_0_1_lpi_3_dfm_4_1_1[3]) & (window_d_colCnt_0_1_lpi_3_dfm_4_1_1[1])
      & (window_d_colCnt_0_1_lpi_3_dfm_4_1_1[0]) & window_d_colCnt_0_1_lpi_3_dfm_0_1
      & (~ (window_d_colCnt_0_1_lpi_3_dfm_4_1_1[2])));
  assign nl_WINDOW_1_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_acc_1_nl
      = ({window_d_colCnt_0_0_lpi_3_dfm_4_1_1 , window_d_colCnt_0_0_lpi_3_dfm_0_1})
      + 5'b00001;
  assign WINDOW_1_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_acc_1_nl
      = nl_WINDOW_1_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_acc_1_nl[4:0];
  assign ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_nand_nl
      = ~((window_d_colCnt_0_0_lpi_3_dfm_4_1_1[3]) & (window_d_colCnt_0_0_lpi_3_dfm_4_1_1[1])
      & (window_d_colCnt_0_0_lpi_3_dfm_4_1_1[0]) & window_d_colCnt_0_0_lpi_3_dfm_0_1
      & (~ (window_d_colCnt_0_0_lpi_3_dfm_4_1_1[2])));
  assign operator_10_false_1_mux_2_nl = MUX_v_2_2_2((FMAP_WIDTH_col_4_0_sva[4:3]),
      2'b01, fsm_output[5]);
  assign operator_10_false_1_mux_3_nl = MUX_v_2_2_2(2'b01, (z_out_1[4:3]), fsm_output[5]);
  assign nl_operator_10_false_1_acc_nl = conv_u2u_2_3(operator_10_false_1_mux_2_nl)
      + conv_u2u_2_3(operator_10_false_1_mux_3_nl) + 3'b100;
  assign operator_10_false_1_acc_nl = nl_operator_10_false_1_acc_nl[2:0];
  assign z_out_2 = readslicef_3_1_2(operator_10_false_1_acc_nl);
  assign ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_mux1h_1_nl
      = MUX1HOT_v_5_3_2(({window_d_colCnt_0_2_lpi_3_dfm_4_1_1 , window_d_colCnt_0_2_lpi_3_dfm_0_1}),
      FMAP_HEIGHT_row_4_0_sva, FMAP_WIDTH_col_4_0_sva, {(fsm_output[1]) , (fsm_output[5])
      , (fsm_output[4])});
  assign nl_z_out_1 = ac_window1xN_stride_1_pad_N_HLS_ac_int_36_false_3_24_8_0_slide_window_if_else_2_mux1h_1_nl
      + 5'b00001;
  assign z_out_1 = nl_z_out_1[4:0];

  function automatic  MUX1HOT_s_1_3_2;
    input  input_2;
    input  input_1;
    input  input_0;
    input [2:0] sel;
    reg  result;
  begin
    result = input_0 & sel[0];
    result = result | (input_1 & sel[1]);
    result = result | (input_2 & sel[2]);
    MUX1HOT_s_1_3_2 = result;
  end
  endfunction


  function automatic [35:0] MUX1HOT_v_36_3_2;
    input [35:0] input_2;
    input [35:0] input_1;
    input [35:0] input_0;
    input [2:0] sel;
    reg [35:0] result;
  begin
    result = input_0 & {36{sel[0]}};
    result = result | (input_1 & {36{sel[1]}});
    result = result | (input_2 & {36{sel[2]}});
    MUX1HOT_v_36_3_2 = result;
  end
  endfunction


  function automatic [4:0] MUX1HOT_v_5_3_2;
    input [4:0] input_2;
    input [4:0] input_1;
    input [4:0] input_0;
    input [2:0] sel;
    reg [4:0] result;
  begin
    result = input_0 & {5{sel[0]}};
    result = result | (input_1 & {5{sel[1]}});
    result = result | (input_2 & {5{sel[2]}});
    MUX1HOT_v_5_3_2 = result;
  end
  endfunction


  function automatic  MUX_s_1_2_2;
    input  input_0;
    input  input_1;
    input  sel;
    reg  result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function automatic [107:0] MUX_v_108_2_2;
    input [107:0] input_0;
    input [107:0] input_1;
    input  sel;
    reg [107:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_108_2_2 = result;
  end
  endfunction


  function automatic [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input  sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function automatic [35:0] MUX_v_36_2_2;
    input [35:0] input_0;
    input [35:0] input_1;
    input  sel;
    reg [35:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_36_2_2 = result;
  end
  endfunction


  function automatic [3:0] MUX_v_4_2_2;
    input [3:0] input_0;
    input [3:0] input_1;
    input  sel;
    reg [3:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_4_2_2 = result;
  end
  endfunction


  function automatic [4:0] MUX_v_5_2_2;
    input [4:0] input_0;
    input [4:0] input_1;
    input  sel;
    reg [4:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_5_2_2 = result;
  end
  endfunction


  function automatic [0:0] readslicef_3_1_2;
    input [2:0] vector;
    reg [2:0] tmp;
  begin
    tmp = vector >> 2;
    readslicef_3_1_2 = tmp[0:0];
  end
  endfunction


  function automatic [0:0] readslicef_6_1_5;
    input [5:0] vector;
    reg [5:0] tmp;
  begin
    tmp = vector >> 5;
    readslicef_6_1_5 = tmp[0:0];
  end
  endfunction


  function automatic [21:0] conv_s2s_19_22 ;
    input [18:0]  vector ;
  begin
    conv_s2s_19_22 = {{3{vector[18]}}, vector};
  end
  endfunction


  function automatic [2:0] conv_u2s_2_3 ;
    input [1:0]  vector ;
  begin
    conv_u2s_2_3 =  {1'b0, vector};
  end
  endfunction


  function automatic [5:0] conv_u2s_5_6 ;
    input [4:0]  vector ;
  begin
    conv_u2s_5_6 =  {1'b0, vector};
  end
  endfunction


  function automatic [2:0] conv_u2u_2_3 ;
    input [1:0]  vector ;
  begin
    conv_u2u_2_3 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run
    (
  clk, rst, din_rsc_dat, din_rsc_vld, din_rsc_rdy, bias_rsc_dat, bias_rsc_vld, bias_rsc_rdy,
      dout_rsc_dat, dout_rsc_vld, dout_rsc_rdy
);
  input clk;
  input rst;
  input [22:0] din_rsc_dat;
  input din_rsc_vld;
  output din_rsc_rdy;
  input [31:0] bias_rsc_dat;
  input bias_rsc_vld;
  output bias_rsc_rdy;
  output [25:0] dout_rsc_dat;
  output dout_rsc_vld;
  input dout_rsc_rdy;


  // Interconnect Declarations
  reg run_wen;
  wire din_rsci_wen_comp;
  wire din_rsci_ivld;
  wire din_rsci_ivld_oreg;
  wire [22:0] din_rsci_idat_mxwt;
  wire bias_rsci_wen_comp;
  wire bias_rsci_ivld;
  wire bias_rsci_ivld_oreg;
  wire [25:0] bias_rsci_idat_mxwt;
  wire dout_rsci_wen_comp;
  wire dout_rsci_irdy;
  wire dout_rsci_irdy_oreg;
  reg [25:0] dout_rsci_idat;
  wire [26:0] nl_dout_rsci_idat;
  wire [3:0] fsm_output;
  wire [2:0] FMAP_PSUM_OCHAN_outChan_2_0_sva_2;
  wire [3:0] nl_FMAP_PSUM_OCHAN_outChan_2_0_sva_2;
  reg FMAP_PSUM_OCHAN_stage_0;
  wire run_wen_rtff;
  reg reg_bias_rsci_oswt_tmp;
  reg reg_dout_rsci_oswt_tmp;
  wire FMAP_PSUM_OCHAN_if_mux_rmff;
  wire FMAP_PSUM_OCHAN_if_1_mux_rmff;
  wire [4:0] z_out;
  wire [5:0] nl_z_out;
  reg [4:0] FMAP_PSUM_HEIGHT_r_4_0_sva;
  reg [4:0] FMAP_PSUM_WIDTH_c_4_0_sva;
  reg [1:0] FMAP_PSUM_OCHAN_outChan_2_0_sva_1_0;
  wire nand_1_cse;
  wire FMAP_PSUM_HEIGHT_r_or_cse;
  wire z_out_1_2;

  wire FMAP_PSUM_OCHAN_if_nor_nl;
  wire FMAP_PSUM_WIDTH_c_not_nl;
  wire and_35_nl;
  wire[4:0] FMAP_PSUM_HEIGHT_mux_2_nl;
  wire[2:0] FMAP_PSUM_WIDTH_acc_nl;
  wire[4:0] nl_FMAP_PSUM_WIDTH_acc_nl;
  wire[1:0] FMAP_PSUM_WIDTH_mux_2_nl;
  wire[1:0] FMAP_PSUM_WIDTH_mux_3_nl;

  // Interconnect Declarations for Component Instantiations 
  wire  nl_branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_run_fsm_inst_FMAP_PSUM_OCHAN_C_0_tr0;
  assign nl_branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_run_fsm_inst_FMAP_PSUM_OCHAN_C_0_tr0
      = ~ FMAP_PSUM_OCHAN_stage_0;
  wire  nl_branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_run_fsm_inst_FMAP_PSUM_WIDTH_C_0_tr0;
  assign nl_branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_run_fsm_inst_FMAP_PSUM_WIDTH_C_0_tr0
      = ~ z_out_1_2;
  wire  nl_branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_run_fsm_inst_FMAP_PSUM_HEIGHT_C_0_tr0;
  assign nl_branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_run_fsm_inst_FMAP_PSUM_HEIGHT_C_0_tr0
      = ~ z_out_1_2;
  branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_din_rsci
      branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_din_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsc_dat(din_rsc_dat),
      .din_rsc_vld(din_rsc_vld),
      .din_rsc_rdy(din_rsc_rdy),
      .run_wen(run_wen),
      .din_rsci_oswt(reg_bias_rsci_oswt_tmp),
      .din_rsci_wen_comp(din_rsci_wen_comp),
      .din_rsci_ivld(din_rsci_ivld),
      .din_rsci_ivld_oreg(din_rsci_ivld_oreg),
      .din_rsci_idat_mxwt(din_rsci_idat_mxwt),
      .din_rsci_oswt_pff(FMAP_PSUM_OCHAN_if_mux_rmff),
      .din_rsci_ivld_oreg_pff(din_rsci_ivld)
    );
  branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_wait_dp
      branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsci_ivld(din_rsci_ivld),
      .din_rsci_ivld_oreg(din_rsci_ivld_oreg),
      .bias_rsci_ivld(bias_rsci_ivld),
      .bias_rsci_ivld_oreg(bias_rsci_ivld_oreg),
      .dout_rsci_irdy(dout_rsci_irdy),
      .dout_rsci_irdy_oreg(dout_rsci_irdy_oreg)
    );
  branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_bias_rsci
      branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_bias_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .bias_rsc_dat(bias_rsc_dat),
      .bias_rsc_vld(bias_rsc_vld),
      .bias_rsc_rdy(bias_rsc_rdy),
      .run_wen(run_wen),
      .bias_rsci_oswt(reg_bias_rsci_oswt_tmp),
      .bias_rsci_wen_comp(bias_rsci_wen_comp),
      .bias_rsci_ivld(bias_rsci_ivld),
      .bias_rsci_ivld_oreg(bias_rsci_ivld_oreg),
      .bias_rsci_idat_mxwt(bias_rsci_idat_mxwt),
      .bias_rsci_oswt_pff(FMAP_PSUM_OCHAN_if_mux_rmff),
      .bias_rsci_ivld_oreg_pff(bias_rsci_ivld)
    );
  branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_dout_rsci
      branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_dout_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_rsc_dat(dout_rsc_dat),
      .dout_rsc_vld(dout_rsc_vld),
      .dout_rsc_rdy(dout_rsc_rdy),
      .run_wen(run_wen),
      .dout_rsci_oswt(reg_dout_rsci_oswt_tmp),
      .dout_rsci_wen_comp(dout_rsci_wen_comp),
      .dout_rsci_irdy(dout_rsci_irdy),
      .dout_rsci_irdy_oreg(dout_rsci_irdy_oreg),
      .dout_rsci_idat(dout_rsci_idat),
      .dout_rsci_oswt_pff(FMAP_PSUM_OCHAN_if_1_mux_rmff),
      .dout_rsci_irdy_oreg_pff(dout_rsci_irdy)
    );
  branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_staller
      branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_staller_inst
      (
      .run_wen(run_wen_rtff),
      .din_rsci_wen_comp(din_rsci_wen_comp),
      .bias_rsci_wen_comp(bias_rsci_wen_comp),
      .dout_rsci_wen_comp(dout_rsci_wen_comp)
    );
  branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_run_fsm
      branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_run_fsm_inst
      (
      .clk(clk),
      .rst(rst),
      .run_wen(run_wen),
      .fsm_output(fsm_output),
      .FMAP_PSUM_OCHAN_C_0_tr0(nl_branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_run_fsm_inst_FMAP_PSUM_OCHAN_C_0_tr0),
      .FMAP_PSUM_WIDTH_C_0_tr0(nl_branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_run_fsm_inst_FMAP_PSUM_WIDTH_C_0_tr0),
      .FMAP_PSUM_HEIGHT_C_0_tr0(nl_branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_run_fsm_inst_FMAP_PSUM_HEIGHT_C_0_tr0)
    );
  assign nand_1_cse = ~((~ (FMAP_PSUM_OCHAN_outChan_2_0_sva_2[2])) & FMAP_PSUM_OCHAN_stage_0);
  assign FMAP_PSUM_OCHAN_if_nor_nl = ~(((~ z_out_1_2) & (fsm_output[3])) | (nand_1_cse
      & (fsm_output[1])) | ((~ z_out_1_2) & (fsm_output[2])));
  assign FMAP_PSUM_OCHAN_if_mux_rmff = MUX_s_1_2_2(reg_bias_rsci_oswt_tmp, FMAP_PSUM_OCHAN_if_nor_nl,
      run_wen);
  assign FMAP_PSUM_HEIGHT_r_or_cse = (fsm_output[0]) | (fsm_output[3]);
  assign and_35_nl = FMAP_PSUM_OCHAN_stage_0 & (fsm_output[1]);
  assign FMAP_PSUM_OCHAN_if_1_mux_rmff = MUX_s_1_2_2(reg_dout_rsci_oswt_tmp, and_35_nl,
      run_wen);
  assign nl_FMAP_PSUM_OCHAN_outChan_2_0_sva_2 = 3'b001 + conv_u2s_2_3(FMAP_PSUM_OCHAN_outChan_2_0_sva_1_0);
  assign FMAP_PSUM_OCHAN_outChan_2_0_sva_2 = nl_FMAP_PSUM_OCHAN_outChan_2_0_sva_2[2:0];
  always @(posedge clk) begin
    if ( rst ) begin
      reg_bias_rsci_oswt_tmp <= 1'b0;
      reg_dout_rsci_oswt_tmp <= 1'b0;
      run_wen <= 1'b1;
    end
    else begin
      reg_bias_rsci_oswt_tmp <= FMAP_PSUM_OCHAN_if_mux_rmff;
      reg_dout_rsci_oswt_tmp <= FMAP_PSUM_OCHAN_if_1_mux_rmff;
      run_wen <= run_wen_rtff;
    end
  end
  always @(posedge clk) begin
    if ( run_wen & (fsm_output[1]) & FMAP_PSUM_OCHAN_stage_0 ) begin
      dout_rsci_idat <= nl_dout_rsci_idat[25:0];
    end
  end
  always @(posedge clk) begin
    if ( run_wen & FMAP_PSUM_HEIGHT_r_or_cse ) begin
      FMAP_PSUM_HEIGHT_r_4_0_sva <= MUX_v_5_2_2(5'b00000, z_out, (fsm_output[3]));
    end
  end
  always @(posedge clk) begin
    if ( run_wen & ((fsm_output[2]) | FMAP_PSUM_HEIGHT_r_or_cse) ) begin
      FMAP_PSUM_WIDTH_c_4_0_sva <= MUX_v_5_2_2(5'b00000, z_out, FMAP_PSUM_WIDTH_c_not_nl);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      FMAP_PSUM_OCHAN_stage_0 <= 1'b0;
    end
    else if ( run_wen ) begin
      FMAP_PSUM_OCHAN_stage_0 <= ~(nand_1_cse & (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( run_wen & (FMAP_PSUM_OCHAN_stage_0 | (~ (fsm_output[1]))) ) begin
      FMAP_PSUM_OCHAN_outChan_2_0_sva_1_0 <= MUX_v_2_2_2(2'b00, (FMAP_PSUM_OCHAN_outChan_2_0_sva_2[1:0]),
          (fsm_output[1]));
    end
  end
  assign nl_dout_rsci_idat  = conv_s2s_23_26(din_rsci_idat_mxwt) + bias_rsci_idat_mxwt;
  assign FMAP_PSUM_WIDTH_c_not_nl = ~ FMAP_PSUM_HEIGHT_r_or_cse;
  assign FMAP_PSUM_HEIGHT_mux_2_nl = MUX_v_5_2_2(FMAP_PSUM_HEIGHT_r_4_0_sva, FMAP_PSUM_WIDTH_c_4_0_sva,
      fsm_output[2]);
  assign nl_z_out = FMAP_PSUM_HEIGHT_mux_2_nl + 5'b00001;
  assign z_out = nl_z_out[4:0];
  assign FMAP_PSUM_WIDTH_mux_2_nl = MUX_v_2_2_2((z_out[4:3]), 2'b01, fsm_output[3]);
  assign FMAP_PSUM_WIDTH_mux_3_nl = MUX_v_2_2_2(2'b01, (z_out[4:3]), fsm_output[3]);
  assign nl_FMAP_PSUM_WIDTH_acc_nl = conv_u2u_2_3(FMAP_PSUM_WIDTH_mux_2_nl) + conv_u2u_2_3(FMAP_PSUM_WIDTH_mux_3_nl)
      + 3'b100;
  assign FMAP_PSUM_WIDTH_acc_nl = nl_FMAP_PSUM_WIDTH_acc_nl[2:0];
  assign z_out_1_2 = readslicef_3_1_2(FMAP_PSUM_WIDTH_acc_nl);

  function automatic  MUX_s_1_2_2;
    input  input_0;
    input  input_1;
    input  sel;
    reg  result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function automatic [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input  sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function automatic [4:0] MUX_v_5_2_2;
    input [4:0] input_0;
    input [4:0] input_1;
    input  sel;
    reg [4:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_5_2_2 = result;
  end
  endfunction


  function automatic [0:0] readslicef_3_1_2;
    input [2:0] vector;
    reg [2:0] tmp;
  begin
    tmp = vector >> 2;
    readslicef_3_1_2 = tmp[0:0];
  end
  endfunction


  function automatic [25:0] conv_s2s_23_26 ;
    input [22:0]  vector ;
  begin
    conv_s2s_23_26 = {{3{vector[22]}}, vector};
  end
  endfunction


  function automatic [2:0] conv_u2s_2_3 ;
    input [1:0]  vector ;
  begin
    conv_u2s_2_3 =  {1'b0, vector};
  end
  endfunction


  function automatic [2:0] conv_u2u_2_3 ;
    input [1:0]  vector ;
  begin
    conv_u2u_2_3 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run
    (
  clk, rst, din_rsc_dat, din_rsc_vld, din_rsc_rdy, dout_rsc_dat, dout_rsc_vld, dout_rsc_rdy
);
  input clk;
  input rst;
  input [25:0] din_rsc_dat;
  input din_rsc_vld;
  output din_rsc_rdy;
  output [7:0] dout_rsc_dat;
  output dout_rsc_vld;
  input dout_rsc_rdy;


  // Interconnect Declarations
  reg run_wen;
  wire din_rsci_wen_comp;
  wire din_rsci_ivld;
  wire din_rsci_ivld_oreg;
  wire [25:0] din_rsci_idat_mxwt;
  wire dout_rsci_wen_comp;
  wire dout_rsci_irdy;
  wire dout_rsci_irdy_oreg;
  reg [7:0] dout_rsci_idat;
  wire [1:0] fsm_output;
  reg [25:0] for_for_if_slc_for_for_if_for_for_if_mul_47_22_psp_sva_1;
  reg for_stage_0_2;
  reg for_stage_0;
  wire run_wen_rtff;
  reg reg_din_rsci_oswt_tmp;
  reg reg_dout_rsci_oswt_tmp;
  wire for_mux_rmff;
  wire for_mux_1_rmff;
  reg [11:0] for_i_11_0_sva;
  wire [11:0] for_i_11_0_sva_1_mx1w0;
  wire [12:0] nl_for_i_11_0_sva_1_mx1w0;
  wire for_for_if_for_nand_cse;

  wire[4:0] for_acc_nl;
  wire[5:0] nl_for_acc_nl;
  wire[7:0] for_for_nor_nl;
  wire[7:0] for_for_else_2_else_acc_nl;
  wire[8:0] nl_for_for_else_2_else_acc_nl;
  wire for_for_else_2_else_and_nl;
  wire[47:0] for_for_if_for_for_if_mul_nl;
  wire signed [48:0] nl_for_for_if_for_for_if_mul_nl;
  wire[11:0] for_i_mux_1_nl;
  wire and_14_nl;

  // Interconnect Declarations for Component Instantiations 
  wire  nl_branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_run_fsm_inst_for_C_0_tr0;
  assign nl_branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_run_fsm_inst_for_C_0_tr0
      = ~(for_stage_0_2 | for_stage_0);
  branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_din_rsci
      branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_din_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsc_dat(din_rsc_dat),
      .din_rsc_vld(din_rsc_vld),
      .din_rsc_rdy(din_rsc_rdy),
      .run_wen(run_wen),
      .din_rsci_oswt(reg_din_rsci_oswt_tmp),
      .din_rsci_wen_comp(din_rsci_wen_comp),
      .din_rsci_ivld(din_rsci_ivld),
      .din_rsci_ivld_oreg(din_rsci_ivld_oreg),
      .din_rsci_idat_mxwt(din_rsci_idat_mxwt),
      .din_rsci_oswt_pff(for_mux_rmff),
      .din_rsci_ivld_oreg_pff(din_rsci_ivld)
    );
  branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_wait_dp
      branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsci_ivld(din_rsci_ivld),
      .din_rsci_ivld_oreg(din_rsci_ivld_oreg),
      .dout_rsci_irdy(dout_rsci_irdy),
      .dout_rsci_irdy_oreg(dout_rsci_irdy_oreg)
    );
  branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_dout_rsci
      branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_dout_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dout_rsc_dat(dout_rsc_dat),
      .dout_rsc_vld(dout_rsc_vld),
      .dout_rsc_rdy(dout_rsc_rdy),
      .run_wen(run_wen),
      .dout_rsci_oswt(reg_dout_rsci_oswt_tmp),
      .dout_rsci_wen_comp(dout_rsci_wen_comp),
      .dout_rsci_irdy(dout_rsci_irdy),
      .dout_rsci_irdy_oreg(dout_rsci_irdy_oreg),
      .dout_rsci_idat(dout_rsci_idat),
      .dout_rsci_oswt_pff(for_mux_1_rmff),
      .dout_rsci_irdy_oreg_pff(dout_rsci_irdy)
    );
  branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_staller
      branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_staller_inst
      (
      .run_wen(run_wen_rtff),
      .din_rsci_wen_comp(din_rsci_wen_comp),
      .dout_rsci_wen_comp(dout_rsci_wen_comp)
    );
  branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_run_fsm
      branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_run_fsm_inst
      (
      .clk(clk),
      .rst(rst),
      .run_wen(run_wen),
      .fsm_output(fsm_output),
      .for_C_0_tr0(nl_branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_run_fsm_inst_for_C_0_tr0)
    );
  assign nl_for_acc_nl = 5'b10111 + conv_u2s_4_5(for_i_11_0_sva_1_mx1w0[11:8]);
  assign for_acc_nl = nl_for_acc_nl[4:0];
  assign for_for_if_for_nand_cse = ~((~((readslicef_5_1_4(for_acc_nl)) & for_stage_0))
      & (fsm_output[1]));
  assign for_mux_rmff = MUX_s_1_2_2(reg_din_rsci_oswt_tmp, for_for_if_for_nand_cse,
      run_wen);
  assign and_14_nl = for_stage_0_2 & (fsm_output[1]);
  assign for_mux_1_rmff = MUX_s_1_2_2(reg_dout_rsci_oswt_tmp, and_14_nl, run_wen);
  assign nl_for_i_11_0_sva_1_mx1w0 = for_i_11_0_sva + 12'b000000000001;
  assign for_i_11_0_sva_1_mx1w0 = nl_for_i_11_0_sva_1_mx1w0[11:0];
  always @(posedge clk) begin
    if ( rst ) begin
      reg_din_rsci_oswt_tmp <= 1'b0;
      reg_dout_rsci_oswt_tmp <= 1'b0;
      run_wen <= 1'b1;
    end
    else begin
      reg_din_rsci_oswt_tmp <= for_mux_rmff;
      reg_dout_rsci_oswt_tmp <= for_mux_1_rmff;
      run_wen <= run_wen_rtff;
    end
  end
  always @(posedge clk) begin
    if ( run_wen & (~((~ for_stage_0_2) | (fsm_output[0]))) ) begin
      dout_rsci_idat <= ~(MUX_v_8_2_2(for_for_nor_nl, 8'b11111111, (for_for_if_slc_for_for_if_for_for_if_mul_47_22_psp_sva_1[25])));
    end
  end
  always @(posedge clk) begin
    if ( run_wen ) begin
      for_i_11_0_sva <= MUX_v_12_2_2(12'b000000000000, for_i_mux_1_nl, (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_for_if_slc_for_for_if_for_for_if_mul_47_22_psp_sva_1 <= 26'b00000000000000000000000000;
      for_stage_0 <= 1'b0;
      for_stage_0_2 <= 1'b0;
    end
    else if ( run_wen ) begin
      for_for_if_slc_for_for_if_for_for_if_mul_47_22_psp_sva_1 <= readslicef_48_26_22(for_for_if_for_for_if_mul_nl);
      for_stage_0 <= for_for_if_for_nand_cse;
      for_stage_0_2 <= for_stage_0 & (fsm_output[1]);
    end
  end
  assign for_for_else_2_else_and_nl = (for_for_if_slc_for_for_if_for_for_if_mul_47_22_psp_sva_1[7])
      & ((for_for_if_slc_for_for_if_for_for_if_mul_47_22_psp_sva_1[0]) | (for_for_if_slc_for_for_if_for_for_if_mul_47_22_psp_sva_1[1])
      | (for_for_if_slc_for_for_if_for_for_if_mul_47_22_psp_sva_1[2]) | (for_for_if_slc_for_for_if_for_for_if_mul_47_22_psp_sva_1[3])
      | (for_for_if_slc_for_for_if_for_for_if_mul_47_22_psp_sva_1[4]) | (for_for_if_slc_for_for_if_for_for_if_mul_47_22_psp_sva_1[5])
      | (for_for_if_slc_for_for_if_for_for_if_mul_47_22_psp_sva_1[6]) | (for_for_if_slc_for_for_if_for_for_if_mul_47_22_psp_sva_1[8]));
  assign nl_for_for_else_2_else_acc_nl = (for_for_if_slc_for_for_if_for_for_if_mul_47_22_psp_sva_1[15:8])
      + conv_u2s_1_8(for_for_else_2_else_and_nl);
  assign for_for_else_2_else_acc_nl = nl_for_for_else_2_else_acc_nl[7:0];
  assign for_for_nor_nl = ~(MUX_v_8_2_2(for_for_else_2_else_acc_nl, 8'b11111111,
      (16'b1111111100000000 < (for_for_if_slc_for_for_if_for_for_if_mul_47_22_psp_sva_1[24:0]))));
  assign nl_for_for_if_for_for_if_mul_nl = $signed(23'b01000001001010001100111) *
      $signed((din_rsci_idat_mxwt));
  assign for_for_if_for_for_if_mul_nl = nl_for_for_if_for_for_if_mul_nl[47:0];
  assign for_i_mux_1_nl = MUX_v_12_2_2(for_i_11_0_sva, for_i_11_0_sva_1_mx1w0, for_stage_0);

  function automatic  MUX_s_1_2_2;
    input  input_0;
    input  input_1;
    input  sel;
    reg  result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function automatic [11:0] MUX_v_12_2_2;
    input [11:0] input_0;
    input [11:0] input_1;
    input  sel;
    reg [11:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_12_2_2 = result;
  end
  endfunction


  function automatic [7:0] MUX_v_8_2_2;
    input [7:0] input_0;
    input [7:0] input_1;
    input  sel;
    reg [7:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_8_2_2 = result;
  end
  endfunction


  function automatic [25:0] readslicef_48_26_22;
    input [47:0] vector;
    reg [47:0] tmp;
  begin
    tmp = vector >> 22;
    readslicef_48_26_22 = tmp[25:0];
  end
  endfunction


  function automatic [0:0] readslicef_5_1_4;
    input [4:0] vector;
    reg [4:0] tmp;
  begin
    tmp = vector >> 4;
    readslicef_5_1_4 = tmp[0:0];
  end
  endfunction


  function automatic [7:0] conv_u2s_1_8 ;
    input [0:0]  vector ;
  begin
    conv_u2s_1_8 = {{7{1'b0}}, vector};
  end
  endfunction


  function automatic [4:0] conv_u2s_4_5 ;
    input [3:0]  vector ;
  begin
    conv_u2s_4_5 =  {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1
    (
  clk, rst, AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_dat, AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_vld,
      AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_rdy
);
  input clk;
  input rst;
  output [31:0] AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_dat;
  output AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_vld;
  input AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_rdy;



  // Interconnect Declarations for Component Instantiations 
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_inst
      (
      .clk(clk),
      .rst(rst),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_dat(AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_dat),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_vld(AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_vld),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_rdy(AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_rdy)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1
    (
  clk, rst, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_dat, AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_vld,
      AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_rdy
);
  input clk;
  input rst;
  output [287:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_dat;
  output AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_vld;
  input AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_rdy;



  // Interconnect Declarations for Component Instantiations 
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_core_inst
      (
      .clk(clk),
      .rst(rst),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_dat(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_dat),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_vld(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_vld),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_rdy(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_rdy)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4
    (
  clk, rst, din_rsc_dat, din_rsc_vld, din_rsc_rdy, dout_rsc_dat, dout_rsc_vld, dout_rsc_rdy
);
  input clk;
  input rst;
  input [31:0] din_rsc_dat;
  input din_rsc_vld;
  output din_rsc_rdy;
  output [107:0] dout_rsc_dat;
  output dout_rsc_vld;
  input dout_rsc_rdy;



  // Interconnect Declarations for Component Instantiations 
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4_run_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsc_dat(din_rsc_dat),
      .din_rsc_vld(din_rsc_vld),
      .din_rsc_rdy(din_rsc_rdy),
      .dout_rsc_dat(dout_rsc_dat),
      .dout_rsc_vld(dout_rsc_vld),
      .dout_rsc_rdy(dout_rsc_rdy)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4
    (
  clk, rst, din_rsc_dat, din_rsc_vld, din_rsc_rdy, kernelIn_rsc_dat, kernelIn_rsc_vld,
      kernelIn_rsc_rdy, dout_rsc_dat, dout_rsc_vld, dout_rsc_rdy
);
  input clk;
  input rst;
  input [107:0] din_rsc_dat;
  input din_rsc_vld;
  output din_rsc_rdy;
  input [287:0] kernelIn_rsc_dat;
  input kernelIn_rsc_vld;
  output kernelIn_rsc_rdy;
  output [22:0] dout_rsc_dat;
  output dout_rsc_vld;
  input dout_rsc_rdy;


  // Interconnect Declarations
  wire [7:0] KERNEL_X_acc_37_cmp_a;
  wire [8:0] KERNEL_X_acc_37_cmp_b;
  wire [7:0] KERNEL_X_acc_37_cmp_c;
  wire [8:0] KERNEL_X_acc_37_cmp_d;
  wire [18:0] KERNEL_X_acc_37_cmp_z;
  wire [7:0] KERNEL_X_acc_37_cmp_1_a;
  wire [8:0] KERNEL_X_acc_37_cmp_1_b;
  wire [7:0] KERNEL_X_acc_37_cmp_1_c;
  wire [8:0] KERNEL_X_acc_37_cmp_1_d;
  wire [18:0] KERNEL_X_acc_37_cmp_1_z;
  wire [7:0] KERNEL_X_acc_37_cmp_2_a;
  wire [8:0] KERNEL_X_acc_37_cmp_2_b;
  wire [7:0] KERNEL_X_acc_37_cmp_2_c;
  wire [8:0] KERNEL_X_acc_37_cmp_2_d;
  wire [18:0] KERNEL_X_acc_37_cmp_2_z;
  wire [7:0] KERNEL_X_acc_37_cmp_3_a;
  wire [8:0] KERNEL_X_acc_37_cmp_3_b;
  wire [7:0] KERNEL_X_acc_37_cmp_3_c;
  wire [8:0] KERNEL_X_acc_37_cmp_3_d;
  wire [18:0] KERNEL_X_acc_37_cmp_3_z;
  wire [7:0] KERNEL_X_acc_37_cmp_4_a;
  wire [8:0] KERNEL_X_acc_37_cmp_4_b;
  wire [7:0] KERNEL_X_acc_37_cmp_4_c;
  wire [8:0] KERNEL_X_acc_37_cmp_4_d;
  wire [18:0] KERNEL_X_acc_37_cmp_4_z;
  wire [7:0] KERNEL_X_acc_37_cmp_5_a;
  wire [8:0] KERNEL_X_acc_37_cmp_5_b;
  wire [7:0] KERNEL_X_acc_37_cmp_5_c;
  wire [8:0] KERNEL_X_acc_37_cmp_5_d;
  wire [18:0] KERNEL_X_acc_37_cmp_5_z;
  wire [7:0] KERNEL_X_acc_37_cmp_6_a;
  wire [8:0] KERNEL_X_acc_37_cmp_6_b;
  wire [7:0] KERNEL_X_acc_37_cmp_6_c;
  wire [8:0] KERNEL_X_acc_37_cmp_6_d;
  wire [18:0] KERNEL_X_acc_37_cmp_6_z;
  wire [7:0] KERNEL_X_acc_37_cmp_7_a;
  wire [8:0] KERNEL_X_acc_37_cmp_7_b;
  wire [7:0] KERNEL_X_acc_37_cmp_7_c;
  wire [8:0] KERNEL_X_acc_37_cmp_7_d;
  wire [18:0] KERNEL_X_acc_37_cmp_7_z;
  wire [7:0] KERNEL_X_acc_37_cmp_8_a;
  wire [8:0] KERNEL_X_acc_37_cmp_8_b;
  wire [7:0] KERNEL_X_acc_37_cmp_8_c;
  wire [8:0] KERNEL_X_acc_37_cmp_8_d;
  wire [18:0] KERNEL_X_acc_37_cmp_8_z;
  wire [7:0] KERNEL_X_acc_37_cmp_9_a;
  wire [8:0] KERNEL_X_acc_37_cmp_9_b;
  wire [7:0] KERNEL_X_acc_37_cmp_9_c;
  wire [8:0] KERNEL_X_acc_37_cmp_9_d;
  wire [18:0] KERNEL_X_acc_37_cmp_9_z;
  wire [7:0] KERNEL_X_acc_37_cmp_10_a;
  wire [8:0] KERNEL_X_acc_37_cmp_10_b;
  wire [7:0] KERNEL_X_acc_37_cmp_10_c;
  wire [8:0] KERNEL_X_acc_37_cmp_10_d;
  wire [18:0] KERNEL_X_acc_37_cmp_10_z;
  wire [7:0] KERNEL_X_acc_37_cmp_11_a;
  wire [8:0] KERNEL_X_acc_37_cmp_11_b;
  wire [7:0] KERNEL_X_acc_37_cmp_11_c;
  wire [8:0] KERNEL_X_acc_37_cmp_11_d;
  wire [18:0] KERNEL_X_acc_37_cmp_11_z;
  wire [7:0] KERNEL_X_acc_37_cmp_12_a;
  wire [8:0] KERNEL_X_acc_37_cmp_12_b;
  wire [7:0] KERNEL_X_acc_37_cmp_12_c;
  wire [8:0] KERNEL_X_acc_37_cmp_12_d;
  wire [18:0] KERNEL_X_acc_37_cmp_12_z;
  wire [7:0] KERNEL_X_acc_37_cmp_13_a;
  wire [8:0] KERNEL_X_acc_37_cmp_13_b;
  wire [7:0] KERNEL_X_acc_37_cmp_13_c;
  wire [8:0] KERNEL_X_acc_37_cmp_13_d;
  wire [18:0] KERNEL_X_acc_37_cmp_13_z;
  wire [7:0] KERNEL_X_acc_37_cmp_14_a;
  wire [8:0] KERNEL_X_acc_37_cmp_14_b;
  wire [7:0] KERNEL_X_acc_37_cmp_14_c;
  wire [8:0] KERNEL_X_acc_37_cmp_14_d;
  wire [18:0] KERNEL_X_acc_37_cmp_14_z;
  wire [7:0] KERNEL_X_acc_37_cmp_15_a;
  wire [8:0] KERNEL_X_acc_37_cmp_15_b;
  wire [7:0] KERNEL_X_acc_37_cmp_15_c;
  wire [8:0] KERNEL_X_acc_37_cmp_15_d;
  wire [18:0] KERNEL_X_acc_37_cmp_15_z;
  wire [7:0] KERNEL_X_acc_37_cmp_16_a;
  wire [8:0] KERNEL_X_acc_37_cmp_16_b;
  wire [7:0] KERNEL_X_acc_37_cmp_16_c;
  wire [8:0] KERNEL_X_acc_37_cmp_16_d;
  wire [18:0] KERNEL_X_acc_37_cmp_16_z;
  wire [7:0] KERNEL_X_acc_37_cmp_17_a;
  wire [8:0] KERNEL_X_acc_37_cmp_17_b;
  wire [7:0] KERNEL_X_acc_37_cmp_17_c;
  wire [8:0] KERNEL_X_acc_37_cmp_17_d;
  wire [18:0] KERNEL_X_acc_37_cmp_17_z;


  // Interconnect Declarations for Component Instantiations 
  mgc_mul2add1 #(.gentype(32'sd1),
  .width_a(32'sd8),
  .signd_a(32'sd1),
  .width_b(32'sd9),
  .signd_b(32'sd1),
  .width_c(32'sd8),
  .signd_c(32'sd1),
  .width_d(32'sd9),
  .signd_d(32'sd1),
  .width_e(32'sd1),
  .signd_e(32'sd0),
  .width_b2(32'sd0),
  .signd_b2(32'sd0),
  .width_d2(32'sd0),
  .signd_d2(32'sd0),
  .width_z(32'sd19),
  .isadd(32'sd1),
  .add_b2(32'sd1),
  .add_d2(32'sd1),
  .use_const(32'sd0)) KERNEL_X_acc_37_cmp (
      .a(KERNEL_X_acc_37_cmp_a),
      .b(KERNEL_X_acc_37_cmp_b),
      .c(KERNEL_X_acc_37_cmp_c),
      .d(KERNEL_X_acc_37_cmp_d),
      .cst(1'b0),
      .z(KERNEL_X_acc_37_cmp_z)
    );
  mgc_mul2add1 #(.gentype(32'sd1),
  .width_a(32'sd8),
  .signd_a(32'sd1),
  .width_b(32'sd9),
  .signd_b(32'sd1),
  .width_c(32'sd8),
  .signd_c(32'sd1),
  .width_d(32'sd9),
  .signd_d(32'sd1),
  .width_e(32'sd1),
  .signd_e(32'sd0),
  .width_b2(32'sd0),
  .signd_b2(32'sd0),
  .width_d2(32'sd0),
  .signd_d2(32'sd0),
  .width_z(32'sd19),
  .isadd(32'sd1),
  .add_b2(32'sd1),
  .add_d2(32'sd1),
  .use_const(32'sd0)) KERNEL_X_acc_37_cmp_1 (
      .a(KERNEL_X_acc_37_cmp_1_a),
      .b(KERNEL_X_acc_37_cmp_1_b),
      .c(KERNEL_X_acc_37_cmp_1_c),
      .d(KERNEL_X_acc_37_cmp_1_d),
      .cst(1'b0),
      .z(KERNEL_X_acc_37_cmp_1_z)
    );
  mgc_mul2add1 #(.gentype(32'sd1),
  .width_a(32'sd8),
  .signd_a(32'sd1),
  .width_b(32'sd9),
  .signd_b(32'sd1),
  .width_c(32'sd8),
  .signd_c(32'sd1),
  .width_d(32'sd9),
  .signd_d(32'sd1),
  .width_e(32'sd1),
  .signd_e(32'sd0),
  .width_b2(32'sd0),
  .signd_b2(32'sd0),
  .width_d2(32'sd0),
  .signd_d2(32'sd0),
  .width_z(32'sd19),
  .isadd(32'sd1),
  .add_b2(32'sd1),
  .add_d2(32'sd1),
  .use_const(32'sd0)) KERNEL_X_acc_37_cmp_2 (
      .a(KERNEL_X_acc_37_cmp_2_a),
      .b(KERNEL_X_acc_37_cmp_2_b),
      .c(KERNEL_X_acc_37_cmp_2_c),
      .d(KERNEL_X_acc_37_cmp_2_d),
      .cst(1'b0),
      .z(KERNEL_X_acc_37_cmp_2_z)
    );
  mgc_mul2add1 #(.gentype(32'sd1),
  .width_a(32'sd8),
  .signd_a(32'sd1),
  .width_b(32'sd9),
  .signd_b(32'sd1),
  .width_c(32'sd8),
  .signd_c(32'sd1),
  .width_d(32'sd9),
  .signd_d(32'sd1),
  .width_e(32'sd1),
  .signd_e(32'sd0),
  .width_b2(32'sd0),
  .signd_b2(32'sd0),
  .width_d2(32'sd0),
  .signd_d2(32'sd0),
  .width_z(32'sd19),
  .isadd(32'sd1),
  .add_b2(32'sd1),
  .add_d2(32'sd1),
  .use_const(32'sd0)) KERNEL_X_acc_37_cmp_3 (
      .a(KERNEL_X_acc_37_cmp_3_a),
      .b(KERNEL_X_acc_37_cmp_3_b),
      .c(KERNEL_X_acc_37_cmp_3_c),
      .d(KERNEL_X_acc_37_cmp_3_d),
      .cst(1'b0),
      .z(KERNEL_X_acc_37_cmp_3_z)
    );
  mgc_mul2add1 #(.gentype(32'sd1),
  .width_a(32'sd8),
  .signd_a(32'sd1),
  .width_b(32'sd9),
  .signd_b(32'sd1),
  .width_c(32'sd8),
  .signd_c(32'sd1),
  .width_d(32'sd9),
  .signd_d(32'sd1),
  .width_e(32'sd1),
  .signd_e(32'sd0),
  .width_b2(32'sd0),
  .signd_b2(32'sd0),
  .width_d2(32'sd0),
  .signd_d2(32'sd0),
  .width_z(32'sd19),
  .isadd(32'sd1),
  .add_b2(32'sd1),
  .add_d2(32'sd1),
  .use_const(32'sd0)) KERNEL_X_acc_37_cmp_4 (
      .a(KERNEL_X_acc_37_cmp_4_a),
      .b(KERNEL_X_acc_37_cmp_4_b),
      .c(KERNEL_X_acc_37_cmp_4_c),
      .d(KERNEL_X_acc_37_cmp_4_d),
      .cst(1'b0),
      .z(KERNEL_X_acc_37_cmp_4_z)
    );
  mgc_mul2add1 #(.gentype(32'sd1),
  .width_a(32'sd8),
  .signd_a(32'sd1),
  .width_b(32'sd9),
  .signd_b(32'sd1),
  .width_c(32'sd8),
  .signd_c(32'sd1),
  .width_d(32'sd9),
  .signd_d(32'sd1),
  .width_e(32'sd1),
  .signd_e(32'sd0),
  .width_b2(32'sd0),
  .signd_b2(32'sd0),
  .width_d2(32'sd0),
  .signd_d2(32'sd0),
  .width_z(32'sd19),
  .isadd(32'sd1),
  .add_b2(32'sd1),
  .add_d2(32'sd1),
  .use_const(32'sd0)) KERNEL_X_acc_37_cmp_5 (
      .a(KERNEL_X_acc_37_cmp_5_a),
      .b(KERNEL_X_acc_37_cmp_5_b),
      .c(KERNEL_X_acc_37_cmp_5_c),
      .d(KERNEL_X_acc_37_cmp_5_d),
      .cst(1'b0),
      .z(KERNEL_X_acc_37_cmp_5_z)
    );
  mgc_mul2add1 #(.gentype(32'sd1),
  .width_a(32'sd8),
  .signd_a(32'sd1),
  .width_b(32'sd9),
  .signd_b(32'sd1),
  .width_c(32'sd8),
  .signd_c(32'sd1),
  .width_d(32'sd9),
  .signd_d(32'sd1),
  .width_e(32'sd1),
  .signd_e(32'sd0),
  .width_b2(32'sd0),
  .signd_b2(32'sd0),
  .width_d2(32'sd0),
  .signd_d2(32'sd0),
  .width_z(32'sd19),
  .isadd(32'sd1),
  .add_b2(32'sd1),
  .add_d2(32'sd1),
  .use_const(32'sd0)) KERNEL_X_acc_37_cmp_6 (
      .a(KERNEL_X_acc_37_cmp_6_a),
      .b(KERNEL_X_acc_37_cmp_6_b),
      .c(KERNEL_X_acc_37_cmp_6_c),
      .d(KERNEL_X_acc_37_cmp_6_d),
      .cst(1'b0),
      .z(KERNEL_X_acc_37_cmp_6_z)
    );
  mgc_mul2add1 #(.gentype(32'sd1),
  .width_a(32'sd8),
  .signd_a(32'sd1),
  .width_b(32'sd9),
  .signd_b(32'sd1),
  .width_c(32'sd8),
  .signd_c(32'sd1),
  .width_d(32'sd9),
  .signd_d(32'sd1),
  .width_e(32'sd1),
  .signd_e(32'sd0),
  .width_b2(32'sd0),
  .signd_b2(32'sd0),
  .width_d2(32'sd0),
  .signd_d2(32'sd0),
  .width_z(32'sd19),
  .isadd(32'sd1),
  .add_b2(32'sd1),
  .add_d2(32'sd1),
  .use_const(32'sd0)) KERNEL_X_acc_37_cmp_7 (
      .a(KERNEL_X_acc_37_cmp_7_a),
      .b(KERNEL_X_acc_37_cmp_7_b),
      .c(KERNEL_X_acc_37_cmp_7_c),
      .d(KERNEL_X_acc_37_cmp_7_d),
      .cst(1'b0),
      .z(KERNEL_X_acc_37_cmp_7_z)
    );
  mgc_mul2add1 #(.gentype(32'sd1),
  .width_a(32'sd8),
  .signd_a(32'sd1),
  .width_b(32'sd9),
  .signd_b(32'sd1),
  .width_c(32'sd8),
  .signd_c(32'sd1),
  .width_d(32'sd9),
  .signd_d(32'sd1),
  .width_e(32'sd1),
  .signd_e(32'sd0),
  .width_b2(32'sd0),
  .signd_b2(32'sd0),
  .width_d2(32'sd0),
  .signd_d2(32'sd0),
  .width_z(32'sd19),
  .isadd(32'sd1),
  .add_b2(32'sd1),
  .add_d2(32'sd1),
  .use_const(32'sd0)) KERNEL_X_acc_37_cmp_8 (
      .a(KERNEL_X_acc_37_cmp_8_a),
      .b(KERNEL_X_acc_37_cmp_8_b),
      .c(KERNEL_X_acc_37_cmp_8_c),
      .d(KERNEL_X_acc_37_cmp_8_d),
      .cst(1'b0),
      .z(KERNEL_X_acc_37_cmp_8_z)
    );
  mgc_mul2add1 #(.gentype(32'sd1),
  .width_a(32'sd8),
  .signd_a(32'sd1),
  .width_b(32'sd9),
  .signd_b(32'sd1),
  .width_c(32'sd8),
  .signd_c(32'sd1),
  .width_d(32'sd9),
  .signd_d(32'sd1),
  .width_e(32'sd1),
  .signd_e(32'sd0),
  .width_b2(32'sd0),
  .signd_b2(32'sd0),
  .width_d2(32'sd0),
  .signd_d2(32'sd0),
  .width_z(32'sd19),
  .isadd(32'sd1),
  .add_b2(32'sd1),
  .add_d2(32'sd1),
  .use_const(32'sd0)) KERNEL_X_acc_37_cmp_9 (
      .a(KERNEL_X_acc_37_cmp_9_a),
      .b(KERNEL_X_acc_37_cmp_9_b),
      .c(KERNEL_X_acc_37_cmp_9_c),
      .d(KERNEL_X_acc_37_cmp_9_d),
      .cst(1'b0),
      .z(KERNEL_X_acc_37_cmp_9_z)
    );
  mgc_mul2add1 #(.gentype(32'sd1),
  .width_a(32'sd8),
  .signd_a(32'sd1),
  .width_b(32'sd9),
  .signd_b(32'sd1),
  .width_c(32'sd8),
  .signd_c(32'sd1),
  .width_d(32'sd9),
  .signd_d(32'sd1),
  .width_e(32'sd1),
  .signd_e(32'sd0),
  .width_b2(32'sd0),
  .signd_b2(32'sd0),
  .width_d2(32'sd0),
  .signd_d2(32'sd0),
  .width_z(32'sd19),
  .isadd(32'sd1),
  .add_b2(32'sd1),
  .add_d2(32'sd1),
  .use_const(32'sd0)) KERNEL_X_acc_37_cmp_10 (
      .a(KERNEL_X_acc_37_cmp_10_a),
      .b(KERNEL_X_acc_37_cmp_10_b),
      .c(KERNEL_X_acc_37_cmp_10_c),
      .d(KERNEL_X_acc_37_cmp_10_d),
      .cst(1'b0),
      .z(KERNEL_X_acc_37_cmp_10_z)
    );
  mgc_mul2add1 #(.gentype(32'sd1),
  .width_a(32'sd8),
  .signd_a(32'sd1),
  .width_b(32'sd9),
  .signd_b(32'sd1),
  .width_c(32'sd8),
  .signd_c(32'sd1),
  .width_d(32'sd9),
  .signd_d(32'sd1),
  .width_e(32'sd1),
  .signd_e(32'sd0),
  .width_b2(32'sd0),
  .signd_b2(32'sd0),
  .width_d2(32'sd0),
  .signd_d2(32'sd0),
  .width_z(32'sd19),
  .isadd(32'sd1),
  .add_b2(32'sd1),
  .add_d2(32'sd1),
  .use_const(32'sd0)) KERNEL_X_acc_37_cmp_11 (
      .a(KERNEL_X_acc_37_cmp_11_a),
      .b(KERNEL_X_acc_37_cmp_11_b),
      .c(KERNEL_X_acc_37_cmp_11_c),
      .d(KERNEL_X_acc_37_cmp_11_d),
      .cst(1'b0),
      .z(KERNEL_X_acc_37_cmp_11_z)
    );
  mgc_mul2add1 #(.gentype(32'sd1),
  .width_a(32'sd8),
  .signd_a(32'sd1),
  .width_b(32'sd9),
  .signd_b(32'sd1),
  .width_c(32'sd8),
  .signd_c(32'sd1),
  .width_d(32'sd9),
  .signd_d(32'sd1),
  .width_e(32'sd1),
  .signd_e(32'sd0),
  .width_b2(32'sd0),
  .signd_b2(32'sd0),
  .width_d2(32'sd0),
  .signd_d2(32'sd0),
  .width_z(32'sd19),
  .isadd(32'sd1),
  .add_b2(32'sd1),
  .add_d2(32'sd1),
  .use_const(32'sd0)) KERNEL_X_acc_37_cmp_12 (
      .a(KERNEL_X_acc_37_cmp_12_a),
      .b(KERNEL_X_acc_37_cmp_12_b),
      .c(KERNEL_X_acc_37_cmp_12_c),
      .d(KERNEL_X_acc_37_cmp_12_d),
      .cst(1'b0),
      .z(KERNEL_X_acc_37_cmp_12_z)
    );
  mgc_mul2add1 #(.gentype(32'sd1),
  .width_a(32'sd8),
  .signd_a(32'sd1),
  .width_b(32'sd9),
  .signd_b(32'sd1),
  .width_c(32'sd8),
  .signd_c(32'sd1),
  .width_d(32'sd9),
  .signd_d(32'sd1),
  .width_e(32'sd1),
  .signd_e(32'sd0),
  .width_b2(32'sd0),
  .signd_b2(32'sd0),
  .width_d2(32'sd0),
  .signd_d2(32'sd0),
  .width_z(32'sd19),
  .isadd(32'sd1),
  .add_b2(32'sd1),
  .add_d2(32'sd1),
  .use_const(32'sd0)) KERNEL_X_acc_37_cmp_13 (
      .a(KERNEL_X_acc_37_cmp_13_a),
      .b(KERNEL_X_acc_37_cmp_13_b),
      .c(KERNEL_X_acc_37_cmp_13_c),
      .d(KERNEL_X_acc_37_cmp_13_d),
      .cst(1'b0),
      .z(KERNEL_X_acc_37_cmp_13_z)
    );
  mgc_mul2add1 #(.gentype(32'sd1),
  .width_a(32'sd8),
  .signd_a(32'sd1),
  .width_b(32'sd9),
  .signd_b(32'sd1),
  .width_c(32'sd8),
  .signd_c(32'sd1),
  .width_d(32'sd9),
  .signd_d(32'sd1),
  .width_e(32'sd1),
  .signd_e(32'sd0),
  .width_b2(32'sd0),
  .signd_b2(32'sd0),
  .width_d2(32'sd0),
  .signd_d2(32'sd0),
  .width_z(32'sd19),
  .isadd(32'sd1),
  .add_b2(32'sd1),
  .add_d2(32'sd1),
  .use_const(32'sd0)) KERNEL_X_acc_37_cmp_14 (
      .a(KERNEL_X_acc_37_cmp_14_a),
      .b(KERNEL_X_acc_37_cmp_14_b),
      .c(KERNEL_X_acc_37_cmp_14_c),
      .d(KERNEL_X_acc_37_cmp_14_d),
      .cst(1'b0),
      .z(KERNEL_X_acc_37_cmp_14_z)
    );
  mgc_mul2add1 #(.gentype(32'sd1),
  .width_a(32'sd8),
  .signd_a(32'sd1),
  .width_b(32'sd9),
  .signd_b(32'sd1),
  .width_c(32'sd8),
  .signd_c(32'sd1),
  .width_d(32'sd9),
  .signd_d(32'sd1),
  .width_e(32'sd1),
  .signd_e(32'sd0),
  .width_b2(32'sd0),
  .signd_b2(32'sd0),
  .width_d2(32'sd0),
  .signd_d2(32'sd0),
  .width_z(32'sd19),
  .isadd(32'sd1),
  .add_b2(32'sd1),
  .add_d2(32'sd1),
  .use_const(32'sd0)) KERNEL_X_acc_37_cmp_15 (
      .a(KERNEL_X_acc_37_cmp_15_a),
      .b(KERNEL_X_acc_37_cmp_15_b),
      .c(KERNEL_X_acc_37_cmp_15_c),
      .d(KERNEL_X_acc_37_cmp_15_d),
      .cst(1'b0),
      .z(KERNEL_X_acc_37_cmp_15_z)
    );
  mgc_mul2add1 #(.gentype(32'sd1),
  .width_a(32'sd8),
  .signd_a(32'sd1),
  .width_b(32'sd9),
  .signd_b(32'sd1),
  .width_c(32'sd8),
  .signd_c(32'sd1),
  .width_d(32'sd9),
  .signd_d(32'sd1),
  .width_e(32'sd1),
  .signd_e(32'sd0),
  .width_b2(32'sd0),
  .signd_b2(32'sd0),
  .width_d2(32'sd0),
  .signd_d2(32'sd0),
  .width_z(32'sd19),
  .isadd(32'sd1),
  .add_b2(32'sd1),
  .add_d2(32'sd1),
  .use_const(32'sd0)) KERNEL_X_acc_37_cmp_16 (
      .a(KERNEL_X_acc_37_cmp_16_a),
      .b(KERNEL_X_acc_37_cmp_16_b),
      .c(KERNEL_X_acc_37_cmp_16_c),
      .d(KERNEL_X_acc_37_cmp_16_d),
      .cst(1'b0),
      .z(KERNEL_X_acc_37_cmp_16_z)
    );
  mgc_mul2add1 #(.gentype(32'sd1),
  .width_a(32'sd8),
  .signd_a(32'sd1),
  .width_b(32'sd9),
  .signd_b(32'sd1),
  .width_c(32'sd8),
  .signd_c(32'sd1),
  .width_d(32'sd9),
  .signd_d(32'sd1),
  .width_e(32'sd1),
  .signd_e(32'sd0),
  .width_b2(32'sd0),
  .signd_b2(32'sd0),
  .width_d2(32'sd0),
  .signd_d2(32'sd0),
  .width_z(32'sd19),
  .isadd(32'sd1),
  .add_b2(32'sd1),
  .add_d2(32'sd1),
  .use_const(32'sd0)) KERNEL_X_acc_37_cmp_17 (
      .a(KERNEL_X_acc_37_cmp_17_a),
      .b(KERNEL_X_acc_37_cmp_17_b),
      .c(KERNEL_X_acc_37_cmp_17_c),
      .d(KERNEL_X_acc_37_cmp_17_d),
      .cst(1'b0),
      .z(KERNEL_X_acc_37_cmp_17_z)
    );
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run
      branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4_run_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsc_dat(din_rsc_dat),
      .din_rsc_vld(din_rsc_vld),
      .din_rsc_rdy(din_rsc_rdy),
      .kernelIn_rsc_dat(kernelIn_rsc_dat),
      .kernelIn_rsc_vld(kernelIn_rsc_vld),
      .kernelIn_rsc_rdy(kernelIn_rsc_rdy),
      .dout_rsc_dat(dout_rsc_dat),
      .dout_rsc_vld(dout_rsc_vld),
      .dout_rsc_rdy(dout_rsc_rdy),
      .KERNEL_X_acc_37_cmp_a(KERNEL_X_acc_37_cmp_a),
      .KERNEL_X_acc_37_cmp_b(KERNEL_X_acc_37_cmp_b),
      .KERNEL_X_acc_37_cmp_c(KERNEL_X_acc_37_cmp_c),
      .KERNEL_X_acc_37_cmp_d(KERNEL_X_acc_37_cmp_d),
      .KERNEL_X_acc_37_cmp_z(KERNEL_X_acc_37_cmp_z),
      .KERNEL_X_acc_37_cmp_1_a(KERNEL_X_acc_37_cmp_1_a),
      .KERNEL_X_acc_37_cmp_1_b(KERNEL_X_acc_37_cmp_1_b),
      .KERNEL_X_acc_37_cmp_1_c(KERNEL_X_acc_37_cmp_1_c),
      .KERNEL_X_acc_37_cmp_1_d(KERNEL_X_acc_37_cmp_1_d),
      .KERNEL_X_acc_37_cmp_1_z(KERNEL_X_acc_37_cmp_1_z),
      .KERNEL_X_acc_37_cmp_2_a(KERNEL_X_acc_37_cmp_2_a),
      .KERNEL_X_acc_37_cmp_2_b(KERNEL_X_acc_37_cmp_2_b),
      .KERNEL_X_acc_37_cmp_2_c(KERNEL_X_acc_37_cmp_2_c),
      .KERNEL_X_acc_37_cmp_2_d(KERNEL_X_acc_37_cmp_2_d),
      .KERNEL_X_acc_37_cmp_2_z(KERNEL_X_acc_37_cmp_2_z),
      .KERNEL_X_acc_37_cmp_3_a(KERNEL_X_acc_37_cmp_3_a),
      .KERNEL_X_acc_37_cmp_3_b(KERNEL_X_acc_37_cmp_3_b),
      .KERNEL_X_acc_37_cmp_3_c(KERNEL_X_acc_37_cmp_3_c),
      .KERNEL_X_acc_37_cmp_3_d(KERNEL_X_acc_37_cmp_3_d),
      .KERNEL_X_acc_37_cmp_3_z(KERNEL_X_acc_37_cmp_3_z),
      .KERNEL_X_acc_37_cmp_4_a(KERNEL_X_acc_37_cmp_4_a),
      .KERNEL_X_acc_37_cmp_4_b(KERNEL_X_acc_37_cmp_4_b),
      .KERNEL_X_acc_37_cmp_4_c(KERNEL_X_acc_37_cmp_4_c),
      .KERNEL_X_acc_37_cmp_4_d(KERNEL_X_acc_37_cmp_4_d),
      .KERNEL_X_acc_37_cmp_4_z(KERNEL_X_acc_37_cmp_4_z),
      .KERNEL_X_acc_37_cmp_5_a(KERNEL_X_acc_37_cmp_5_a),
      .KERNEL_X_acc_37_cmp_5_b(KERNEL_X_acc_37_cmp_5_b),
      .KERNEL_X_acc_37_cmp_5_c(KERNEL_X_acc_37_cmp_5_c),
      .KERNEL_X_acc_37_cmp_5_d(KERNEL_X_acc_37_cmp_5_d),
      .KERNEL_X_acc_37_cmp_5_z(KERNEL_X_acc_37_cmp_5_z),
      .KERNEL_X_acc_37_cmp_6_a(KERNEL_X_acc_37_cmp_6_a),
      .KERNEL_X_acc_37_cmp_6_b(KERNEL_X_acc_37_cmp_6_b),
      .KERNEL_X_acc_37_cmp_6_c(KERNEL_X_acc_37_cmp_6_c),
      .KERNEL_X_acc_37_cmp_6_d(KERNEL_X_acc_37_cmp_6_d),
      .KERNEL_X_acc_37_cmp_6_z(KERNEL_X_acc_37_cmp_6_z),
      .KERNEL_X_acc_37_cmp_7_a(KERNEL_X_acc_37_cmp_7_a),
      .KERNEL_X_acc_37_cmp_7_b(KERNEL_X_acc_37_cmp_7_b),
      .KERNEL_X_acc_37_cmp_7_c(KERNEL_X_acc_37_cmp_7_c),
      .KERNEL_X_acc_37_cmp_7_d(KERNEL_X_acc_37_cmp_7_d),
      .KERNEL_X_acc_37_cmp_7_z(KERNEL_X_acc_37_cmp_7_z),
      .KERNEL_X_acc_37_cmp_8_a(KERNEL_X_acc_37_cmp_8_a),
      .KERNEL_X_acc_37_cmp_8_b(KERNEL_X_acc_37_cmp_8_b),
      .KERNEL_X_acc_37_cmp_8_c(KERNEL_X_acc_37_cmp_8_c),
      .KERNEL_X_acc_37_cmp_8_d(KERNEL_X_acc_37_cmp_8_d),
      .KERNEL_X_acc_37_cmp_8_z(KERNEL_X_acc_37_cmp_8_z),
      .KERNEL_X_acc_37_cmp_9_a(KERNEL_X_acc_37_cmp_9_a),
      .KERNEL_X_acc_37_cmp_9_b(KERNEL_X_acc_37_cmp_9_b),
      .KERNEL_X_acc_37_cmp_9_c(KERNEL_X_acc_37_cmp_9_c),
      .KERNEL_X_acc_37_cmp_9_d(KERNEL_X_acc_37_cmp_9_d),
      .KERNEL_X_acc_37_cmp_9_z(KERNEL_X_acc_37_cmp_9_z),
      .KERNEL_X_acc_37_cmp_10_a(KERNEL_X_acc_37_cmp_10_a),
      .KERNEL_X_acc_37_cmp_10_b(KERNEL_X_acc_37_cmp_10_b),
      .KERNEL_X_acc_37_cmp_10_c(KERNEL_X_acc_37_cmp_10_c),
      .KERNEL_X_acc_37_cmp_10_d(KERNEL_X_acc_37_cmp_10_d),
      .KERNEL_X_acc_37_cmp_10_z(KERNEL_X_acc_37_cmp_10_z),
      .KERNEL_X_acc_37_cmp_11_a(KERNEL_X_acc_37_cmp_11_a),
      .KERNEL_X_acc_37_cmp_11_b(KERNEL_X_acc_37_cmp_11_b),
      .KERNEL_X_acc_37_cmp_11_c(KERNEL_X_acc_37_cmp_11_c),
      .KERNEL_X_acc_37_cmp_11_d(KERNEL_X_acc_37_cmp_11_d),
      .KERNEL_X_acc_37_cmp_11_z(KERNEL_X_acc_37_cmp_11_z),
      .KERNEL_X_acc_37_cmp_12_a(KERNEL_X_acc_37_cmp_12_a),
      .KERNEL_X_acc_37_cmp_12_b(KERNEL_X_acc_37_cmp_12_b),
      .KERNEL_X_acc_37_cmp_12_c(KERNEL_X_acc_37_cmp_12_c),
      .KERNEL_X_acc_37_cmp_12_d(KERNEL_X_acc_37_cmp_12_d),
      .KERNEL_X_acc_37_cmp_12_z(KERNEL_X_acc_37_cmp_12_z),
      .KERNEL_X_acc_37_cmp_13_a(KERNEL_X_acc_37_cmp_13_a),
      .KERNEL_X_acc_37_cmp_13_b(KERNEL_X_acc_37_cmp_13_b),
      .KERNEL_X_acc_37_cmp_13_c(KERNEL_X_acc_37_cmp_13_c),
      .KERNEL_X_acc_37_cmp_13_d(KERNEL_X_acc_37_cmp_13_d),
      .KERNEL_X_acc_37_cmp_13_z(KERNEL_X_acc_37_cmp_13_z),
      .KERNEL_X_acc_37_cmp_14_a(KERNEL_X_acc_37_cmp_14_a),
      .KERNEL_X_acc_37_cmp_14_b(KERNEL_X_acc_37_cmp_14_b),
      .KERNEL_X_acc_37_cmp_14_c(KERNEL_X_acc_37_cmp_14_c),
      .KERNEL_X_acc_37_cmp_14_d(KERNEL_X_acc_37_cmp_14_d),
      .KERNEL_X_acc_37_cmp_14_z(KERNEL_X_acc_37_cmp_14_z),
      .KERNEL_X_acc_37_cmp_15_a(KERNEL_X_acc_37_cmp_15_a),
      .KERNEL_X_acc_37_cmp_15_b(KERNEL_X_acc_37_cmp_15_b),
      .KERNEL_X_acc_37_cmp_15_c(KERNEL_X_acc_37_cmp_15_c),
      .KERNEL_X_acc_37_cmp_15_d(KERNEL_X_acc_37_cmp_15_d),
      .KERNEL_X_acc_37_cmp_15_z(KERNEL_X_acc_37_cmp_15_z),
      .KERNEL_X_acc_37_cmp_16_a(KERNEL_X_acc_37_cmp_16_a),
      .KERNEL_X_acc_37_cmp_16_b(KERNEL_X_acc_37_cmp_16_b),
      .KERNEL_X_acc_37_cmp_16_c(KERNEL_X_acc_37_cmp_16_c),
      .KERNEL_X_acc_37_cmp_16_d(KERNEL_X_acc_37_cmp_16_d),
      .KERNEL_X_acc_37_cmp_16_z(KERNEL_X_acc_37_cmp_16_z),
      .KERNEL_X_acc_37_cmp_17_a(KERNEL_X_acc_37_cmp_17_a),
      .KERNEL_X_acc_37_cmp_17_b(KERNEL_X_acc_37_cmp_17_b),
      .KERNEL_X_acc_37_cmp_17_c(KERNEL_X_acc_37_cmp_17_c),
      .KERNEL_X_acc_37_cmp_17_d(KERNEL_X_acc_37_cmp_17_d),
      .KERNEL_X_acc_37_cmp_17_z(KERNEL_X_acc_37_cmp_17_z)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4
    (
  clk, rst, din_rsc_dat, din_rsc_vld, din_rsc_rdy, bias_rsc_dat, bias_rsc_vld, bias_rsc_rdy,
      dout_rsc_dat, dout_rsc_vld, dout_rsc_rdy
);
  input clk;
  input rst;
  input [22:0] din_rsc_dat;
  input din_rsc_vld;
  output din_rsc_rdy;
  input [31:0] bias_rsc_dat;
  input bias_rsc_vld;
  output bias_rsc_rdy;
  output [25:0] dout_rsc_dat;
  output dout_rsc_vld;
  input dout_rsc_rdy;



  // Interconnect Declarations for Component Instantiations 
  branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run
      branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4_run_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsc_dat(din_rsc_dat),
      .din_rsc_vld(din_rsc_vld),
      .din_rsc_rdy(din_rsc_rdy),
      .bias_rsc_dat(bias_rsc_dat),
      .bias_rsc_vld(bias_rsc_vld),
      .bias_rsc_rdy(bias_rsc_rdy),
      .dout_rsc_dat(dout_rsc_dat),
      .dout_rsc_vld(dout_rsc_vld),
      .dout_rsc_rdy(dout_rsc_rdy)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0
    (
  clk, rst, din_rsc_dat, din_rsc_vld, din_rsc_rdy, dout_rsc_dat, dout_rsc_vld, dout_rsc_rdy
);
  input clk;
  input rst;
  input [25:0] din_rsc_dat;
  input din_rsc_vld;
  output din_rsc_rdy;
  output [7:0] dout_rsc_dat;
  output dout_rsc_vld;
  input dout_rsc_rdy;



  // Interconnect Declarations for Component Instantiations 
  branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run
      branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0_run_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsc_dat(din_rsc_dat),
      .din_rsc_vld(din_rsc_vld),
      .din_rsc_rdy(din_rsc_rdy),
      .dout_rsc_dat(dout_rsc_dat),
      .dout_rsc_vld(dout_rsc_vld),
      .dout_rsc_rdy(dout_rsc_rdy)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_qconv2d_relu_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_4_1_1_0_4_24_24_4_3_1
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_qconv2d_relu_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_4_1_1_0_4_24_24_4_3_1
    (
  clk, rst, din_rsc_dat, din_rsc_vld, din_rsc_rdy, kernelIn_rsc_dat, kernelIn_rsc_vld,
      kernelIn_rsc_rdy, bias_rsc_dat, bias_rsc_vld, bias_rsc_rdy, dout_rsc_dat, dout_rsc_vld,
      dout_rsc_rdy
);
  input clk;
  input rst;
  input [31:0] din_rsc_dat;
  input din_rsc_vld;
  output din_rsc_rdy;
  input [287:0] kernelIn_rsc_dat;
  input kernelIn_rsc_vld;
  output kernelIn_rsc_rdy;
  input [31:0] bias_rsc_dat;
  input bias_rsc_vld;
  output bias_rsc_rdy;
  output [7:0] dout_rsc_dat;
  output dout_rsc_vld;
  input dout_rsc_rdy;


  // Interconnect Declarations
  wire [107:0] dout_rsc_dat_n_inst0;
  wire [22:0] dout_rsc_dat_n_inst1;
  wire [25:0] dout_rsc_dat_n_inst2;
  wire [7:0] dout_rsc_dat_n_inst3;
  wire din_rsc_rdy_n_inst0_bud;
  wire dout_rsc_vld_n_inst0_bud;
  wire din_rsc_rdy_n_inst1_bud;
  wire kernelIn_rsc_rdy_n_inst1_bud;
  wire dout_rsc_vld_n_inst1_bud;
  wire din_rsc_rdy_n_inst2_bud;
  wire bias_rsc_rdy_n_inst2_bud;
  wire dout_rsc_vld_n_inst2_bud;
  wire din_rsc_rdy_n_inst3_bud;
  wire dout_rsc_vld_n_inst3_bud;


  // Interconnect Declarations for Component Instantiations 
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_ib_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_9_9_true_AC_TRN_AC_WRAP_4_1_24_24_3_1_4
      inst0 (
      .clk(clk),
      .rst(rst),
      .din_rsc_dat(din_rsc_dat),
      .din_rsc_vld(din_rsc_vld),
      .din_rsc_rdy(din_rsc_rdy_n_inst0_bud),
      .dout_rsc_dat(dout_rsc_dat_n_inst0),
      .dout_rsc_vld(dout_rsc_vld_n_inst0_bud),
      .dout_rsc_rdy(din_rsc_rdy_n_inst1_bud)
    );
  branch_0_layer_0_qnn_conv2d_105273232_conv2d_pe_ac_fixed_9_9_true_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_23_23_true_AC_TRN_AC_WRAP_4_1_1_24_24_3_1_4_4
      inst1 (
      .clk(clk),
      .rst(rst),
      .din_rsc_dat(dout_rsc_dat_n_inst0),
      .din_rsc_vld(dout_rsc_vld_n_inst0_bud),
      .din_rsc_rdy(din_rsc_rdy_n_inst1_bud),
      .kernelIn_rsc_dat(kernelIn_rsc_dat),
      .kernelIn_rsc_vld(kernelIn_rsc_vld),
      .kernelIn_rsc_rdy(kernelIn_rsc_rdy_n_inst1_bud),
      .dout_rsc_dat(dout_rsc_dat_n_inst1),
      .dout_rsc_vld(dout_rsc_vld_n_inst1_bud),
      .dout_rsc_rdy(din_rsc_rdy_n_inst2_bud)
    );
  branch_0_layer_0_qnn_conv2d_105273232_psum_act_ac_fixed_23_23_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_26_26_true_AC_TRN_AC_WRAP_1_24_24_1_4
      inst2 (
      .clk(clk),
      .rst(rst),
      .din_rsc_dat(dout_rsc_dat_n_inst1),
      .din_rsc_vld(dout_rsc_vld_n_inst1_bud),
      .din_rsc_rdy(din_rsc_rdy_n_inst2_bud),
      .bias_rsc_dat(bias_rsc_dat),
      .bias_rsc_vld(bias_rsc_vld),
      .bias_rsc_rdy(bias_rsc_rdy_n_inst2_bud),
      .dout_rsc_dat(dout_rsc_dat_n_inst2),
      .dout_rsc_vld(dout_rsc_vld_n_inst2_bud),
      .dout_rsc_rdy(din_rsc_rdy_n_inst3_bud)
    );
  branch_0_layer_0_qnn_conv2d_105273232_rescaling_relu_ac_fixed_26_26_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_2304_1_1_0
      inst3 (
      .clk(clk),
      .rst(rst),
      .din_rsc_dat(dout_rsc_dat_n_inst2),
      .din_rsc_vld(dout_rsc_vld_n_inst2_bud),
      .din_rsc_rdy(din_rsc_rdy_n_inst3_bud),
      .dout_rsc_dat(dout_rsc_dat_n_inst3),
      .dout_rsc_vld(dout_rsc_vld_n_inst3_bud),
      .dout_rsc_rdy(dout_rsc_rdy)
    );
  assign din_rsc_rdy = din_rsc_rdy_n_inst0_bud;
  assign kernelIn_rsc_rdy = kernelIn_rsc_rdy_n_inst1_bud;
  assign bias_rsc_rdy = bias_rsc_rdy_n_inst2_bud;
  assign dout_rsc_vld = dout_rsc_vld_n_inst3_bud;
  assign dout_rsc_dat = dout_rsc_dat_n_inst3;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232_struct
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232_struct (
  clk, rst, din_rsc_dat_data, din_rsc_vld, din_rsc_rdy, dout_rsc_dat_data, dout_rsc_vld,
      dout_rsc_rdy
);
  input clk;
  input rst;
  input [31:0] din_rsc_dat_data;
  input din_rsc_vld;
  output din_rsc_rdy;
  output [7:0] dout_rsc_dat_data;
  output dout_rsc_vld;
  input dout_rsc_rdy;


  // Interconnect Declarations
  wire [287:0] kernelIn_rsc_dat_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst;
  wire kernelIn_rsc_vld_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst;
  wire [31:0] bias_rsc_dat_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst;
  wire bias_rsc_vld_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst;
  wire [7:0] dout_rsc_dat_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst;
  wire [287:0] AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_dat_n_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst;
  wire AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_rdy_n_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst;
  wire [31:0] AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_dat_n_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst;
  wire AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_rdy_n_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst;
  wire din_rsc_rdy_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst_bud;
  wire kernelIn_rsc_rdy_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst_bud;
  wire AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_vld_n_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst_bud;
  wire bias_rsc_rdy_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst_bud;
  wire AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_vld_n_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst_bud;
  wire dout_rsc_vld_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst_bud;
  wire AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_unc_2;
  wire AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_idle;
  wire AC_CH_ID99580272_func0_fc_bias_shape_4_unc_2;
  wire AC_CH_ID99580272_func0_fc_bias_shape_4_idle;


  // Interconnect Declarations for Component Instantiations 
  ccs_pipe_v6 #(.rscid(32'sd41),
  .width(32'sd288),
  .sz_width(32'sd1),
  .fifo_sz(32'sd16),
  .log2_sz(32'sd4),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1)) AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_cns_pipe (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .din_rdy(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_rdy_n_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst),
      .din_vld(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_vld_n_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst_bud),
      .din(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_dat_n_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst),
      .dout_rdy(kernelIn_rsc_rdy_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst_bud),
      .dout_vld(kernelIn_rsc_vld_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst),
      .dout(kernelIn_rsc_dat_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst),
      .sz(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_unc_2),
      .sz_req(1'b0),
      .is_idle(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_idle)
    );
  ccs_pipe_v6 #(.rscid(32'sd42),
  .width(32'sd32),
  .sz_width(32'sd1),
  .fifo_sz(32'sd16),
  .log2_sz(32'sd4),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd1)) AC_CH_ID99580272_func0_fc_bias_shape_4_cns_pipe (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .din_rdy(AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_rdy_n_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst),
      .din_vld(AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_vld_n_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst_bud),
      .din(AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_dat_n_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst),
      .dout_rdy(bias_rsc_rdy_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst_bud),
      .dout_vld(bias_rsc_vld_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst),
      .dout(bias_rsc_dat_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst),
      .sz(AC_CH_ID99580272_func0_fc_bias_shape_4_unc_2),
      .sz_req(1'b0),
      .is_idle(AC_CH_ID99580272_func0_fc_bias_shape_4_idle)
    );
  branch_0_layer_0_qnn_conv2d_105273232_qconv2d_relu_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_ac_fixed_8_8_false_AC_TRN_AC_WRAP_ac_fixed_32_2_false_AC_TRN_AC_WRAP_4_1_1_0_4_24_24_4_3_1
      branch_0_layer_0_qnn_conv2d_105273232_inner_inst (
      .clk(clk),
      .rst(rst),
      .din_rsc_dat(din_rsc_dat_data),
      .din_rsc_vld(din_rsc_vld),
      .din_rsc_rdy(din_rsc_rdy_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst_bud),
      .kernelIn_rsc_dat(kernelIn_rsc_dat_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst),
      .kernelIn_rsc_vld(kernelIn_rsc_vld_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst),
      .kernelIn_rsc_rdy(kernelIn_rsc_rdy_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst_bud),
      .bias_rsc_dat(bias_rsc_dat_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst),
      .bias_rsc_vld(bias_rsc_vld_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst),
      .bias_rsc_rdy(bias_rsc_rdy_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst_bud),
      .dout_rsc_dat(dout_rsc_dat_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst),
      .dout_rsc_vld(dout_rsc_vld_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst_bud),
      .dout_rsc_rdy(dout_rsc_rdy)
    );
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst
      (
      .clk(clk),
      .rst(rst),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_dat(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_dat_n_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_vld(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_vld_n_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst_bud),
      .AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_rdy(AC_CH_ID104977024_func0_fc_weight_shape_4_4_3_3_rsc_rdy_n_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_weight_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst)
    );
  branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1
      branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst
      (
      .clk(clk),
      .rst(rst),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_dat(AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_dat_n_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_vld(AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_vld_n_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst_bud),
      .AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_rdy(AC_CH_ID99580272_func0_fc_bias_shape_4_rsc_rdy_n_branch_0_layer_0_qnn_conv2d_105273232_bramloader_continuous_cfg_bias_ac_fixed_8_8_true_AC_TRN_AC_WRAP_ac_fixed_32_32_true_AC_TRN_AC_WRAP_4_1_1_4_24_24_4_3_1_36_1_inst)
    );
  assign dout_rsc_dat_data = dout_rsc_dat_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst;
  assign din_rsc_rdy = din_rsc_rdy_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst_bud;
  assign dout_rsc_vld = dout_rsc_vld_n_branch_0_layer_0_qnn_conv2d_105273232_inner_inst_bud;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    branch_0_layer_0_qnn_conv2d_105273232
// ------------------------------------------------------------------


module branch_0_layer_0_qnn_conv2d_105273232 (
  clk, rst, din_rsc_dat, din_rsc_vld, din_rsc_rdy, dout_rsc_dat, dout_rsc_vld, dout_rsc_rdy
);
  input clk;
  input rst;
  input [31:0] din_rsc_dat;
  input din_rsc_vld;
  output din_rsc_rdy;
  output [7:0] dout_rsc_dat;
  output dout_rsc_vld;
  input dout_rsc_rdy;


  // Interconnect Declarations
  wire [7:0] dout_rsc_dat_data;


  // Interconnect Declarations for Component Instantiations 
  branch_0_layer_0_qnn_conv2d_105273232_struct branch_0_layer_0_qnn_conv2d_105273232_struct_inst
      (
      .clk(clk),
      .rst(rst),
      .din_rsc_dat_data(din_rsc_dat),
      .din_rsc_vld(din_rsc_vld),
      .din_rsc_rdy(din_rsc_rdy),
      .dout_rsc_dat_data(dout_rsc_dat_data),
      .dout_rsc_vld(dout_rsc_vld),
      .dout_rsc_rdy(dout_rsc_rdy)
    );
  assign dout_rsc_dat = dout_rsc_dat_data;
endmodule



