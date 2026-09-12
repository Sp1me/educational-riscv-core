module register_file (
    input clk, 
    input [4:0] rs1_addr,
    input [4:0] rs2_addr,
    input [4:0] rd_addr,

    input writeback_en,
    input [31:0] writeback_data,

    output [31:0] rs1_data,
    output [31:0] rs2_data
);

reg [31:0] RegisterBank [31:0];

assign rs1_data = (rs1_addr == 5'd0) ? 32'b0 : RegisterBank[rs1_addr];

assign rs2_data = (rs2_addr == 5'd0) ? 32'b0 : RegisterBank[rs2_addr];

always@(posedge clk) begin
    if (writeback_en && rd_addr != 5'd0)
        RegisterBank[rd_addr] <= writeback_data;
end

endmodule
