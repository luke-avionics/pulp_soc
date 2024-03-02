module top_module_branch_0(
  clk, rst,
// anchor for input args
din_rsc_dat,
din_rsc_vld,
din_rsc_rdy,
  // din_rsc_dat,
  // din_rsc_vld,
  // din_rsc_rdy,
// anchor for output args
dout_rsc_dat,
dout_rsc_vld,
dout_rsc_rdy
  // dout_rsc_dat,
  // dout_rsc_vld,
  // dout_rsc_rdy
);
// anchor for wdith params
parameter IN0_DATA_WIDTH = 32;
parameter OUT0_DATA_WIDTH = 8;
// parameter IN_DATA_WIDTH = 32, OUT_DATA_WIDTH = 32;


  input clk;
  input rst;
// anchor for input list
input [IN0_DATA_WIDTH-1:0] din_rsc_dat;
input din_rsc_vld;
output din_rsc_rdy;
  // input [IN_DATA_WIDTH-1:0] din_rsc_dat;
  // input din_rsc_vld;
  // output din_rsc_rdy;
// anchor for output list
output [OUT0_DATA_WIDTH-1:0] dout_rsc_dat;
output dout_rsc_vld;
input dout_rsc_rdy;
  // output [OUT_DATA_WIDTH-1:0] dout_rsc_dat;
  // output dout_rsc_vld;
  // input dout_rsc_rdy;

// anchor start for intermediate signals
wire clk_branch_0_layer_0_qnn_conv2d_105273232;
wire rst_branch_0_layer_0_qnn_conv2d_105273232;
wire [31:0] din_rsc_dat_branch_0_layer_0_qnn_conv2d_105273232;
wire din_rsc_vld_branch_0_layer_0_qnn_conv2d_105273232;
wire din_rsc_rdy_branch_0_layer_0_qnn_conv2d_105273232;
wire [7:0] dout_rsc_dat_branch_0_layer_0_qnn_conv2d_105273232;
wire dout_rsc_vld_branch_0_layer_0_qnn_conv2d_105273232;
wire dout_rsc_rdy_branch_0_layer_0_qnn_conv2d_105273232;
// anchor end for intermediate signals

// anchor start for assigning signals
assign clk_branch_0_layer_0_qnn_conv2d_105273232 = clk;
assign rst_branch_0_layer_0_qnn_conv2d_105273232 = rst;
assign din_rsc_dat_branch_0_layer_0_qnn_conv2d_105273232 = din_rsc_dat;
assign din_rsc_vld_branch_0_layer_0_qnn_conv2d_105273232 = din_rsc_vld;
assign din_rsc_rdy = din_rsc_rdy_branch_0_layer_0_qnn_conv2d_105273232;
assign dout_rsc_dat = dout_rsc_dat_branch_0_layer_0_qnn_conv2d_105273232;
assign dout_rsc_vld = dout_rsc_vld_branch_0_layer_0_qnn_conv2d_105273232;
assign dout_rsc_rdy_branch_0_layer_0_qnn_conv2d_105273232 = dout_rsc_rdy;
// anchor end for assigning signals

// anchor start for layer instantiations
	branch_0_layer_0_qnn_conv2d_105273232 branch_0_layer_0_qnn_conv2d_105273232_inst (
		.clk(clk_branch_0_layer_0_qnn_conv2d_105273232),
		.rst(rst_branch_0_layer_0_qnn_conv2d_105273232),
		.din_rsc_dat(din_rsc_dat_branch_0_layer_0_qnn_conv2d_105273232),
		.din_rsc_vld(din_rsc_vld_branch_0_layer_0_qnn_conv2d_105273232),
		.din_rsc_rdy(din_rsc_rdy_branch_0_layer_0_qnn_conv2d_105273232),
		.dout_rsc_dat(dout_rsc_dat_branch_0_layer_0_qnn_conv2d_105273232),
		.dout_rsc_vld(dout_rsc_vld_branch_0_layer_0_qnn_conv2d_105273232),
		.dout_rsc_rdy(dout_rsc_rdy_branch_0_layer_0_qnn_conv2d_105273232)
	);
// anchor end for layer instantiations


endmodule
