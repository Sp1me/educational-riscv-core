    `include "defines.vh"
    module decoder (
        input [31:0] instr,

        output [6:0] opcode,
        output [4:0] rs1,
        output [4:0] rs2,
        output [4:0] rd,
        output [2:0] funct3,
        output [6:0] funct7,
        output reg [3:0] alu_op,
        output reg alu_src_imm,
        output reg [31:0] imm);

        // ========================================
        //Assigning constants based on instruction format
        // ========================================
        assign rs1 = instr[19:15];
        assign rs2 = instr[24:20];
        assign rd = instr[11:7];
        assign funct3 = instr[14:12];
        assign funct7 = instr[31:25];
        assign opcode = instr[6:0];

        // ========================================
        // Immediate decoding mappings
        // ========================================
        wire [31:0] Uimm={instr[31], instr[30:12], {12{1'b0}}};
        wire [31:0] Iimm={{21{instr[31]}}, instr[30:20]};
        wire [31:0] Simm={{21{instr[31]}}, instr[30:25],instr[11:7]};
        wire [31:0] Bimm={{20{instr[31]}}, instr[7],instr[30:25],instr[11:8],1'b0};
        wire [31:0] Jimm={{12{instr[31]}}, instr[19:12],instr[20],instr[30:21],1'b0};

    always @(*) begin
            if (isALUimm || isJALR || isLoad)
                imm = Iimm;
            else if (isStore)
                imm = Simm;
            else if (isBranch)
                imm = Bimm;
            else if (isLUI || isAUIPC)
                imm = Uimm;
            else if (isJAL)
                imm = Jimm;
            else
                imm = 32'b0;
    end

        // ========================================
        //Defining instructions based on opcode
        // ========================================
        wire isALUreg  =  (instr[6:0] == 7'b0110011); // rd <- rs1 OP rs2
        wire isALUimm  =  (instr[6:0] == 7'b0010011); // rd <- rs1 OP Iimm
        wire isBranch  =  (instr[6:0] == 7'b1100011); // if(rs1 OP rs2) PC<-PC+Bimm
        wire isJALR    =  (instr[6:0] == 7'b1100111); // rd <- PC+4; PC<-rs1+Iimm
        wire isJAL     =  (instr[6:0] == 7'b1101111); // rd <- PC+4; PC<-PC+Jimm
        wire isAUIPC   =  (instr[6:0] == 7'b0010111); // rd <- PC + Uimm
        wire isLUI     =  (instr[6:0] == 7'b0110111); // rd <- Uimm
        wire isLoad    =  (instr[6:0] == 7'b0000011); // rd <- mem[rs1+Iimm]
        wire isStore   =  (instr[6:0] == 7'b0100011); // mem[rs1+Simm] <- rs2
        wire isSYSTEM  =  (instr[6:0] == 7'b1110011); // special


    always @(*) begin
        alu_op = `ALU_ADD;   // default
        if (isALUreg || isALUimm) begin
            case (funct3)
                3'b000: begin
                    if (funct7[5] && isALUreg)
                        alu_op = `ALU_SUB;
                    else
                        alu_op = `ALU_ADD;
                end
                3'b001:
                    alu_op = `ALU_SLL;
                3'b010:
                    alu_op = `ALU_SLT;
                3'b011:
                    alu_op = `ALU_SLTU;
                3'b100:
                    alu_op = `ALU_XOR;
                3'b101:begin
                    if (instr[30])
                        alu_op = `ALU_SRA;
                    else
                        alu_op = `ALU_SRL;
                end
                3'b110:
                    alu_op = `ALU_OR;
                3'b111:
                    alu_op = `ALU_AND;

            endcase
        end
    end


    always @(*) begin
        alu_src_imm = 1'b0;  // default: use rs2
            if (isALUimm || isLoad || isStore || isJALR)
                alu_src_imm = 1'b1;
    end

    endmodule
