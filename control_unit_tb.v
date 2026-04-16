`timescale 1ns/1ps

module control_unit_tb;
    reg  [31:0] instr;   // instruction đầu vào
    reg         br_eq;   // cờ so sánh bằng
    reg         br_lt;   // cờ so sánh nhỏ hơn

    wire        pc_sel;
    wire [2:0]  imm_sel;
    wire        reg_wen;
    wire        br_un;
    wire        b_sel;
    wire        a_sel;
    wire [3:0]  alu_sel;
    wire        mem_rw;
    wire [1:0]  wb_sel;

    // Gọi module control unit cần test
    control_unit dut (
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

    initial begin
        $dumpfile("control_unit_tb.vcd");
        $dumpvars(0, control_unit_tb);

        // Mặc định
        br_eq = 0;
        br_lt = 0;

        // R-type add
        instr = 32'h002081B3;
        #10;
        $display("ADD  -> pc_sel=%b imm_sel=%b reg_wen=%b br_un=%b b_sel=%b a_sel=%b alu_sel=%b mem_rw=%b wb_sel=%b",
                 pc_sel, imm_sel, reg_wen, br_un, b_sel, a_sel, alu_sel, mem_rw, wb_sel);

        // R-type sub
        instr = 32'h402081B3;
        #10;
        $display("SUB  -> pc_sel=%b imm_sel=%b reg_wen=%b br_un=%b b_sel=%b a_sel=%b alu_sel=%b mem_rw=%b wb_sel=%b",
                 pc_sel, imm_sel, reg_wen, br_un, b_sel, a_sel, alu_sel, mem_rw, wb_sel);

        // addi
        instr = 32'h00500093;
        #10;
        $display("ADDI -> pc_sel=%b imm_sel=%b reg_wen=%b br_un=%b b_sel=%b a_sel=%b alu_sel=%b mem_rw=%b wb_sel=%b",
                 pc_sel, imm_sel, reg_wen, br_un, b_sel, a_sel, alu_sel, mem_rw, wb_sel);

        // lw
        instr = 32'h0000A103;
        #10;
        $display("LW   -> pc_sel=%b imm_sel=%b reg_wen=%b br_un=%b b_sel=%b a_sel=%b alu_sel=%b mem_rw=%b wb_sel=%b",
                 pc_sel, imm_sel, reg_wen, br_un, b_sel, a_sel, alu_sel, mem_rw, wb_sel);

        // sw
        instr = 32'h0020A223;
        #10;
        $display("SW   -> pc_sel=%b imm_sel=%b reg_wen=%b br_un=%b b_sel=%b a_sel=%b alu_sel=%b mem_rw=%b wb_sel=%b",
                 pc_sel, imm_sel, reg_wen, br_un, b_sel, a_sel, alu_sel, mem_rw, wb_sel);

        // beq khi điều kiện sai
        instr = 32'h00208463;
        br_eq = 0;
        br_lt = 0;
        #10;
        $display("BEQ false -> pc_sel=%b imm_sel=%b reg_wen=%b", pc_sel, imm_sel, reg_wen);

        // beq khi điều kiện đúng
        br_eq = 1;
        #10;
        $display("BEQ true  -> pc_sel=%b imm_sel=%b reg_wen=%b", pc_sel, imm_sel, reg_wen);

        // jal
        instr = 32'h0100006F;
        br_eq = 0;
        br_lt = 0;
        #10;
        $display("JAL  -> pc_sel=%b imm_sel=%b reg_wen=%b wb_sel=%b",
                 pc_sel, imm_sel, reg_wen, wb_sel);

        // jalr
        instr = 32'h00008067;
        #10;
        $display("JALR -> pc_sel=%b imm_sel=%b reg_wen=%b wb_sel=%b",
                 pc_sel, imm_sel, reg_wen, wb_sel);

        $finish;
    end

endmodule