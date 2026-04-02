module control_unit (
    input  wire [31:0] instr,
    input  wire        br_eq,
    input  wire        br_lt,
    output reg         pc_sel,
    output reg  [2:0]  imm_sel,
    output reg         reg_wen,
    output reg         br_un,
    output reg         b_sel,
    output reg         a_sel,
    output reg  [3:0]  alu_sel,
    output reg         mem_rw,
    output reg  [1:0]  wb_sel
);

    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    localparam IMM_I = 3'b000;
    localparam IMM_S = 3'b001;
    localparam IMM_B = 3'b010;
    localparam IMM_U = 3'b011;
    localparam IMM_J = 3'b100;

    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLT  = 4'b0101;
    localparam ALU_SLTU = 4'b0110;
    localparam ALU_SLL  = 4'b0111;
    localparam ALU_SRL  = 4'b1000;
    localparam ALU_SRA  = 4'b1001;

    localparam WB_MEM = 2'b00;
    localparam WB_ALU = 2'b01;
    localparam WB_PC4 = 2'b10;

    always @(*) begin
        // default
        pc_sel  = 1'b0;
        imm_sel = IMM_I;
        reg_wen = 1'b0;
        br_un   = 1'b0;
        b_sel   = 1'b0;
        a_sel   = 1'b0;
        alu_sel = ALU_ADD;
        mem_rw  = 1'b0;
        wb_sel  = WB_ALU;

        case (opcode)
            7'b0110011: begin // R-type
                reg_wen = 1'b1;
                a_sel   = 1'b0;
                b_sel   = 1'b0;
                wb_sel  = WB_ALU;

                case (funct3)
                    3'b000: alu_sel = (funct7 == 7'b0100000) ? ALU_SUB : ALU_ADD;
                    3'b111: alu_sel = ALU_AND;
                    3'b110: alu_sel = ALU_OR;
                    3'b100: alu_sel = ALU_XOR;
                    3'b010: alu_sel = ALU_SLT;
                    3'b011: alu_sel = ALU_SLTU;
                    3'b001: alu_sel = ALU_SLL;
                    3'b101: alu_sel = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
                endcase
            end

            7'b0010011: begin // I-type arithmetic
                reg_wen = 1'b1;
                imm_sel = IMM_I;
                a_sel   = 1'b0;
                b_sel   = 1'b1;
                wb_sel  = WB_ALU;

                case (funct3)
                    3'b000: alu_sel = ALU_ADD;  // addi
                    3'b111: alu_sel = ALU_AND;  // andi
                    3'b110: alu_sel = ALU_OR;   // ori
                    3'b100: alu_sel = ALU_XOR;  // xori
                    3'b010: alu_sel = ALU_SLT;  // slti
                    3'b011: alu_sel = ALU_SLTU; // sltiu
                    3'b001: alu_sel = ALU_SLL;  // slli
                    3'b101: alu_sel = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
                endcase
            end

            7'b0000011: begin // load (lw)
                reg_wen = 1'b1;
                imm_sel = IMM_I;
                a_sel   = 1'b0;
                b_sel   = 1'b1;
                alu_sel = ALU_ADD;
                wb_sel  = WB_MEM;
            end

            7'b0100011: begin // store (sw)
                imm_sel = IMM_S;
                a_sel   = 1'b0;
                b_sel   = 1'b1;
                alu_sel = ALU_ADD;
                mem_rw  = 1'b1;
            end

            7'b1100011: begin // branch
                imm_sel = IMM_B;
                a_sel   = 1'b1; // PC
                b_sel   = 1'b1; // imm
                alu_sel = ALU_ADD; // target = PC + imm

                case (funct3)
                    3'b000: pc_sel = br_eq;           // beq
                    3'b001: pc_sel = ~br_eq;          // bne
                    3'b100: pc_sel = br_lt;           // blt
                    3'b101: pc_sel = br_eq | ~br_lt;  // bge
                    3'b110: begin br_un = 1'b1; pc_sel = br_lt; end      // bltu
                    3'b111: begin br_un = 1'b1; pc_sel = br_eq | ~br_lt; end // bgeu
                endcase
            end

            7'b1101111: begin // jal
                reg_wen = 1'b1;
                imm_sel = IMM_J;
                a_sel   = 1'b1; // PC
                b_sel   = 1'b1; // imm
                alu_sel = ALU_ADD;
                wb_sel  = WB_PC4;
                pc_sel  = 1'b1;
            end

            7'b1100111: begin // jalr
                reg_wen = 1'b1;
                imm_sel = IMM_I;
                a_sel   = 1'b0; // rs1
                b_sel   = 1'b1; // imm
                alu_sel = ALU_ADD;
                wb_sel  = WB_PC4;
                pc_sel  = 1'b1;
            end

            7'b0110111: begin // lui
                reg_wen = 1'b1;
                imm_sel = IMM_U;
                a_sel   = 1'b0;
                b_sel   = 1'b1;
                alu_sel = ALU_ADD;
                wb_sel  = WB_ALU;
            end

            7'b0010111: begin // auipc
                reg_wen = 1'b1;
                imm_sel = IMM_U;
                a_sel   = 1'b1; // PC
                b_sel   = 1'b1; // imm
                alu_sel = ALU_ADD;
                wb_sel  = WB_ALU;
            end
        endcase
    end
endmodule