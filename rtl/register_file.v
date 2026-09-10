module register_file (
    input clk, 
    input rst, 
    input [4:0] rs1_addr,
    input [4:0] rs2_addr,
    input [4:0] rd_addr,
    input [31:0] rd_data,

    output [31:0] rs1_data,
    output [31:0] rs2_data
);

reg [31:0] RegisterBank [31:0];



endmodule
