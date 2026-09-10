module cpu (
    input clk,
    input resetn, // Reset activates on low signal
    input alu_src_imm,
    input [31:0] writeback_data,
    input writeback_en,
    input [4:0] rs1_addr,
    input [4:0] rs2_addr,
    input [4:0] rd_addr
);

// ========================================
// Fetch decode execute state machine
// ========================================
localparam FETCH_INSTR = 0,
           FETCH_REGS = 1,
           EXECUTE_INSTR = 2;
reg [1:0] state = FETCH_INSTR;
always @(posedge clk) begin
    if(!resetn) begin
	 PC    <= 0;
	 state <= FETCH_INSTR;
	 instr <= 32'b0000000_00000_00000_000_00000_0110011; // NOP
      end else begin
	 if(writeback_en && rdId != 0) begin
	    RegisterBank[rdId] <= writeback_data;
	 end
    case (state)
        FETCH_INSTR: begin
            instr <= MEM[PC];
            state <= FETCH_REGS;
        end
        FETCH_REGS: begin
            rs1 <= RegisterBank[rs1_addr];
            rs2 <= RegisterBank[rs2_addr];
            state <= EXECUTE_INSTR;
        end
        EXECUTE_INSTR: begin
            PC <= PC + 4;
            state <= FETCH_INSTR;
        end
        default: state <= FETCH_INSTR;
    endcase
      end
end



    // ========================================
    // Mux to select between rs2 and immediate value for ALU input
    // ========================================
    wire [31:0] alu_in2 = alu_src_imm ? imm : rs2_data;
endmodule
