// Synchronous FIFO Buffer

// Module:
//   1) sync_fifo

// 1) SYNCHRONOUS FIFO

// Purpose:
// Store data in first-in, first-out order
// Track how many values are currently stored
// Assert full flag when FIFO reaches DEPTH
// Assert empty flag when FIFO has no stored values
// Detect overflow and underflow attempts

module sync_fifo #(
    parameter DATA_WL = 8,
    parameter DEPTH = 16,
    parameter ADDR_WL = 4,
    parameter COUNT_WL = 5
)(
    input CLK,
    input RESET,

    input write_en,
    input read_en,
    input [DATA_WL-1:0] write_data,

    output reg [DATA_WL-1:0] read_data,
    output reg [COUNT_WL-1:0] count,
    output reg overflow,
    output reg underflow,
    output full,
    output empty
);

    reg [DATA_WL-1:0] memory [0:DEPTH-1];   // FIFO storage array
    reg [ADDR_WL-1:0] write_ptr;     // points to next write location
    reg [ADDR_WL-1:0] read_ptr;    // points to next read location

    wire can_read;   // internal valid read signal
    wire can_write;      // internal valid write signal

    assign full = (count == DEPTH);    // FIFO is full when count = 16
    assign empty = (count == 0);   // FIFO is empty when count = 0

    assign can_read = read_en && !empty;  // read only if FIFO has data
    assign can_write = write_en && (!full || can_read);  // write if space exists or read frees space

    always @(posedge CLK or posedge RESET) begin // sync reset
        if (RESET) begin
            write_ptr <= 4'd0;   // reset write pointer
            read_ptr <= 4'd0;      // reset read pointer
            read_data <= 8'd0;    // clear output data
            count <= 5'd0;   // FIFO starts empty
            overflow <= 1'b0;     // clear overflow flag
            underflow <= 1'b0;   // clear underflow flag
        end
        else begin
            overflow <= write_en && full && !can_read;   // blocked write while full
            underflow <= read_en && empty;    // blocked read while empty

            if (can_write) begin
                memory[write_ptr] <= write_data;    // store new data

                if (write_ptr == DEPTH - 1) begin
                    write_ptr <= 4'd0;   // wrap back to first slot
                end
                else begin
                    write_ptr <= write_ptr + 1'b1;     // move to next write slot
                end
            end

            if (can_read) begin 
                read_data <= memory[read_ptr];   // output oldest stored data

                if (read_ptr == DEPTH - 1) begin
                    read_ptr <= 4'd0;      // wrap back to first slot
                end
                else begin
                    read_ptr <= read_ptr + 1'b1;   // move to next read slot
                end
            end

            if (can_write && !can_read) begin // WRITE only
                count <= count + 1'b1;    // write only increases count
            end
            else if (!can_write && can_read) begin // READ only
                count <= count - 1'b1;      // read only decreases count
            end
            else begin // NO READ/WRITE
                count <= count;   // same count for no-op or read/write
            end
        end
    end
endmodule