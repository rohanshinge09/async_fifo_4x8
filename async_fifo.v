module async_fifo #(
 parameter DEPTH = 4, // FIFO depth
 parameter ADDR_WIDTH = 2
) (
 // Write domain
 input wire wr_clk,
 input wire wr_en,
 input wire [7:0] wr_data,
 output wire full,
 // Read domain
 input wire rd_clk,
 input wire rd_en,
 output reg [7:0] rd_data,
 output wire empty,
 // Global reset (active-low)
 input wire rst_n
);
 reg [7:0] mem[0:DEPTH-1];
 // Pointers with extra MSB for wrap detection
 reg [ADDR_WIDTH:0] wr_ptr = 0;
 reg [ADDR_WIDTH:0] rd_ptr = 0;
 // Write logic
 always @(posedge wr_clk or negedge rst_n) begin
 if (!rst_n)
 wr_ptr <= 0;
 else if (wr_en && !full) begin
 mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
 wr_ptr <= wr_ptr + 1;
 end
 end
 // Read logic
 always @(posedge rd_clk or negedge rst_n) begin
 if (!rst_n) begin
 rd_ptr <= 0;
 rd_data <= 8'h00;
 end else if (rd_en && !empty) begin
 rd_data <= mem[rd_ptr[ADDR_WIDTH-1:0]];
 rd_ptr <= rd_ptr + 1;
 end
 end
 // Full flag
 assign full = (wr_ptr[ADDR_WIDTH] !=rd_ptr[ADDR_WIDTH])
&&(wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);
 // Empty flag
 assign empty = (wr_ptr == rd_ptr);
endmodule
