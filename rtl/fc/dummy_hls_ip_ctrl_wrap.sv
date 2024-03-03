import dummy_hls_ip_package::*;
import hwpe_ctrl_package::*;

module dummy_hls_ip_ctrl_wrap
#(
  parameter int unsigned N_CORES         = 2,
  parameter int unsigned N_CONTEXT       = 2,
  parameter int unsigned N_IO_REGS       = 16,
  parameter int unsigned ID              = 10,
  parameter int unsigned ULOOP_HARDWIRED = 0
)
(
  // global signals
  input  logic                                  clk_i,
  input  logic                                  rst_ni,
  input  logic                                  test_mode_i,
  output logic                                  clear_o,
  // events
  output logic [N_CORES-1:0][REGFILE_N_EVT-1:0] evt_o,
  // ctrl & flags
  output ctrl_streamer_t                        ctrl_streamer_o,
  input  flags_streamer_t                       flags_streamer_i,
  output ctrl_engine_t                          ctrl_engine_o,
  input  flags_engine_t                         flags_engine_i,
  // periph slave port
  hwpe_ctrl_intf_periph.slave                   periph
);

  ctrl_slave_t   slave_ctrl;
  flags_slave_t  slave_flags;
  ctrl_regfile_t reg_file;

  logic unsigned [31:0] static_reg_nb_iter;
  logic unsigned [31:0] static_reg_vectstride;
  logic unsigned [31:0] static_reg_onestride;

  //Anchor: Channel length static_reg_ch_xx_len_iter declaration
  logic unsigned [31:0] static_reg_ch_fpga_func0_graph_input_0_len_iter;
  logic unsigned [31:0] static_reg_ch_fpga_func0_output0_len_iter;


  uloop_bytecode_t [31:0] uloop_bytecode;
  uloop_code_t uloop_code;
  ctrl_uloop_t   uloop_ctrl;
  flags_uloop_t  uloop_flags;
  logic [11:0][31:0] uloop_registers_read;

  ctrl_fsm_t fsm_ctrl;
  regfile_in_t regfile_in_from_hwme;

  /* Peripheral slave & register file */
  hwpe_ctrl_slave #(
    .N_CORES        ( N_CORES               ),
    .N_CONTEXT      ( N_CONTEXT             ),
    .N_IO_REGS      ( N_IO_REGS             ),
    .N_GENERIC_REGS ( (1-ULOOP_HARDWIRED)*8 ),
    .ID_WIDTH       ( ID                    )
  ) i_slave (
    .clk_i    ( clk_i       ),
    .rst_ni   ( rst_ni      ),
    .clear_o  ( clear_o     ),
    .cfg      ( periph      ),
    .ctrl_i   ( slave_ctrl  ),
    .flags_o  ( slave_flags ),
    .reg_file ( reg_file    ),
    .static_context_mode ( 1 ),
    .regfile_in_from_hwme(regfile_in_from_hwme)
  );
  assign evt_o = slave_flags.evt;

  /* Direct register file mappings */
  assign static_reg_nb_iter    = reg_file.hwpe_params[MAC_REG_NB_ITER]  + 1;
  assign static_reg_vectstride = reg_file.hwpe_params[MAC_REG_SHIFT_VECTSTRIDE];
  assign static_reg_onestride  = reg_file.hwpe_params[MAC_REG_SHIFT_ONESTRIDE];
  assign static_reg_op_type    = reg_file.hwpe_params[MAC_REG_OP_TYPE];
  //Anchor: Channel length static_reg_ch_xx_len_iter assignment
  assign static_reg_ch_fpga_func0_graph_input_0_len_iter   = reg_file.hwpe_params[MAC_REG_ch_fpga_func0_graph_input_0_LEN] + 1;
  assign static_reg_ch_fpga_func0_output0_len_iter  = reg_file.hwpe_params[MAC_REG_ch_fpga_func0_output0_LEN] + 1;
  //Anchor: Channel ready flags assignment
  assign static_reg_ch_fpga_func0_graph_input_0_ready = reg_file.hwpe_params[MAC_REG_ch_fpga_func0_graph_input_0_READY];
  assign static_reg_ch_fpga_func0_output0_ready = reg_file.hwpe_params[MAC_REG_ch_fpga_func0_output0_READY];

  /* Microcode processor */
  generate
    if(ULOOP_HARDWIRED == 1) begin : hardwired_uloop_gen
      assign uloop_bytecode = 196'h00000000000000000000000000000000000008cd11a12c05;
    end
    else begin : not_hardwired_uloop_gen
      assign uloop_bytecode = reg_file.generic_params[5:0];
    end
  endgenerate

  // currently hardwired
  always_comb
  begin
    uloop_code = '0;
    uloop_code.loops[0] = 8'h04;
    for(int i=0; i<196; i++) begin
      uloop_code.code [i] = uloop_bytecode[i];
    end
    uloop_code.range[0] = static_reg_nb_iter[11:0];
  end

  assign uloop_registers_read[MAC_UCODE_MNEM_NBITER]     = static_reg_nb_iter;
  assign uloop_registers_read[MAC_UCODE_MNEM_ITERSTRIDE] = static_reg_vectstride;
  assign uloop_registers_read[MAC_UCODE_MNEM_ONESTRIDE]  = static_reg_onestride;
  assign uloop_registers_read[11:3] = '0;
  hwpe_ctrl_uloop #(
    .NB_LOOPS  ( 1  ),
    .NB_REG    ( 4  ),
    .NB_RO_REG ( 12 )
  ) i_uloop (
    .clk_i            ( clk_i                ),
    .rst_ni           ( rst_ni               ),
    .test_mode_i      ( test_mode_i          ),
    .clear_i          ( clear_o              ),
    .ctrl_i           ( uloop_ctrl           ),
    .flags_o          ( uloop_flags          ),
    .uloop_code_i     ( uloop_code           ),
    .registers_read_i ( uloop_registers_read )
  );

  /* Main FSM */
  dummy_hls_ip_fsm i_dummy_hls_ip_fsm (
    .clk_i            ( clk_i              ),
    .rst_ni           ( rst_ni             ),
    .test_mode_i      ( test_mode_i        ),
    .clear_i          ( clear_o            ),
    .ctrl_streamer_o  ( ctrl_streamer_o    ),
    .flags_streamer_i ( flags_streamer_i   ),
    .ctrl_engine_o    ( ctrl_engine_o      ),
    .flags_engine_i   ( flags_engine_i     ),
    .ctrl_uloop_o     ( uloop_ctrl         ),
    .flags_uloop_i    ( uloop_flags        ),
    .ctrl_slave_o     ( slave_ctrl         ),
    .flags_slave_i    ( slave_flags        ),
    .reg_file_i       ( reg_file           ),
    .ctrl_i           ( fsm_ctrl           ),
    .regfile_in_from_hwme(regfile_in_from_hwme)
  );

  //Anchor: Channel length settings fsm_ctrl assignment
  always_comb
  begin
    fsm_ctrl.ch_fpga_func0_graph_input_0_len        = static_reg_ch_fpga_func0_graph_input_0_len_iter[$clog2(MAC_CNT_LEN):0];
    fsm_ctrl.ch_fpga_func0_output0_len       = static_reg_ch_fpga_func0_output0_len_iter[$clog2(MAC_CNT_LEN):0];
    fsm_ctrl.op_type = static_reg_op_type;
  end

endmodule // mac_ctrl
