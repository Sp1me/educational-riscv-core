`include "defines.vh"
module alu (
    input [31:0] rs1,
    input [31:0] rs2,
    input [31:0] imm,
    input [3:0] alu_op,

    output reg [31:0] rd,
    output reg [31:0] writeback_data,
    output writeback_en

);

always@(*) begin
    case (alu_op)
        `ALU_ADD: rd = rs1 + rs2;
    endcase
end

endmodule
