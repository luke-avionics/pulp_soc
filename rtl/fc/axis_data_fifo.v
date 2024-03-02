`timescale 1ns / 1ps

module axis_fifo #
(
    parameter AXIS_DATA_WIDTH_FIFO_IN = 32,
    parameter AXIS_DATA_WIDTH_FIFO_OUT = 16,
    parameter MEM_ADDR_WIDTH = 12,
    parameter MEM_DATA_WIDTH = 16,
    parameter WR_PTR_STEP = 2,
    parameter RD_PTR_STEP = 1
)
(
    /*
     * Ports to pipe in the data to the FIFO
     */
    input  wire                   wr_aclk,
    input  wire                   wr_rstn,
    input  wire [AXIS_DATA_WIDTH_FIFO_IN-1:0]  wr_axis_data,
    input  wire                   wr_axis_vld,
    output wire                   wr_axis_rdy,
    
    /*
     * Ports to get the data to the FIFO
     */
    input  wire                   rd_aclk,
    input  wire                   rd_rstn,
    output wire [AXIS_DATA_WIDTH_FIFO_OUT-1:0]  rd_axis_data,
    output wire                   rd_axis_vld,
    input  wire                   rd_axis_rdy
);

parameter WR_PTR_STEP_EXTRA = WR_PTR_STEP*2;
parameter RD_PTR_STEP_EXTRA = RD_PTR_STEP*2;

reg [MEM_ADDR_WIDTH:0] wr_ptr_reg = {MEM_ADDR_WIDTH+1{1'b0}}, wr_ptr_next;
reg [MEM_ADDR_WIDTH:0] wr_ptr_extra_step_reg = WR_PTR_STEP;
reg [MEM_ADDR_WIDTH:0] wr_ptr_extra_step_next = WR_PTR_STEP;
reg [MEM_ADDR_WIDTH:0] wr_ptr_gray_reg = {MEM_ADDR_WIDTH+1{1'b0}}, wr_ptr_gray_next;
reg [MEM_ADDR_WIDTH:0] wr_addr_reg = {MEM_ADDR_WIDTH+1{1'b0}};
reg [MEM_ADDR_WIDTH:0] rd_ptr_reg = {MEM_ADDR_WIDTH+1{1'b0}}, rd_ptr_next;
reg [MEM_ADDR_WIDTH:0] rd_ptr_extra_step_reg = RD_PTR_STEP;
reg [MEM_ADDR_WIDTH:0] rd_ptr_extra_step_next = RD_PTR_STEP;
reg [MEM_ADDR_WIDTH:0] rd_ptr_gray_reg = {MEM_ADDR_WIDTH+1{1'b0}}, rd_ptr_gray_next;
reg [MEM_ADDR_WIDTH:0] rd_addr_reg = {MEM_ADDR_WIDTH+1{1'b0}};

reg [MEM_ADDR_WIDTH:0] wr_ptr_gray_sync1_reg = {MEM_ADDR_WIDTH+1{1'b0}};
reg [MEM_ADDR_WIDTH:0] wr_ptr_gray_sync2_reg = {MEM_ADDR_WIDTH+1{1'b0}};
reg [MEM_ADDR_WIDTH:0] rd_ptr_gray_sync1_reg = {MEM_ADDR_WIDTH+1{1'b0}};
reg [MEM_ADDR_WIDTH:0] rd_ptr_gray_sync2_reg = {MEM_ADDR_WIDTH+1{1'b0}};
reg [MEM_ADDR_WIDTH:0] wr_ptr_sync1_reg = {MEM_ADDR_WIDTH+1{1'b0}};
reg [MEM_ADDR_WIDTH:0] wr_ptr_sync2_reg = {MEM_ADDR_WIDTH+1{1'b0}};
reg [MEM_ADDR_WIDTH:0] rd_ptr_sync1_reg = {MEM_ADDR_WIDTH+1{1'b0}};
reg [MEM_ADDR_WIDTH:0] rd_ptr_sync2_reg = {MEM_ADDR_WIDTH+1{1'b0}};
reg [MEM_ADDR_WIDTH:0] wr_ptr_extra_step_sync1_reg = WR_PTR_STEP;
reg [MEM_ADDR_WIDTH:0] wr_ptr_extra_step_sync2_reg = WR_PTR_STEP;
reg [MEM_ADDR_WIDTH:0] rd_ptr_extra_step_sync1_reg = RD_PTR_STEP;
reg [MEM_ADDR_WIDTH:0] rd_ptr_extra_step_sync2_reg = RD_PTR_STEP;

reg wr_rst_sync1_reg = 1'b1;
reg wr_rst_sync2_reg = 1'b1;
reg wr_rst_sync3_reg = 1'b1;
reg rd_rst_sync1_reg = 1'b1;
reg rd_rst_sync2_reg = 1'b1;
reg rd_rst_sync3_reg = 1'b1;

reg [MEM_DATA_WIDTH-1:0] mem[(2**MEM_ADDR_WIDTH)-1:0];
reg [AXIS_DATA_WIDTH_FIFO_OUT-1:0] mem_read_data_reg = {AXIS_DATA_WIDTH_FIFO_OUT{1'b0}};
reg mem_read_data_valid_reg = 1'b0, mem_read_data_valid_next;
wire [AXIS_DATA_WIDTH_FIFO_IN-1:0] mem_write_data;

reg [AXIS_DATA_WIDTH_FIFO_OUT-1:0] rd_data_reg = {AXIS_DATA_WIDTH_FIFO_OUT{1'b0}};

reg rd_axis_vld_reg = 1'b0, rd_axis_vld_next;

// TODO: check for full status based on comparison between wr_ptr_gray_reg and rd_ptr_gray_sync2_reg
wire full = 
            //  ((wr_ptr_gray_reg[MEM_ADDR_WIDTH] != rd_ptr_gray_sync2_reg[MEM_ADDR_WIDTH]) &&
            //   (wr_ptr_gray_reg[MEM_ADDR_WIDTH-1] != rd_ptr_gray_sync2_reg[MEM_ADDR_WIDTH-1]) &&
            //   (wr_ptr_gray_reg[MEM_ADDR_WIDTH-2:0] == rd_ptr_gray_sync2_reg[MEM_ADDR_WIDTH-2:0])
            //  ) ||
             (
                wr_ptr_extra_step_reg[MEM_ADDR_WIDTH] != rd_ptr_sync2_reg[MEM_ADDR_WIDTH] &&
                wr_ptr_extra_step_reg[MEM_ADDR_WIDTH-1:0] > rd_ptr_sync2_reg[MEM_ADDR_WIDTH-1:0]
             ) ||
             (
                wr_ptr_reg[MEM_ADDR_WIDTH] != rd_ptr_sync2_reg[MEM_ADDR_WIDTH] &&
                wr_ptr_extra_step_reg[MEM_ADDR_WIDTH] == rd_ptr_sync2_reg[MEM_ADDR_WIDTH] 
                
             ); //TODO: use gray code for better robustness


// TODO: check for empty status based on comparison between wr_ptr_gray_reg and rd_ptr_gray_sync2_reg
wire empty = 
             //  (rd_ptr_gray_reg == wr_ptr_gray_sync2_reg) ||
             (rd_ptr_extra_step_reg[MEM_ADDR_WIDTH] == wr_ptr_sync2_reg[MEM_ADDR_WIDTH] &&
              rd_ptr_extra_step_reg[MEM_ADDR_WIDTH-1:0] > wr_ptr_sync2_reg[MEM_ADDR_WIDTH-1:0]
             ) ||
             (rd_ptr_reg[MEM_ADDR_WIDTH] == wr_ptr_sync2_reg[MEM_ADDR_WIDTH] &&
              rd_ptr_extra_step_reg[MEM_ADDR_WIDTH] != wr_ptr_sync2_reg[MEM_ADDR_WIDTH]
             );

// control signals
reg write;
reg read;
reg store_output;

// TODO: complete the logic for wr_axis_rdy
assign wr_axis_rdy = ~full & ~wr_rst_sync3_reg;

assign rd_axis_vld = rd_axis_vld_reg;

assign mem_write_data[AXIS_DATA_WIDTH_FIFO_IN-1:0] = wr_axis_data;
assign rd_axis_data = rd_data_reg[AXIS_DATA_WIDTH_FIFO_OUT-1:0];

// reset synchronization
always @(posedge wr_aclk) begin
    if (!wr_rstn) begin
        wr_rst_sync1_reg <= 1'b1;
        wr_rst_sync2_reg <= 1'b1;
        wr_rst_sync3_reg <= 1'b1;
    end else begin
        wr_rst_sync1_reg <= 1'b0;
        wr_rst_sync2_reg <= wr_rst_sync1_reg | rd_rst_sync1_reg;
        wr_rst_sync3_reg <= wr_rst_sync2_reg;
    end
end

always @(posedge rd_aclk) begin
    if (!rd_rstn) begin
        rd_rst_sync1_reg <= 1'b1;
        rd_rst_sync2_reg <= 1'b1;
        rd_rst_sync3_reg <= 1'b1;
    end else begin
        rd_rst_sync1_reg <= 1'b0;
        rd_rst_sync2_reg <= wr_rst_sync1_reg | rd_rst_sync1_reg;
        rd_rst_sync3_reg <= rd_rst_sync2_reg;
    end
end

// Write logic
always @* begin
    write = 1'b0;

    wr_ptr_next = wr_ptr_reg;
    wr_ptr_gray_next = wr_ptr_gray_reg;
    wr_ptr_extra_step_next = wr_ptr_extra_step_reg;
    
    //TODO: complete the write logic; hint should we always execute the the following signal assignments? or is there a condition that we should check?
    if (wr_axis_vld) begin
        // input data valid
        if (~full) begin
            // not full, perform write
            write = 1'b1;
            wr_ptr_next = wr_ptr_reg + WR_PTR_STEP;
            wr_ptr_extra_step_next = wr_ptr_reg + WR_PTR_STEP_EXTRA;
            wr_ptr_gray_next = wr_ptr_next ^ (wr_ptr_next >> 1);
        end
    end
end

always @(posedge wr_aclk) begin
    if (wr_rst_sync3_reg) begin
        wr_ptr_reg <= {MEM_ADDR_WIDTH+1{1'b0}};
        wr_ptr_extra_step_reg <= WR_PTR_STEP;
        wr_ptr_gray_reg <= {MEM_ADDR_WIDTH+1{1'b0}};
    end else begin
        wr_ptr_reg <= wr_ptr_next;
        wr_ptr_extra_step_reg <= wr_ptr_extra_step_next;
        wr_ptr_gray_reg <= wr_ptr_gray_next;
    end
    wr_addr_reg <= wr_ptr_next;
end

genvar i;
generate
    for (i = 0; i < WR_PTR_STEP; i = i + 1) begin : MEM_WRITE
        always @(posedge wr_aclk) begin
            if (write) begin
                // write data mem_write_data[(i+1)*MEM_DATA_WIDTH-1:i*MEM_DATA_WIDTH] to  mem[wr_addr_reg[MEM_ADDR_WIDTH-1:0]+i]
                mem[wr_addr_reg[MEM_ADDR_WIDTH-1:0]+i] <= mem_write_data[i*MEM_DATA_WIDTH+:MEM_DATA_WIDTH];
            end
        end
    end
endgenerate

// pointer synchronization
always @(posedge wr_aclk) begin
    if (wr_rst_sync3_reg) begin
        rd_ptr_gray_sync1_reg <= {MEM_ADDR_WIDTH+1{1'b0}};
        rd_ptr_gray_sync2_reg <= {MEM_ADDR_WIDTH+1{1'b0}};
        rd_ptr_sync1_reg <= {MEM_ADDR_WIDTH+1{1'b0}};
        rd_ptr_sync2_reg <= {MEM_ADDR_WIDTH+1{1'b0}};
        rd_ptr_extra_step_sync1_reg <= RD_PTR_STEP;
        rd_ptr_extra_step_sync2_reg <= RD_PTR_STEP;
    end else begin
        rd_ptr_gray_sync1_reg <= rd_ptr_gray_reg;
        rd_ptr_gray_sync2_reg <= rd_ptr_gray_sync1_reg;
        rd_ptr_sync1_reg <= rd_ptr_reg;
        rd_ptr_sync2_reg <= rd_ptr_sync1_reg;
        rd_ptr_extra_step_sync1_reg <= rd_ptr_extra_step_reg;
        rd_ptr_extra_step_sync2_reg <= rd_ptr_extra_step_sync1_reg;
    end
end

always @(posedge rd_aclk) begin
    if (rd_rst_sync3_reg) begin
        wr_ptr_gray_sync1_reg <= {MEM_ADDR_WIDTH+1{1'b0}};
        wr_ptr_gray_sync2_reg <= {MEM_ADDR_WIDTH+1{1'b0}};
        wr_ptr_sync1_reg <= {MEM_ADDR_WIDTH+1{1'b0}};
        wr_ptr_sync2_reg <= {MEM_ADDR_WIDTH+1{1'b0}};
        wr_ptr_extra_step_sync1_reg <= WR_PTR_STEP;
        wr_ptr_extra_step_sync2_reg <= WR_PTR_STEP;
    end else begin
        wr_ptr_gray_sync1_reg <= wr_ptr_gray_reg;
        wr_ptr_gray_sync2_reg <= wr_ptr_gray_sync1_reg;
        wr_ptr_sync1_reg <= wr_ptr_reg;
        wr_ptr_sync2_reg <= wr_ptr_sync1_reg;
        wr_ptr_extra_step_sync1_reg <= wr_ptr_extra_step_reg;
        wr_ptr_extra_step_sync2_reg <= wr_ptr_extra_step_sync1_reg;
    end
end

// Read logic
always @* begin
    read = 1'b0;

    rd_ptr_next = rd_ptr_reg;
    rd_ptr_extra_step_next = rd_ptr_extra_step_reg;
    rd_ptr_gray_next = rd_ptr_gray_reg;

    mem_read_data_valid_next = mem_read_data_valid_reg;

    //TODO: complete the output read logic;
    if (store_output | ~mem_read_data_valid_reg) begin
        // output data not valid OR currently being transferred
        if (~empty) begin
            // not empty, perform read
            read = 1'b1;
            mem_read_data_valid_next = 1'b1;
            rd_ptr_next = rd_ptr_reg + RD_PTR_STEP;
            rd_ptr_gray_next = rd_ptr_next ^ (rd_ptr_next >> 1);
            rd_ptr_extra_step_next = rd_ptr_reg + RD_PTR_STEP_EXTRA;
        end else begin
            // empty, invalidate
            mem_read_data_valid_next = 1'b0;
        end
    end
end

always @(posedge rd_aclk) begin
    if (rd_rst_sync3_reg) begin
        rd_ptr_reg <= {MEM_ADDR_WIDTH+1{1'b0}};
        rd_ptr_gray_reg <= {MEM_ADDR_WIDTH+1{1'b0}};
        rd_ptr_extra_step_reg <= RD_PTR_STEP;
        mem_read_data_valid_reg <= 1'b0;
    end else begin
        rd_ptr_reg <= rd_ptr_next;
        rd_ptr_extra_step_reg <= rd_ptr_extra_step_next;
        rd_ptr_gray_reg <= rd_ptr_gray_next;
        mem_read_data_valid_reg <= mem_read_data_valid_next;
    end

    rd_addr_reg <= rd_ptr_next;

end

genvar j;
generate
    for (j = 0; j < RD_PTR_STEP; j = j + 1) begin : MEM_READ
        always @(posedge rd_aclk) begin
            if (read) begin
                // read data from mem[rd_addr_reg[MEM_ADDR_WIDTH-1:0]+j] to mem_read_data_reg[(j+1)*MEM_DATA_WIDTH-1:j*MEM_DATA_WIDTH]
                mem_read_data_reg[j*MEM_DATA_WIDTH+:MEM_DATA_WIDTH]<= mem[rd_addr_reg[MEM_ADDR_WIDTH-1:0]+j];
            end
        end
    end
endgenerate

// Output register
always @* begin
    store_output = 1'b0;

    rd_axis_vld_next = rd_axis_vld_reg;

    //TODO: complete the output register logic;
    if (rd_axis_rdy | ~rd_axis_vld) begin
        store_output = 1'b1;
        rd_axis_vld_next = mem_read_data_valid_reg;
    end
end

always @(posedge rd_aclk) begin
    if (rd_rst_sync3_reg) begin
        rd_axis_vld_reg <= 1'b0;
    end else begin
        rd_axis_vld_reg <= rd_axis_vld_next;
    end

    if (store_output) begin
        rd_data_reg <= mem_read_data_reg;
    end
end

endmodule
