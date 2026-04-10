module control_unit (
    input  wire [31:0] instr,     // lệnh hiện tại
    input  wire        br_eq,     // kết quả so sánh bằng
    input  wire        br_lt,     // kết quả so sánh nhỏ hơn

    output reg         pc_sel,    // chọn PC tiếp theo
    output reg  [2:0]  imm_sel,   // chọn loại immediate
    output reg         reg_wen,   // cho phép ghi thanh ghi
    output reg         br_un,     // so sánh branch unsigned hay signed
    output reg         b_sel,     // chọn ALU B = rs2 hay imm
    output reg         a_sel,     // chọn ALU A = rs1 hay PC
    output reg  [3:0]  alu_sel,   // chọn phép toán ALU
    output reg         mem_rw,    // ghi data memory
    output reg  [1:0]  wb_sel     // chọn dữ liệu ghi về RegFile
);

    // Tách các trường quan trọng của instruction
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    // Mã chọn loại immediate
    localparam IMM_I = 3'b000;
    localparam IMM_S = 3'b001;
    localparam IMM_B = 3'b010;
    localparam IMM_U = 3'b011;
    localparam IMM_J = 3'b100;

    // Mã chọn ALU
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

    // Mã chọn write-back
    localparam WB_MEM = 2'b00;  // ghi dữ liệu từ memory
    localparam WB_ALU = 2'b01;  // ghi dữ liệu từ ALU
    localparam WB_PC4 = 2'b10;  // ghi PC + 4

    always @(*) begin
        // Giá trị mặc định để tránh latch
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

            // =====================
            // R-type: add, sub, and, or, xor, slt,...
            // =====================
            7'b0110011: begin
                reg_wen = 1'b1;   // ghi kết quả về thanh ghi
                a_sel   = 1'b0;   // ALU A = rs1
                b_sel   = 1'b0;   // ALU B = rs2
                wb_sel  = WB_ALU; // dữ liệu ghi về lấy từ ALU

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

            // =====================
            // I-type arithmetic: addi, andi, ori,...
            // =====================
            7'b0010011: begin
                reg_wen = 1'b1;
                imm_sel = IMM_I;
                a_sel   = 1'b0;   // ALU A = rs1
                b_sel   = 1'b1;   // ALU B = imm
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

            // =====================
            // Load: lw
            // =====================
            7'b0000011: begin
                reg_wen = 1'b1;
                imm_sel = IMM_I;
                a_sel   = 1'b0;   // A = rs1
                b_sel   = 1'b1;   // B = imm
                alu_sel = ALU_ADD; // địa chỉ = rs1 + imm
                wb_sel  = WB_MEM;  // ghi dữ liệu từ memory về thanh ghi
            end

            // =====================
            // Store: sw
            // =====================
            7'b0100011: begin
                imm_sel = IMM_S;
                a_sel   = 1'b0;   // A = rs1
                b_sel   = 1'b1;   // B = imm
                alu_sel = ALU_ADD; // địa chỉ = rs1 + imm
                mem_rw  = 1'b1;   // cho phép ghi memory
            end

            // =====================
            // Branch: beq, bne, blt, bge, bltu, bgeu
            // =====================
            7'b1100011: begin
                imm_sel = IMM_B;
                a_sel   = 1'b1;   // A = PC
                b_sel   = 1'b1;   // B = imm
                alu_sel = ALU_ADD; // target = PC + imm

                case (funct3)
                    3'b000: pc_sel = br_eq;            // beq
                    3'b001: pc_sel = ~br_eq;           // bne
                    3'b100: pc_sel = br_lt;            // blt
                    3'b101: pc_sel = br_eq | ~br_lt;   // bge
                    3'b110: begin
                        br_un = 1'b1;                  // unsigned
                        pc_sel = br_lt;                // bltu
                    end
                    3'b111: begin
                        br_un = 1'b1;                  // unsigned
                        pc_sel = br_eq | ~br_lt;       // bgeu
                    end
                endcase
            end

            // =====================
            // jal
            // =====================
            7'b1101111: begin
                reg_wen = 1'b1;
                imm_sel = IMM_J;
                a_sel   = 1'b1;   // A = PC
                b_sel   = 1'b1;   // B = imm
                alu_sel = ALU_ADD; // target = PC + imm
                wb_sel  = WB_PC4;  // rd = PC + 4
                pc_sel  = 1'b1;    // nhảy
            end

            // =====================
            // jalr
            // =====================
            7'b1100111: begin
                reg_wen = 1'b1;
                imm_sel = IMM_I;
                a_sel   = 1'b0;   // A = rs1
                b_sel   = 1'b1;   // B = imm
                alu_sel = ALU_ADD; // target = rs1 + imm
                wb_sel  = WB_PC4;  // rd = PC + 4
                pc_sel  = 1'b1;    // nhảy
            end

            // =====================
            // lui
            // =====================
            7'b0110111: begin
                reg_wen = 1'b1;
                imm_sel = IMM_U;
                a_sel   = 1'b0;
                b_sel   = 1'b1;
                alu_sel = ALU_ADD;
                wb_sel  = WB_ALU;
            end

            // =====================
            // auipc
            // =====================
            7'b0010111: begin
                reg_wen = 1'b1;
                imm_sel = IMM_U;
                a_sel   = 1'b1;   // A = PC
                b_sel   = 1'b1;   // B = imm
                alu_sel = ALU_ADD;
                wb_sel  = WB_ALU;
            end

        endcase
    end

endmodule


// Đây là bộ điều khiển
// Nhìn vào opcode, funct3, funct7 để quyết định:
// ALU làm gì
// lấy immediate kiểu nào
// có ghi thanh ghi không
// có ghi bộ nhớ không
// có nhảy hay không