import dummy_hls_ip_package::*;
import hwpe_ctrl_package::*;

module dummy_hls_ip_top
#(
  parameter int unsigned N_CORES = 2,
  parameter int unsigned ID  = 10
)
(
  // global signals
  input  logic                                  clk_i,
  input  logic                                  rst_ni,
  input  logic                                  test_mode_i,
  // events
  output logic [N_CORES-1:0][REGFILE_N_EVT-1:0] evt_o,
  //Anchor: TCDM master ports
  // tcdm master ports
  hwpe_stream_intf_tcdm.master                  tcdm_ch_fpga_func0_graph_input_0,
  hwpe_stream_intf_tcdm.master                  tcdm_ch_fpga_func0_output0,
  // periph slave port
  hwpe_ctrl_intf_periph.slave                   periph
);

  logic enable, clear;
  ctrl_streamer_t  streamer_ctrl;
  flags_streamer_t streamer_flags;
  ctrl_engine_t    engine_ctrl;
  flags_engine_t   engine_flags;

  //Anchor: Channel declaration hwpe_stream_intf_stream
  hwpe_stream_intf_stream #(
    .DATA_WIDTH(32)
  ) ch_fpga_func0_graph_input_0 (
    .clk ( clk_i )
  );
  hwpe_stream_intf_stream #(
    .DATA_WIDTH(32)
  ) ch_fpga_func0_output0 (
    .clk ( clk_i )
  );

  //Anchor: Instatiation of the engine
  dummy_hls_ip_engine_wrap i_dummy_hls_ip_engine_wrap (
    .clk_i            ( clk_i          ),
    .rst_ni           ( rst_ni         ),
    .test_mode_i      ( test_mode_i    ),
    .ch_fpga_func0_graph_input_0_i              ( ch_fpga_func0_graph_input_0.sink         ),
    .ch_fpga_func0_output0_o              ( ch_fpga_func0_output0.source       ),
    .ctrl_i           ( engine_ctrl    ),
    .flags_o          ( engine_flags   )
  );

  //Anchor: Instatiation of the streamer
  dummy_hls_ip_stream_wrap i_dummy_hls_ip_stream_wrap (
    .clk_i            ( clk_i          ),
    .rst_ni           ( rst_ni         ),
    .test_mode_i      ( test_mode_i    ),
    .enable_i         ( enable         ),
    .clear_i          ( clear          ),
    .ch_fpga_func0_graph_input_0_o              ( ch_fpga_func0_graph_input_0.source       ),
    .ch_fpga_func0_output0_i              ( ch_fpga_func0_output0.sink       ),
    .tcdm_ch_fpga_func0_graph_input_0             ( tcdm_ch_fpga_func0_graph_input_0           ),
    .tcdm_ch_fpga_func0_output0            ( tcdm_ch_fpga_func0_output0          ),
    .ctrl_i           ( streamer_ctrl  ),
    .flags_o          ( streamer_flags )
  );

  // hijacking the interrupt for potential reconfig-ctrl
  logic [N_CORES-1:0][REGFILE_N_EVT-1:0] evt_ctrl_o;
  logic [N_CORES-1:0][REGFILE_N_EVT-1:0] evt_engine_o;
  logic event_mux_ctrl;
  assign event_mux_ctrl = '0;


  //set to max io number 48: https://github.com/pulp-platform/hwpe-ctrl/blob/master/rtl/hwpe_ctrl_package.sv#L23 
  dummy_hls_ip_ctrl_wrap #(
    .N_CORES   ( 2  ),
    .N_CONTEXT ( 2  ),
    .N_IO_REGS ( 48 ),
    .ID ( ID )
  ) i_dummy_hls_ip_ctrl_wrap (
    .clk_i            ( clk_i          ),
    .rst_ni           ( rst_ni         ),
    .test_mode_i      ( test_mode_i    ),
    .evt_o            ( evt_ctrl_o     ),
    .clear_o          ( clear          ),
    .ctrl_streamer_o  ( streamer_ctrl  ),
    .flags_streamer_i ( streamer_flags ),
    .ctrl_engine_o    ( engine_ctrl    ),
    .flags_engine_i   ( engine_flags   ),
    .periph           ( periph         )
  );

  assign enable = 1'b1;

  always_comb 
  begin
    case (event_mux_ctrl)
        0'b0: assign evt_o = evt_ctrl_o;
        0'b1: assign evt_o = evt_engine_o;
      default: assign evt_o = evt_ctrl_o;
    endcase
  end


endmodule