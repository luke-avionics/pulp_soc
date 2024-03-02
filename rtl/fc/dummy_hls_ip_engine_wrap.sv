
import dummy_hls_ip_package::*;
import hwpe_stream_package::*;
module dummy_hls_ip_engine_wrap
(
  // global signals
  input  logic                   clk_i,
  input  logic                   rst_ni,
  input  logic                   test_mode_i,
  //Anchor: Channel port declaration
  hwpe_stream_intf_stream.sink   ch_fpga_func0_graph_input_0_i,
  hwpe_stream_intf_stream.source ch_fpga_func0_output0_o,
  // control channel
  input  ctrl_engine_t           ctrl_i,
  output flags_engine_t          flags_o
);

//Anchor: Channel internal signals
  logic [31:0] chan_in0_rsc_dat;
  logic chan_in0_rsc_vld;
  logic chan_in0_rsc_rdy;
  logic [7:0] chan_out0_rsc_dat;
  logic chan_out0_rsc_vld;
  logic chan_out0_rsc_rdy;

// logic [31:0] chan_in0_rsc_dat;
// logic chan_in0_rsc_vld;
// logic chan_in0_rsc_rdy;
// logic [31:0] chan_out0_rsc_dat;
// logic chan_out0_rsc_vld;
// logic chan_out0_rsc_rdy;

//Anchor: Channel internal signals assignment
// assign chan_in0_rsc_dat = ch_fpga_func0_graph_input_0_i.data;
// assign chan_in0_rsc_vld = ch_fpga_func0_graph_input_0_i.valid;
// assign ch_fpga_func0_graph_input_0_i.ready = chan_in0_rsc_rdy;
// assign ch_fpga_func0_output0_o.data = chan_out0_rsc_dat;
// assign ch_fpga_func0_output0_o.valid = chan_out0_rsc_vld;
// assign chan_out0_rsc_rdy = ch_fpga_func0_output0_o.ready;
assign ch_fpga_func0_output0_o.strb = '1;

//Anchor: Input Channel FIFO and width arbitration
axis_fifo #(
    .MEM_ADDR_WIDTH(8),
    .AXIS_DATA_WIDTH_FIFO_IN(32),
    .AXIS_DATA_WIDTH_FIFO_OUT(32),
    .MEM_DATA_WIDTH(32),
    .WR_PTR_STEP(1),
    .RD_PTR_STEP(1)
)axis_fifo_inst_0(
    .wr_aclk(clk_i),
    .wr_rstn(rst_ni),
    .wr_axis_data(ch_fpga_func0_graph_input_0_i.data),
    .wr_axis_vld(ch_fpga_func0_graph_input_0_i.valid),
    .wr_axis_rdy(ch_fpga_func0_graph_input_0_i.ready),
    .rd_aclk(clk_i),
    .rd_rstn(rst_ni),
    .rd_axis_data(chan_in0_rsc_dat),
    .rd_axis_vld(chan_in0_rsc_vld),
    .rd_axis_rdy(chan_in0_rsc_rdy)
);

// axis_fifo #(
//     .MEM_ADDR_WIDTH(4),
//     .AXIS_DATA_WIDTH_FIFO_IN(32),
//     .AXIS_DATA_WIDTH_FIFO_OUT(32),
//     .MEM_DATA_WIDTH(32),
//     .WR_PTR_STEP(1),
//     .RD_PTR_STEP(1)
// )axis_fifo_inst_0(
//     .wr_aclk(clk),
//     .wr_rstn(rst_ni),
//     .wr_axis_data(ch_fpga_func0_graph_input_0_i.data),
//     .wr_axis_vld(ch_fpga_func0_graph_input_0_i.valid),
//     .wr_axis_rdy(ch_fpga_func0_graph_input_0_i.ready),
//     .rd_aclk(clk),
//     .rd_rstn(rst_ni),
//     .rd_axis_data(chan_in0_rsc_dat),
//     .rd_axis_vld(chan_in0_rsc_vld),
//     .rd_axis_rdy(chan_in0_rsc_rdy)
// );

//Anchor: Output Channel FIFO and width arbitration
axis_fifo #(
    .MEM_ADDR_WIDTH(8),
    .AXIS_DATA_WIDTH_FIFO_IN(8),
    .AXIS_DATA_WIDTH_FIFO_OUT(32),
    .MEM_DATA_WIDTH(8),
    .WR_PTR_STEP(1),
    .RD_PTR_STEP(4)
)axis_fifo_inst_1(
    .wr_aclk(clk_i),
    .wr_rstn(rst_ni),
    .wr_axis_data(chan_out0_rsc_dat),
    .wr_axis_vld(chan_out0_rsc_vld),
    .wr_axis_rdy(chan_out0_rsc_rdy),
    .rd_aclk(clk_i),
    .rd_rstn(rst_ni),
    .rd_axis_data(ch_fpga_func0_output0_o.data),
    .rd_axis_vld(ch_fpga_func0_output0_o.valid),
    .rd_axis_rdy(ch_fpga_func0_output0_o.ready)
);

// axis_fifo #(
//     .MEM_ADDR_WIDTH(4),
//     .AXIS_DATA_WIDTH_FIFO_IN(32),
//     .AXIS_DATA_WIDTH_FIFO_OUT(32),
//     .MEM_DATA_WIDTH(32),
//     .WR_PTR_STEP(1),
//     .RD_PTR_STEP(1)
// )axis_fifo_inst_1(
//     .wr_aclk(clk),
//     .wr_rstn(rst_ni),
//     .wr_axis_data(chan_out0_rsc_dat),
//     .wr_axis_vld(chan_out0_rsc_vld),
//     .wr_axis_rdy(chan_out0_rsc_rdy),
//     .rd_aclk(clk),
//     .rd_rstn(rst_ni),
//     .rd_axis_data(ch_fpga_func0_output0_o.data),
//     .rd_axis_vld(ch_fpga_func0_output0_o.valid),
//     .rd_axis_rdy(ch_fpga_func0_output0_o.ready)
// );

//rst mux for states clearing
logic rst_engine; 
assign rst_engine = ctrl_i.clear? 0 : rst_ni;

//user def
//Anchor: output counter declaration
logic [$clog2(MAC_CNT_LEN):0] counter_o0_rsc_dat;

top_module_branch_0 i_dummy_hls_ip_0(
      .clk (clk_i), 
      .rst (~rst_engine), 
      .din_rsc_dat(chan_in0_rsc_dat),
      .din_rsc_vld(chan_in0_rsc_vld),
      .din_rsc_rdy(chan_in0_rsc_rdy), 
      .dout_rsc_dat (chan_out0_rsc_dat),
      .dout_rsc_vld (chan_out0_rsc_vld), 
      .dout_rsc_rdy (chan_out0_rsc_rdy)
);

// dummy_hls_ip i_dummy_hls_ip_0(
//     .clk    (clk_i), 
//     .rst    (~rst_engine), 
//     .chan_in1_rsc_dat (chan_in1_rsc_dat),
//     .chan_in1_rsc_vld (chan_in1_rsc_vld),
//     .chan_in1_rsc_rdy (chan_in1_rsc_rdy), 
//     .chan_in2_rsc_dat (chan_in2_rsc_dat),
//     .chan_in2_rsc_vld (chan_in2_rsc_vld), 
//     .chan_in2_rsc_rdy (chan_in2_rsc_rdy), 
//     .chan_out_rsc_dat (chan_out_rsc_dat), 
//     .chan_out_rsc_vld (chan_out_rsc_vld), 
//     .chan_out_rsc_rdy (chan_out_rsc_rdy),
//     .counter_o_rsc_dat (counter_o_rsc_dat),
//     .counter_o_rsc_triosy_lz(),
//     .operator_type_rsc_dat(ctrl_i.op_type),
//     .operator_type_rsc_triosy_lz()
// );



// //inter-connect modules
// logic xbar_ctrl;
// //xbar regs
// //output ports for the engine xxxx_<port_num>_<engine_id>
// logic [31:0] chan_out_rsc_dat_0_0;
// logic [31:0] chan_out_rsc_dat_0_1;
// logic chan_out_rsc_rdy_0_0, chan_out_rsc_rdy_0_1, chan_out_rsc_vld_0_0, chan_out_rsc_vld_0_1;
// //input ports for the engine xxxx_<port_num>_<engine_id>
// logic [31:0] chan_in_rsc_dat_0_0;
// logic [31:0] chan_in_rsc_dat_0_1;
// logic [31:0] chan_in_rsc_dat_1_0;
// logic [31:0] chan_in_rsc_dat_1_1;
// logic chan_in_rsc_rdy_0_0, chan_in_rsc_rdy_0_1, chan_in_rsc_rdy_1_0, chan_in_rsc_rdy_1_1;
// logic chan_in_rsc_vld_0_0, chan_in_rsc_vld_0_1, chan_in_rsc_vld_1_0, chan_in_rsc_vld_1_1;    




// assign xbar_ctrl = ctrl_i.xbar_ctrl;

// always_comb
// begin
//   case (xbar_ctrl)
//     1'b0:begin
//       // switch for the inputs
//       assign chan_in_rsc_dat_0_0 = chan_in1_rsc_dat;
//       assign chan_in_rsc_vld_0_0 = chan_in1_rsc_vld;
//       assign chan_in1_rsc_rdy = chan_in_rsc_rdy_0_0;
//       assign chan_in_rsc_dat_1_0 = chan_in2_rsc_dat;
//       assign chan_in_rsc_vld_1_0 = chan_in2_rsc_vld;
//       assign chan_in2_rsc_rdy = chan_in_rsc_rdy_1_0;
//       assign chan_in_rsc_dat_0_1 = chan_in1_rsc_dat;
//       assign chan_in_rsc_vld_0_1 = chan_in1_rsc_vld;
//       assign chan_in1_rsc_rdy = chan_in_rsc_rdy_0_1;
//       // 1st engine's output to one of the 2nd engine's input
//       assign chan_in_rsc_dat_1_1 = chan_out_rsc_dat_0_0;
//       assign chan_in_rsc_vld_1_1 = chan_out_rsc_vld_0_0;
//       assign chan_out_rsc_rdy_0_0 = chan_in_rsc_rdy_1_1;

//       //switch for the outputs
//       assign chan_out_rsc_dat = chan_out_rsc_dat_0_1;
//       assign chan_out_rsc_vld = chan_out_rsc_vld_0_1;
//       assign chan_out_rsc_rdy_0_1 = chan_out_rsc_rdy;
//     end
//     1'b1: begin
//       // switch for the inputs
//       assign chan_in_rsc_dat_0_0 = chan_in1_rsc_dat;
//       assign chan_in_rsc_vld_0_0 = chan_in1_rsc_vld;
//       assign chan_in1_rsc_rdy = chan_in_rsc_rdy_0_0;
//       assign chan_in_rsc_dat_1_1 = chan_in2_rsc_dat;
//       assign chan_in_rsc_vld_1_1 = chan_in2_rsc_vld;
//       assign chan_in2_rsc_rdy = chan_in_rsc_rdy_1_1;
//       assign chan_in_rsc_dat_0_1 = chan_in1_rsc_dat;
//       assign chan_in_rsc_vld_0_1 = chan_in1_rsc_vld;
//       assign chan_in1_rsc_rdy = chan_in_rsc_rdy_0_1;
//       // 2nd engine's output to one of the 1st engine's input
//       assign chan_in_rsc_dat_1_0 = chan_out_rsc_dat_0_1;
//       assign chan_in_rsc_vld_1_0 = chan_out_rsc_vld_0_1;
//       assign chan_out_rsc_rdy_0_1 = chan_in_rsc_rdy_1_0;

//       //switch for the outputs
//       assign chan_out_rsc_dat = chan_out_rsc_dat_0_0;
//       assign chan_out_rsc_vld = chan_out_rsc_vld_0_0;
//       assign chan_out_rsc_rdy_0_0 = chan_out_rsc_rdy;
//     end 
//     default: begin
//       // switch for the inputs
//       assign chan_in_rsc_dat_0_0 = chan_in1_rsc_dat;
//       assign chan_in_rsc_vld_0_0 = chan_in1_rsc_vld;
//       assign chan_in1_rsc_rdy = chan_in_rsc_rdy_0_0;
//       assign chan_in_rsc_dat_1_0 = chan_in2_rsc_dat;
//       assign chan_in_rsc_vld_1_0 = chan_in2_rsc_vld;
//       assign chan_in2_rsc_rdy = chan_in_rsc_rdy_1_0;
//       assign chan_in_rsc_dat_0_1 = chan_in1_rsc_dat;
//       assign chan_in_rsc_vld_0_1 = chan_in1_rsc_vld;
//       assign chan_in1_rsc_rdy = chan_in_rsc_rdy_0_1;
//       // 1st engine's output to one of the 2nd engine's input
//       assign chan_in_rsc_dat_1_1 = chan_out_rsc_dat_0_0;
//       assign chan_in_rsc_vld_1_1 = chan_out_rsc_vld_0_0;
//       assign chan_out_rsc_rdy_0_0 = chan_in_rsc_rdy_1_1;

//       //switch for the outputs
//       assign chan_out_rsc_dat = chan_out_rsc_dat_0_1;
//       assign chan_out_rsc_vld = chan_out_rsc_vld_0_1;
//       assign chan_out_rsc_rdy_0_1 = chan_out_rsc_rdy;
//     end
//   endcase


// end



// dummy_hls_ip i_dummy_hls_ip_0(
//     .clk    (clk_i), 
//     .rst    (~rst_engine), 
//     .chan_in1_rsc_dat (chan_in_rsc_dat_0_0),
//     .chan_in1_rsc_vld (chan_in_rsc_vld_0_0),
//     .chan_in1_rsc_rdy (chan_in_rsc_rdy_0_0), 
//     .chan_in2_rsc_dat (chan_in_rsc_dat_1_0),
//     .chan_in2_rsc_vld (chan_in_rsc_vld_1_0), 
//     .chan_in2_rsc_rdy (chan_in_rsc_rdy_1_0), 
//     .chan_out_rsc_dat (chan_out_rsc_dat_0_0), 
//     .chan_out_rsc_vld (chan_out_rsc_vld_0_0), 
//     .chan_out_rsc_rdy (chan_out_rsc_rdy_0_0),
//     .counter_o_rsc_dat (),
//     .counter_o_rsc_triosy_lz(),
//     // .operator_type_rsc_dat(ctrl_i.op_type),
//     .operator_type_rsc_dat('0),
//     .operator_type_rsc_triosy_lz()
// );

// dummy_hls_ip i_dummy_hls_ip_1(
//     .clk    (clk_i), 
//     .rst    (~rst_engine), 
//     .chan_in1_rsc_dat (chan_in_rsc_dat_0_1),
//     .chan_in1_rsc_vld (chan_in_rsc_vld_0_1),
//     .chan_in1_rsc_rdy (chan_in_rsc_rdy_0_1), 
//     .chan_in2_rsc_dat (chan_in_rsc_dat_1_1),
//     .chan_in2_rsc_vld (chan_in_rsc_vld_1_1), 
//     .chan_in2_rsc_rdy (chan_in_rsc_rdy_1_1), 
//     .chan_out_rsc_dat (chan_out_rsc_dat_0_1), 
//     .chan_out_rsc_vld (chan_out_rsc_vld_0_1), 
//     .chan_out_rsc_rdy (chan_out_rsc_rdy_0_1),
//     .counter_o_rsc_dat (counter_o_rsc_dat),
//     .counter_o_rsc_triosy_lz(),
//     .operator_type_rsc_dat(ctrl_i.op_type),
//     .operator_type_rsc_triosy_lz()
// );


//Anchor: output counter logic
//rtl customized counter if the ip iteself does not have the counter 
//currently, the counter depends on the transaction of the ch_out_rsc_dat
logic unsigned [$clog2(MAC_CNT_LEN):0]    cnt0;
logic                                     r_acc_ready0;
logic                                     r_acc_valid0;


assign r_acc_ready0  = ch_fpga_func0_output0_o.ready | ~r_acc_valid0;
always_ff @(posedge clk_i or negedge rst_ni)
begin : iteration_end_valid0
  if(~rst_ni) begin
    r_acc_valid0 <= '0;
  end
  else if (ctrl_i.clear) begin
    r_acc_valid0 <= '0;
  end
  else if (ctrl_i.enable) begin
    // r_acc_valid is re-evaluated after a valid handshake or in transition to 1
    if(((counter_o0_rsc_dat == ctrl_i.ch_fpga_func0_output0_len) & ch_fpga_func0_output0_o.valid & ch_fpga_func0_output0_o.ready) | (r_acc_valid0 & r_acc_ready0)) begin
      r_acc_valid0 <= (counter_o0_rsc_dat == ctrl_i.ch_fpga_func0_output0_len);
    end
  end
end

always_comb
begin
  cnt0 = counter_o0_rsc_dat + 1;
end

always_ff @(posedge clk_i or negedge rst_ni)
begin
  if(~rst_ni) begin
    counter_o0_rsc_dat <= '0;
  end
  else if(ctrl_i.clear) begin
    counter_o0_rsc_dat <= '0;
  end
  else if(ctrl_i.enable) begin
    if ((ctrl_i.start == 1'b1) || ((counter_o0_rsc_dat > 0) && (counter_o0_rsc_dat < ctrl_i.ch_fpga_func0_output0_len) && (ch_fpga_func0_output0_o.valid & ch_fpga_func0_output0_o.ready == 1'b1))) begin
      counter_o0_rsc_dat <= cnt0;
    end
  end
end


//controlling logic
assign flags_o.ch_fpga_func0_output0_cnt = counter_o0_rsc_dat;
assign flags_o.ch_fpga_func0_output0_acc_valid = ch_fpga_func0_output0_o.valid;

endmodule