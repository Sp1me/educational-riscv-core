module cpu (
    input clk,
    input resetn 
);
reg [31:0] PC;
reg [31:0] instr;
reg [31:0] InstrMem [1023:0]; // 4KB instruction memory

wire [4:0] rs1_addr;
wire [4:0] rs2_addr;
wire [4:0] rd_addr;
wire alu_src_imm;

wire [31:0] rs1_data;
wire [31:0] rs2_data;
wire [31:0] imm;

wire [3:0] alu_op;
wire isJAL, isJALR, isALUimm, isALUreg;
wire [31:0] operand_b;
wire [31:0] alu_result;

wire reg_write_en;
wire writeback_en = resetn && 
                    reg_write_en && 
                    (state == EXECUTE_INSTR) && 
                    (isALUreg || isALUimm || isJAL || isJALR); 
wire [31:0] writeback_data = (isJAL || isJALR) ? (PC + 4) : alu_result; //WHY IS WRITEBACK DATA FOR JAL AND JALR PC + 4? ISN'T IT SUPPOSED TO BE THE RETURN ADDRESS? OR IS THAT WHAT PC + 4 IS?
wire [31:0] nextPC = 
            isJAL  ? 
            PC + imm : isJALR ? 
            (rs1_data + imm) & 32'hFFFFFFFE: PC + 4; 

// ========================================
// Fetch decode execute state machine
// ========================================
localparam FETCH_INSTR = 0,
           FETCH_REGS = 1,
           EXECUTE_INSTR = 2;
reg [1:0] state = FETCH_INSTR;
always @(posedge clk) begin
    if (!resetn) begin
        PC <= 32'b0;
        state <= FETCH_INSTR;
        instr <= 32'h00000013; //NOP instruction
    end else begin
        case (state)
            FETCH_INSTR: begin
                instr <= InstrMem[PC[31:2]];
                state <= FETCH_REGS;
            end
            FETCH_REGS: begin
                state <= EXECUTE_INSTR; 
            end
            EXECUTE_INSTR: begin
                PC <= nextPC;
                state <= FETCH_INSTR;
            end
            default: state <= FETCH_INSTR;
        endcase
    end
end

// ========================================
// Mux to select between rs2 and immediate value for ALU input
// ========================================
assign operand_b = alu_src_imm ? imm : rs2_data; 

// ========================================
// Decoder instantiation
// ========================================
decoder decoder_inst (
    .instr(instr),
    .rs1(rs1_addr),
    .rs2(rs2_addr),
    .rd(rd_addr),
    .alu_op(alu_op),
    .imm(imm),
    .alu_src_imm(alu_src_imm),
    .reg_write_en(reg_write_en),
    .isJAL(isJAL),
    .isJALR(isJALR),
    .isALUimm(isALUimm),
    .isALUreg(isALUreg)
);

// ========================================
// ALU instantiation
// ========================================
alu alu_inst (
    .operand_a(rs1_data),
    .operand_b(operand_b),
    .alu_op(alu_op),
    .alu_result(alu_result)
);

// ========================================
// Register file instantiation
// ========================================
register_file reg_file_inst (
    .clk(clk),
    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),
    .rd_addr(rd_addr),
    .writeback_en(writeback_en),
    .writeback_data(writeback_data),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
);

endmodule
