`timescale 1ns/1ps
module fifo #(parameter DATA_WIDTH=8, DEPTH=32, RAM_DEPTH=32)(
	input clk,
	input rst,
	input wr_en,
	input rd_en,
	input [DATA_WIDTH-1:0] data_in,
	output reg [DATA_WIDTH-1:0] data_out,
	output reg empty,
	output reg full,
	output reg almost_empty,
	output reg almost_full,
	output reg overflow,
	output reg underflow,
	output reg valid,
	output reg [DEPTH:0] fifo_count);

reg [DATA_WIDTH-1:0] mem [DEPTH-1:0];
reg [DEPTH-1:0] wr_ptr, rd_ptr;

assign reg_full = (fifo_count == (RAM_DEPTH-1));
assign reg_empty = (fifo_count == 0);
assign reg_almost_full = (fifo_count == (RAM_DEPTH-2));
assign reg_almost_empty = (fifo_count == 2);

always @(posedge clk or posedge rst)
begin
	if (rst) begin
	wr_ptr <= 0;
	fifo_count <= 0; 
	end
	else if(wr_en) begin
	wr_ptr <= wr_ptr + 1;
	mem[wr_ptr] = data_in;
	fifo_count <= fifo_count + 1;
	end
end

always @(posedge clk or posedge rst)
begin
	if(rst) begin
	rd_ptr <= 0;
	fifo_count = 0;
	end
	else if(rd_en) begin
	rd_ptr <= rd_ptr+1;
	data_out <= mem[rd_ptr];
	fifo_count<=fifo_count - 1;
	end
end

always @(posedge clk or posedge rst)
begin
	empty <= (fifo_count == 0);
	full <= (fifo_count == DEPTH);
	almost_empty <= (fifo_count <= RAM_DEPTH);
	almost_full <= (fifo_count >= DEPTH - RAM_DEPTH);
	overflow <=(wr_en && full);
	underflow <= (rd_en && empty);
end
endmodule
