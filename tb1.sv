`timescale 1ns/1ps

module testbench;
    // Parameters
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 32;
    parameter RAM_DEPTH = 32;

    // Inputs
    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] data_in;

    // Outputs
    wire [DATA_WIDTH-1:0] data_out;
    wire empty;
    wire full;
    wire almost_empty;
    wire almost_full;
    wire overflow;
    wire underflow;
    wire valid;
    wire [DEPTH:0] fifo_count;

    // Instantiate the FIFO
    fifo #(
        .DATA_WIDTH(DATA_WIDTH), 
        .DEPTH(DEPTH), 
        .RAM_DEPTH(RAM_DEPTH)
    ) fifo_inst (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .empty(empty),
        .full(full),
        .almost_empty(almost_empty),
        .almost_full(almost_full),
        .overflow(overflow),
        .underflow(underflow),
        .valid(valid),
        .fifo_count(fifo_count)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Clock period of 10ns
    end

    // Initial Reset
    initial begin
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        data_in = 0;

        // Apply reset
        #10;
        rst = 0;

        // Begin simulation
        #10;
        perform_tests();
        #100 $finish;  // End simulation after some time
    end

    // Test sequences
    task perform_tests;
        integer i;
        begin
            // Write to FIFO
            for (i = 0; i < DEPTH; i = i + 1) begin
                if (!full) begin
                    wr_en = 1;
                    data_in = i;  // Sequential data
                    #10;
                end
                wr_en = 0;
                #10;
            end

            // Read from FIFO
            for (i = 0; i < DEPTH; i = i + 1) begin
                if (!empty) begin
                    rd_en = 1;
                    #10;
                end
                rd_en = 0;
                #10;
            end
        end
    endtask

    // Monitoring changes
    initial begin
	$vcdpluson;
        $monitor("Time = %t, wr_ptr = %d, rd_ptr = %d, Data Out = %h, Full = %b, Empty = %b, Almost Full = %b, Almost Empty = %b, Overflow = %b, Underflow = %b",
                 $time, fifo_inst.wr_ptr, fifo_inst.rd_ptr, data_out, full, empty, almost_full, almost_empty, overflow, underflow);
    end

endmodule


