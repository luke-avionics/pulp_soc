import hwpe_stream_package::*;

package dummy_hls_ip_package;

  parameter int unsigned MAC_CNT_LEN = 1605632; // maximum length of the vectors for a scalar product

  // registers in register file
  parameter int unsigned MAC_REG_NB_ITER          = 0;
  parameter int unsigned MAC_REG_SHIFT_VECTSTRIDE = 1;
  parameter int unsigned MAC_REG_SHIFT_ONESTRIDE  = 2;
  parameter int unsigned MAC_REG_OP_TYPE          = 3;
  //Anchor: Channel Addresses
  parameter int unsigned MAC_REG_ch_fpga_func0_graph_input_0_ADDR            = 4;
  parameter int unsigned MAC_REG_ch_fpga_func0_output0_ADDR           = 6;

  //Anchor: Channel lengths addresses
  parameter int unsigned MAC_REG_ch_fpga_func0_graph_input_0_LEN            = 5;
  parameter int unsigned MAC_REG_ch_fpga_func0_output0_LEN           = 7;

  //Anchor: Channel ready flags
  parameter int unsigned MAC_REG_ch_fpga_func0_graph_input_0_READY            = 8;
  parameter int unsigned MAC_REG_ch_fpga_func0_output0_READY           = 9;

  // microcode offset indeces -- this should be aligned to the microcode compiler of course!
  //Anchor: Channel Offsets
  parameter int unsigned MAC_UCODE_ch_fpga_func0_graph_input_0_OFFS = 0;
  parameter int unsigned MAC_UCODE_ch_fpga_func0_output0_OFFS = 1;

  // microcode mnemonics -- this should be aligned to the microcode compiler of course!
  parameter int unsigned MAC_UCODE_MNEM_NBITER     = 4 - 4; //possibly 4-2 ? 2 for 2 channels
  parameter int unsigned MAC_UCODE_MNEM_ITERSTRIDE = 5 - 4;
  parameter int unsigned MAC_UCODE_MNEM_ONESTRIDE  = 6 - 4;


  //Anchor: Channel length settings ctrl_engine_t
  typedef struct packed {
    logic clear;
    logic enable;
    logic start;
    logic unsigned [1:0] op_type;
    logic unsigned [$clog2(MAC_CNT_LEN):0] ch_fpga_func0_graph_input_0_len; // 1 bit more as cnt starts from 1, not 0
    logic unsigned [$clog2(MAC_CNT_LEN):0] ch_fpga_func0_output0_len; // 1 bit more as cnt starts from 1, not 0
  } ctrl_engine_t; 

  //Anchor: Channel length settings flags_engine_t
  typedef struct packed {
    logic unsigned [$clog2(MAC_CNT_LEN):0] ch_fpga_func0_output0_cnt; // 1 bit more as cnt starts from 1, not 0
    logic ch_fpga_func0_output0_acc_valid;
  } flags_engine_t;

  //Anchor: Channel Control ctrl_streamer_t
  typedef struct packed {
    hwpe_stream_package::ctrl_sourcesink_t ch_fpga_func0_graph_input_0_source_ctrl;
    hwpe_stream_package::ctrl_sourcesink_t ch_fpga_func0_output0_sink_ctrl;  
  } ctrl_streamer_t;

  //Anchor: Channel Control flags_streamer_t
  typedef struct packed {
    hwpe_stream_package::flags_sourcesink_t ch_fpga_func0_graph_input_0_source_flags;
    hwpe_stream_package::flags_sourcesink_t ch_fpga_func0_output0_sink_flags;
  } flags_streamer_t;

  //Anchor: Channel length settings ctrl_fsm_t
  typedef struct packed {
    logic unsigned [1:0] op_type;
    logic unsigned [$clog2(MAC_CNT_LEN):0] ch_fpga_func0_graph_input_0_len; // 1 bit more as cnt starts from 1, not 0
    logic unsigned [$clog2(MAC_CNT_LEN):0] ch_fpga_func0_output0_len; // 1 bit more as cnt starts from 1, not 0
  } ctrl_fsm_t;

  typedef enum {
    FSM_IDLE,
    FSM_START,
    FSM_COMPUTE,
    FSM_WAIT,
    FSM_UPDATEIDX,
    FSM_TERMINATE
  } state_fsm_t;

endpackage // mac_package
