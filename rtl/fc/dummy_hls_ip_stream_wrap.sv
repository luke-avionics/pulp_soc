import dummy_hls_ip_package::*;
import hwpe_stream_package::*;

module dummy_hls_ip_stream_wrap
#(
  parameter int unsigned FD = 2  // FIFO depth
)
(
  // global signals
  input  logic                   clk_i,
  input  logic                   rst_ni,
  input  logic                   test_mode_i,
  // local enable & clear
  input  logic                   enable_i,
  input  logic                   clear_i,

  //Anchor: Stream declaration
  hwpe_stream_intf_stream.source ch_fpga_func0_graph_input_0_o,
  hwpe_stream_intf_stream.sink   ch_fpga_func0_output0_i,

  //Anchor: TCDM ports master
  // TCDM ports
  hwpe_stream_intf_tcdm.master tcdm_ch_fpga_func0_graph_input_0,
  hwpe_stream_intf_tcdm.master tcdm_ch_fpga_func0_output0,

  // control channel
  input  ctrl_streamer_t  ctrl_i,
  output flags_streamer_t flags_o
);

  //Anchor: Input channel fifo signals
  logic ch_fpga_func0_graph_input_0_tcdm_fifo_ready;

  //Anchor: Instantiation of channel pre/post fifos
  hwpe_stream_intf_stream #(
    .DATA_WIDTH ( 32 )
  ) ch_fpga_func0_graph_input_0_prefifo (
    .clk ( clk_i )
  );
  hwpe_stream_intf_stream #(
    .DATA_WIDTH ( 32 )
  ) ch_fpga_func0_output0_postfifo (
    .clk ( clk_i )
  );

  //Anchor: Channel fifos 
  hwpe_stream_intf_tcdm tcdm_fifo_ch_fpga_func0_graph_input_0[0:0](
    .clk ( clk_i )
  );
  hwpe_stream_intf_tcdm tcdm_fifo_ch_fpga_func0_output0[0:0](
    .clk ( clk_i )
  );


  //Anchor: Source and sink modules
  // source and sink modules
  hwpe_stream_source #(
    .DATA_WIDTH ( 32 ),
    .DECOUPLED  ( 1  )
  ) i_ch_in1_source (
    .clk_i              ( clk_i                  ),
    .rst_ni             ( rst_ni                 ),
    .test_mode_i        ( test_mode_i            ),
    .clear_i            ( clear_i                ),
    .tcdm               ( tcdm_fifo_ch_fpga_func0_graph_input_0       ), // this syntax is necessary for Verilator as hwpe_stream_source expects an array of interfaces
    .stream             ( ch_fpga_func0_graph_input_0_prefifo.source  ),
    .ctrl_i             ( ctrl_i.ch_fpga_func0_graph_input_0_source_ctrl   ),
    .flags_o            ( flags_o.ch_fpga_func0_graph_input_0_source_flags ),
    .tcdm_fifo_ready_o  ( ch_fpga_func0_graph_input_0_tcdm_fifo_ready      )
  );
  hwpe_stream_sink #(
    .DATA_WIDTH ( 32 )
  ) i_d_sink (
    .clk_i       ( clk_i                ),
    .rst_ni      ( rst_ni               ),
    .test_mode_i ( test_mode_i          ),
    .clear_i     ( clear_i              ),
    .tcdm        ( tcdm_fifo_ch_fpga_func0_output0          ), // this syntax is necessary for Verilator as hwpe_stream_source expects an array of interfaces
    .stream      ( ch_fpga_func0_output0_postfifo.sink      ),
    .ctrl_i      ( ctrl_i.ch_fpga_func0_output0_sink_ctrl   ),
    .flags_o     ( flags_o.ch_fpga_func0_output0_sink_flags )
  );

  //Anchor: TCDM-side FIFOs
  // TCDM-side FIFOs
  hwpe_stream_tcdm_fifo_load #(
    .FIFO_DEPTH ( 4 )
  ) i_a_tcdm_fifo_load (
    .clk_i       ( clk_i             ),
    .rst_ni      ( rst_ni            ),
    .clear_i     ( clear_i           ),
    .flags_o     (                   ),
    .ready_i     ( ch_fpga_func0_graph_input_0_tcdm_fifo_ready ),
    .tcdm_slave  ( tcdm_fifo_ch_fpga_func0_graph_input_0[0]    ),
    .tcdm_master ( tcdm_ch_fpga_func0_graph_input_0         )
  );
  hwpe_stream_tcdm_fifo_store #(
    .FIFO_DEPTH ( 4 )
  ) i_d_tcdm_fifo_store (
    .clk_i       ( clk_i          ),
    .rst_ni      ( rst_ni         ),
    .clear_i     ( clear_i        ),
    .flags_o     (                ),
    .tcdm_slave  ( tcdm_fifo_ch_fpga_func0_output0[0] ),
    .tcdm_master ( tcdm_ch_fpga_func0_output0 )
  );


  //Anchor: datapath-side FIFOs
  // datapath-side FIFOs
  hwpe_stream_fifo #(
    .DATA_WIDTH( 32 ),
    .FIFO_DEPTH( 2  ),
    .LATCH_FIFO( 0  )
  ) i_a_fifo (
    .clk_i   ( clk_i          ),
    .rst_ni  ( rst_ni         ),
    .clear_i ( clear_i        ),
    .push_i  ( ch_fpga_func0_graph_input_0_prefifo.sink ),
    .pop_o   ( ch_fpga_func0_graph_input_0_o            ),
    .flags_o (                )
  );
  hwpe_stream_fifo #(
    .DATA_WIDTH( 32 ),
    .FIFO_DEPTH( 2  ),
    .LATCH_FIFO( 0  )
  ) i_d_fifo (
    .clk_i   ( clk_i             ),
    .rst_ni  ( rst_ni            ),
    .clear_i ( clear_i           ),
    .push_i  ( ch_fpga_func0_output0_i               ),
    .pop_o   ( ch_fpga_func0_output0_postfifo.source ),
    .flags_o (                   )
  );

endmodule // mac_streamer
