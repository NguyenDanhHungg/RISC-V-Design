module top (
    input wire clk,   // clock hệ thống
    input wire rst    // reset hệ thống
);

    // =========================
    // Khai báo dây tín hiệu nội bộ
    // =========================
    wire [31:0] pc, pc_next, pc_plus4;
    wire [31:0] instr;
    wire [31:0] imm;
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] alu_a, alu_b, alu_y;
    wire [31:0] dmem_rdata;
    wire [31:0] wb_data;

    // Tín hiệu điều khiển
    wire        pc_sel;
    wire [2:0]  imm_sel;
    wire        reg_wen;
    wire        br_un;
    wire        br_eq;
    wire        br_lt;
    wire        b_sel;
    wire        a_sel;
    wire [3:0]  alu_sel;
    wire        mem_rw;
    wire [1:0]  wb_sel;

    // Tách địa chỉ thanh ghi từ instruction
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [4:0] rd  = instr[11:7];

    // Tính PC + 4
    assign pc_plus4 = pc + 32'd4;

    // =========================
    // Module PC
    // =========================
    pc_reg U_PC (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc)
    );

    // =========================
    // Bộ nhớ lệnh
    // =========================
    imem U_IMEM (
        .addr(pc),
        .instr(instr)
    );

    // =========================
    // Register file
    // =========================
    reg_file U_RF (
        .clk(clk),
        .we(reg_wen),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(wb_data),
        .rd1(rs1_data),
        .rd2(rs2_data)
    );

    // =========================
    // Immediate Generator
    // =========================
    imm_gen U_IMM (
        .instr(instr),
        .imm_sel(imm_sel),
        .imm(imm)
    );

    // =========================
    // Branch Comparator
    // =========================
    branch_comp U_BRC (
        .a(rs1_data),
        .b(rs2_data),
        .br_un(br_un),
        .br_eq(br_eq),
        .br_lt(br_lt)
    );

    // =========================
    // Control Unit
    // =========================
    control_unit U_CTRL (
        .instr(instr),
        .br_eq(br_eq),
        .br_lt(br_lt),
        .pc_sel(pc_sel),
        .imm_sel(imm_sel),
        .reg_wen(reg_wen),
        .br_un(br_un),
        .b_sel(b_sel),
        .a_sel(a_sel),
        .alu_sel(alu_sel),
        .mem_rw(mem_rw),
        .wb_sel(wb_sel)
    );

    // =========================
    // MUX chọn đầu vào cho ALU
    // =========================
    // Nếu a_sel = 1 thì ALU lấy PC
    // Nếu a_sel = 0 thì ALU lấy rs1_data
    assign alu_a = (a_sel) ? pc : rs1_data;

    // Nếu b_sel = 1 thì ALU lấy imm
    // Nếu b_sel = 0 thì ALU lấy rs2_data
    assign alu_b = (b_sel) ? imm : rs2_data;

    // =========================
    // ALU
    // =========================
    alu U_ALU (
        .a(alu_a),
        .b(alu_b),
        .alu_sel(alu_sel),
        .y(alu_y)
    );

    // =========================
    // Data memory
    // =========================
    dmem U_DMEM (
        .clk(clk),
        .we(mem_rw),
        .addr(alu_y),
        .wdata(rs2_data),
        .rdata(dmem_rdata)
    );

    // =========================
    // MUX write-back
    // Chọn dữ liệu ghi về thanh ghi
    // =========================
    assign wb_data = (wb_sel == 2'b00) ? dmem_rdata :
                     (wb_sel == 2'b01) ? alu_y :
                     (wb_sel == 2'b10) ? pc_plus4 :
                     32'b0;

    // =========================
    // Chọn PC kế tiếp
    // Nếu pc_sel = 0 -> PC + 4
    // Nếu pc_sel = 1 -> nhảy/branch đến alu_y
    // Riêng jalr: bit thấp nhất phải bằng 0
    // =========================
    assign pc_next = pc_sel ?
                     ((instr[6:0] == 7'b1100111) ? {alu_y[31:1], 1'b0} : alu_y)
                     : pc_plus4;

endmodule

// Đây là module top-level
// Nhiệm vụ:
// nối các module lại với nhau
// điều phối luồng dữ liệu
// cập nhật PC
// ghi dữ liệu về register file