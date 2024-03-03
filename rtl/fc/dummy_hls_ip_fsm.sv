import dummy_hls_ip_package::*;
import hwpe_ctrl_package::*;

module dummy_hls_ip_fsm (
  // global signals
  input  logic                clk_i,
  input  logic                rst_ni,
  input  logic                test_mode_i,
  input  logic                clear_i,
  // ctrl & flags
  output ctrl_streamer_t      ctrl_streamer_o,
  input  flags_streamer_t     flags_streamer_i,
  output ctrl_engine_t        ctrl_engine_o,
  input  flags_engine_t       flags_engine_i,
  output ctrl_uloop_t         ctrl_uloop_o,
  input  flags_uloop_t        flags_uloop_i,
  output ctrl_slave_t         ctrl_slave_o,
  input  flags_slave_t        flags_slave_i,
  input  ctrl_regfile_t       reg_file_i,
  input  ctrl_fsm_t           ctrl_i,
  output regfile_in_t         regfile_in_from_hwme 
);

  state_fsm_t curr_state, next_state;

  always_ff @(posedge clk_i or negedge rst_ni)
  begin : main_fsm_seq
    if(~rst_ni) begin
      curr_state <= FSM_IDLE;
    end
    else if(clear_i) begin
      curr_state <= FSM_IDLE;
    end
    else begin
      curr_state <= next_state;
    end
  end

  always_comb
  begin : main_fsm_comb
    // direct mappings - these have to be here due to blocking/non-blocking assignment
    // combination with the same ctrl_engine_o/ctrl_streamer_o variable
    // shift-by-3 due to conversion from bits to bytes
    // ch_fpga_func0_graph_input_0 stream
    ctrl_streamer_o.ch_fpga_func0_graph_input_0_source_ctrl.addressgen_ctrl.trans_size  = ctrl_i.ch_fpga_func0_graph_input_0_len;
    ctrl_streamer_o.ch_fpga_func0_graph_input_0_source_ctrl.addressgen_ctrl.line_stride = '0;
    ctrl_streamer_o.ch_fpga_func0_graph_input_0_source_ctrl.addressgen_ctrl.line_length = ctrl_i.ch_fpga_func0_graph_input_0_len;
    ctrl_streamer_o.ch_fpga_func0_graph_input_0_source_ctrl.addressgen_ctrl.feat_stride = '0;
    ctrl_streamer_o.ch_fpga_func0_graph_input_0_source_ctrl.addressgen_ctrl.feat_length = 1;
    ctrl_streamer_o.ch_fpga_func0_graph_input_0_source_ctrl.addressgen_ctrl.base_addr   = reg_file_i.hwpe_params[MAC_REG_ch_fpga_func0_graph_input_0_ADDR] + (flags_uloop_i.offs[MAC_UCODE_ch_fpga_func0_graph_input_0_OFFS]);
    ctrl_streamer_o.ch_fpga_func0_graph_input_0_source_ctrl.addressgen_ctrl.feat_roll   = '0;
    ctrl_streamer_o.ch_fpga_func0_graph_input_0_source_ctrl.addressgen_ctrl.loop_outer  = '0;
    ctrl_streamer_o.ch_fpga_func0_graph_input_0_source_ctrl.addressgen_ctrl.realign_type = '0;
    // ch_fpga_func0_output0 stream
    ctrl_streamer_o.ch_fpga_func0_output0_sink_ctrl.addressgen_ctrl.trans_size  = ctrl_i.ch_fpga_func0_output0_len;
    ctrl_streamer_o.ch_fpga_func0_output0_sink_ctrl.addressgen_ctrl.line_stride = '0;
    ctrl_streamer_o.ch_fpga_func0_output0_sink_ctrl.addressgen_ctrl.line_length = ctrl_i.ch_fpga_func0_output0_len;
    ctrl_streamer_o.ch_fpga_func0_output0_sink_ctrl.addressgen_ctrl.feat_stride = '0;
    ctrl_streamer_o.ch_fpga_func0_output0_sink_ctrl.addressgen_ctrl.feat_length = 1;
    ctrl_streamer_o.ch_fpga_func0_output0_sink_ctrl.addressgen_ctrl.base_addr   = reg_file_i.hwpe_params[MAC_REG_ch_fpga_func0_output0_ADDR] + (flags_uloop_i.offs[MAC_UCODE_ch_fpga_func0_output0_OFFS]);
    ctrl_streamer_o.ch_fpga_func0_output0_sink_ctrl.addressgen_ctrl.feat_roll   = '0;
    ctrl_streamer_o.ch_fpga_func0_output0_sink_ctrl.addressgen_ctrl.loop_outer  = '0;
    ctrl_streamer_o.ch_fpga_func0_output0_sink_ctrl.addressgen_ctrl.realign_type = '0;

    // engine
    ctrl_engine_o.clear      = '1;
    ctrl_engine_o.enable     = '1;
    ctrl_engine_o.start      = '0;
    ctrl_engine_o.op_type    = ctrl_i.op_type;
    //Anchor: pass channel length signal
    ctrl_engine_o.ch_fpga_func0_graph_input_0_len        = ctrl_i.ch_fpga_func0_graph_input_0_len;
    ctrl_engine_o.ch_fpga_func0_output0_len        = ctrl_i.ch_fpga_func0_output0_len;

    // slave
    ctrl_slave_o.done = '0;
    ctrl_slave_o.evt  = '0;

    // real finite-state machine
    next_state   = curr_state;
    //Anchor: reset the start signals
    ctrl_streamer_o.ch_fpga_func0_graph_input_0_source_ctrl.req_start = '0;
    ctrl_streamer_o.ch_fpga_func0_output0_sink_ctrl.req_start   = '0;
    ctrl_uloop_o.enable                     = '0;
    ctrl_uloop_o.clear                      = '0;
    ctrl_uloop_o.ready                      = '0;
    regfile_in_from_hwme.wren               = '0;
    regfile_in_from_hwme.addr               = '0;
    regfile_in_from_hwme.wdata              = '0;
    case(curr_state)
      FSM_IDLE: begin
        // wait for a start signal
        ctrl_uloop_o.clear = '1;
	      ctrl_uloop_o.ready = '0;
        ctrl_engine_o.clear = 1;     // added signals to reset the accelerator states
        //Anchor: disable reg file write
        regfile_in_from_hwme.wren = 1'b0;
        if(flags_slave_i.start) begin
          next_state = FSM_START;
        end
      end
      FSM_START: begin
        //Anchor: reset the stream status
        regfile_in_from_hwme.wren = 1'b1;
        regfile_in_from_hwme.addr = MAC_REG_ch_fpga_func0_output0_READY + REGFILE_N_MANDATORY_REGS + REGFILE_N_MAX_GENERIC_REGS;
        regfile_in_from_hwme.wdata = 1'b0;
        // update the indeces, then load the first feature
        if(flags_streamer_i.ch_fpga_func0_graph_input_0_source_flags.ready_start &
          //flags_streamer_i.ch_in1_source_flags.ready_start &
          //flags_streamer_i.ch_in2_source_flags.ready_start &
           flags_streamer_i.ch_fpga_func0_output0_sink_flags.ready_start) begin
          next_state  = FSM_COMPUTE;
          ctrl_engine_o.start  = 1'b1;
          ctrl_engine_o.clear  = 1'b0;
          ctrl_engine_o.enable = 1'b1;
          ctrl_streamer_o.ch_fpga_func0_graph_input_0_source_ctrl.req_start = 1'b1;
          //ctrl_streamer_o.ch_in1_source_ctrl.req_start = 1'b1;

          // if(~ctrl_i.simple_mul)
          //   ctrl_streamer_o.ch_in2_source_ctrl.req_start = 1'b1;
          ctrl_streamer_o.ch_fpga_func0_output0_sink_ctrl.req_start = 1'b1;
        end
        else begin
          next_state = FSM_WAIT;
        end
      end
      FSM_COMPUTE: begin
        ctrl_engine_o.clear  = 1'b0;
	      ctrl_uloop_o.ready = 1'b1;
        // compute, then update the indeces (and write output if necessary)
        if(flags_streamer_i.ch_fpga_func0_output0_sink_flags.done) begin
          next_state = FSM_UPDATEIDX;
          //Anchor: enable reg file write to indicate the output is ready
          regfile_in_from_hwme.wren = 1'b1;
          //N_RESERVED_REGS - N_MAX_GENERIC_REGS + N_GENERIC_REGS - N_MANDATORY_REGS
          regfile_in_from_hwme.addr = MAC_REG_ch_fpga_func0_output0_READY+ REGFILE_N_MANDATORY_REGS + REGFILE_N_MAX_GENERIC_REGS;
          regfile_in_from_hwme.wdata = 1'b1;
        end else begin
          regfile_in_from_hwme.wren = 1'b0;
        end
      end
      FSM_UPDATEIDX: begin
        //Anchor: disable reg file write
        regfile_in_from_hwme.wren = 1'b0;
        // update the indeces, then go back to load or idle
        if(flags_uloop_i.valid == 1'b0) begin
          ctrl_uloop_o.enable = 1'b1;
	        ctrl_uloop_o.ready = 1'b1;
        end
        else if(flags_uloop_i.done) begin
          next_state = FSM_TERMINATE;
        end
        else if(flags_streamer_i.ch_fpga_func0_graph_input_0_source_flags.ready_start &
                // flags_streamer_i.ch_in1_source_flags.ready_start &
                // flags_streamer_i.ch_in2_source_flags.ready_start &
                flags_streamer_i.ch_fpga_func0_output0_sink_flags.ready_start) begin
          next_state = FSM_COMPUTE;
          ctrl_engine_o.start  = 1'b1;
          ctrl_engine_o.clear  = 1'b0;
          ctrl_engine_o.enable = 1'b1;
          ctrl_streamer_o.ch_fpga_func0_graph_input_0_source_ctrl.req_start = 1'b1;
          // ctrl_streamer_o.ch_in1_source_ctrl.req_start = 1'b1;
          // if(~ctrl_i.simple_mul)
          //   ctrl_streamer_o.ch_in2_source_ctrl.req_start = 1'b1;
          ctrl_streamer_o.ch_fpga_func0_output0_sink_ctrl.req_start = 1'b1;
        end
        else begin
          next_state = FSM_WAIT;
        end
      end
      FSM_WAIT: begin
        //Anchor: disable reg file write
        regfile_in_from_hwme.wren = 1'b0;
        // wait for the flags to be ok then go back to load
        ctrl_engine_o.clear  = 1'b0;
        ctrl_engine_o.enable = 1'b0;
        ctrl_uloop_o.enable  = 1'b0;
        if(flags_streamer_i.ch_fpga_func0_graph_input_0_source_flags.ready_start &
          //  flags_streamer_i.ch_in1_source_flags.ready_start &
          //  flags_streamer_i.ch_in2_source_flags.ready_start &
           flags_streamer_i.ch_fpga_func0_output0_sink_flags.ready_start) begin
          next_state = FSM_COMPUTE;
          ctrl_engine_o.start = 1'b1;
          ctrl_engine_o.enable = 1'b1;
          ctrl_streamer_o.ch_fpga_func0_graph_input_0_source_ctrl.req_start = 1'b1;
          // ctrl_streamer_o.ch_in1_source_ctrl.req_start = 1'b1;
          // if(~ctrl_i.simple_mul)
          //   ctrl_streamer_o.ch_in2_source_ctrl.req_start = 1'b1;
          ctrl_streamer_o.ch_fpga_func0_output0_sink_ctrl.req_start   = 1'b1;
        end
      end
      FSM_TERMINATE: begin
        //Anchor: disable reg file write
        regfile_in_from_hwme.wren = 1'b0;
        // wait for the flags to be ok then go back to idle
        ctrl_engine_o.clear  = 1'b0;
        ctrl_engine_o.enable = 1'b0;
        if(
          //  flags_streamer_i.ch_fpga_func0_graph_input_0_source_flags.ready_start &
          //  flags_streamer_i.ch_in1_source_flags.ready_start &
          //  flags_streamer_i.ch_in2_source_flags.ready_start &
           flags_streamer_i.ch_fpga_func0_output0_sink_flags.ready_start) begin
          next_state = FSM_IDLE;
          ctrl_slave_o.done = 1'b1;
        end
      end
    endcase // curr_state
  end

endmodule // mac_fsm
