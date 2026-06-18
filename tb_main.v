`timescale 1ns / 1ns

module tb_sync_fifo;

    parameter DATA_WL = 8;
    parameter DEPTH = 16;
    parameter ADDR_WL = 4;
    parameter COUNT_WL = 5;
    parameter ClockPeriod = 10;

    reg CLK;
    reg RESET;
    reg write_en;
    reg read_en;
    reg [DATA_WL-1:0] write_data;

    wire [DATA_WL-1:0] read_data;
    wire [COUNT_WL-1:0] count;
    wire overflow;
    wire underflow;
    wire full;
    wire empty;

    integer errors;
    integer i;

    sync_fifo #(
        .DATA_WL(DATA_WL),
        .DEPTH(DEPTH),
        .ADDR_WL(ADDR_WL),
        .COUNT_WL(COUNT_WL)
    ) UUT (
        .CLK(CLK),
        .RESET(RESET),
        .write_en(write_en),
        .read_en(read_en),
        .write_data(write_data),
        .read_data(read_data),
        .count(count),
        .overflow(overflow),
        .underflow(underflow),
        .full(full),
        .empty(empty)
    );

    initial CLK = 1'b0;
    always #(ClockPeriod / 2) CLK = ~CLK;   // free-running clock

    initial begin
        $dumpfile("waveforms/sync_fifo.vcd");   // GTKWave file
        $dumpvars(0, tb_sync_fifo);           
    end

    initial begin
        errors = 0;
        RESET = 1'b0;
        write_en = 1'b0;
        read_en = 1'b0;
        write_data = 8'd0;

        // TEST 1: reset behavior
        RESET = 1'b1;   // apply reset
        @(posedge CLK);
        RESET = 1'b0;
        @(posedge CLK);   // settle after reset

        if (empty != 1'b1 || full != 1'b0 || count != 5'd0) begin
            errors = errors + 1;   // reset failed
        end

        // TEST 2: FIFO order
        write_data = 8'd10;   // write first value
        write_en = 1'b1;
        @(posedge CLK);
        write_en = 1'b0;
        @(posedge CLK);

        write_data = 8'd20;   // write second value
        write_en = 1'b1;
        @(posedge CLK);
        write_en = 1'b0;
        @(posedge CLK);

        write_data = 8'd30;   // write third value
        write_en = 1'b1;
        @(posedge CLK);
        write_en = 1'b0;
        @(posedge CLK);

        read_en = 1'b1;   // read first value
        @(posedge CLK);
        read_en = 1'b0;
        @(posedge CLK);
        if (read_data != 8'd10) errors = errors + 1;   // expect 10

        read_en = 1'b1;   // read second value
        @(posedge CLK);
        read_en = 1'b0;
        @(posedge CLK);
        if (read_data != 8'd20) errors = errors + 1;   // expect 20

        read_en = 1'b1;   // read third value
        @(posedge CLK);
        read_en = 1'b0;
        @(posedge CLK);
        if (read_data != 8'd30) errors = errors + 1;   // expect 30

        // TEST 3: full flag
        for (i = 1; i <= DEPTH; i = i + 1) begin
            write_data = i;   // fill FIFO
            write_en = 1'b1;
            @(posedge CLK);
            write_en = 1'b0;
            @(posedge CLK);
        end

        if (full != 1'b1 || count != 5'd16) begin
            errors = errors + 1;   // full failed
        end

        // TEST 4: overflow flag
        write_data = 8'd99;   // write while full
        write_en = 1'b1;
        @(posedge CLK);
        #1;

        if (overflow != 1'b1) begin
            errors = errors + 1;   // overflow failed
        end

        write_en = 1'b0;
        write_data = 8'd0;
        @(posedge CLK);

        // TEST 5: pointer wraparound
        read_en = 1'b1;   // free slot 1
        @(posedge CLK);
        read_en = 1'b0;
        @(posedge CLK);

        read_en = 1'b1;   // free slot 2
        @(posedge CLK);
        read_en = 1'b0;
        @(posedge CLK);

        write_data = 8'd100;   // write into reused slot
        write_en = 1'b1;
        @(posedge CLK);
        write_en = 1'b0;
        @(posedge CLK);

        write_data = 8'd101;   // write into reused slot
        write_en = 1'b1;
        @(posedge CLK);
        write_en = 1'b0;
        @(posedge CLK);

        for (i = 3; i <= 16; i = i + 1) begin
            read_en = 1'b1;   // drain old values
            @(posedge CLK);
            read_en = 1'b0;
            @(posedge CLK);
        end

        read_en = 1'b1;   // read wrapped value
        @(posedge CLK);
        read_en = 1'b0;
        @(posedge CLK);
        if (read_data != 8'd100) errors = errors + 1;   // expect 100

        read_en = 1'b1;   // read wrapped value
        @(posedge CLK);
        read_en = 1'b0;
        @(posedge CLK);
        if (read_data != 8'd101) errors = errors + 1;   // expect 101

        // TEST 6: empty flag
        if (empty != 1'b1 || count != 5'd0) begin
            errors = errors + 1;   // empty failed
        end

        // TEST 7: underflow flag
        read_en = 1'b1;   // read while empty
        @(posedge CLK);
        #1;

        if (underflow != 1'b1) begin
            errors = errors + 1;   // underflow failed
        end

        read_en = 1'b0;
        @(posedge CLK);

        if (errors == 0) begin
            $display("All FIFO tests passed.");
        end
        else begin
            $display("FIFO test failed with %0d error(s).", errors);
        end

        #20;
        $finish;
    end

endmodule
