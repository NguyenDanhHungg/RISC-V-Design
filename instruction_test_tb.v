`timescale 1ns/1ps

module instruction_test_tb;

    // Đầu vào test 
    reg  [31:0] instr;      // instruction đang test
    reg         br_eq;      // cờ branch equal
    reg         br_lt;      // cờ branch less than

    reg  [31:0] rs1_data;   // dữ liệu giả lập từ rs1
    reg  [31:0] rs2_data;   // dữ liệu giả lập từ rs2
    reg  [31:0] pc;         // PC giả lập

    // Đầu ra từ control unit 
    wire        pc_sel;
    wire [2:0]  imm_sel;
    wire        reg_wen;
    wire        br_un;
    wire        b_sel;
    wire        a_sel;
    wire [3:0]  alu_sel;
    wire        mem_rw;
    wire [1:0]  wb_sel;

    // Đầu ra từ imm_gen 
    wire [31:0] imm;

    // Tách trường thanh ghi 
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [4:0] rd  = instr[11:7];

    // Đầu vào/ra ALU 
    wire [31:0] alu_a;
    wire [31:0] alu_b;
    wire [31:0] alu_y;

    // Dữ liệu write-back mô phỏng 
    reg  [31:0] mem_data;
    wire [31:0] wb_data;

    // DUTs 
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

    imm_gen U_IMM (
        .instr(instr),
        .imm_sel(imm_sel),
        .imm(imm)
    );

    // a_sel = 0 -> ALU A = rs1_data
    // a_sel = 1 -> ALU A = pc
    assign alu_a = (a_sel) ? pc : rs1_data;

    // b_sel = 0 -> ALU B = rs2_data
    // b_sel = 1 -> ALU B = imm
    assign alu_b = (b_sel) ? imm : rs2_data;

    alu U_ALU (
        .a(alu_a),
        .b(alu_b),
        .alu_sel(alu_sel),
        .y(alu_y)
    );

    // wb_sel:
    // 00 = memory
    // 01 = ALU
    // 10 = PC + 4
    assign wb_data = (wb_sel == 2'b00) ? mem_data :
                     (wb_sel == 2'b01) ? alu_y    :
                     (wb_sel == 2'b10) ? (pc + 32'd4) :
                     32'b0;

    task show_case;
        input [255:0] name;
        begin
            $display("\n==============================");
            $display("TEST: %0s", name);
            $display("==============================");
        end
    endtask

    // ===== Task in trạng thái chung =====
    task show_signals;
        begin
            $display("instr    = %h", instr);
            $display("rs1=%0d rs2=%0d rd=%0d", rs1, rs2, rd);
            $display("pc_sel   = %b", pc_sel);
            $display("imm_sel  = %b", imm_sel);
            $display("imm      = %0d (0x%h)", $signed(imm), imm);
            $display("reg_wen  = %b", reg_wen);
            $display("br_un    = %b", br_un);
            $display("a_sel    = %b", a_sel);
            $display("b_sel    = %b", b_sel);
            $display("alu_sel  = %b", alu_sel);
            $display("mem_rw   = %b", mem_rw);
            $display("wb_sel   = %b", wb_sel);
            $display("alu_a    = %0d", $signed(alu_a));
            $display("alu_b    = %0d", $signed(alu_b));
            $display("alu_y    = %0d", $signed(alu_y));
            $display("wb_data  = %0d", $signed(wb_data));
        end
    endtask

    initial begin
        $dumpfile("instruction_test_tb.vcd");
        $dumpvars(0, instruction_test_tb);

        // Giá trị mặc định
        instr    = 32'b0;
        br_eq    = 1'b0;
        br_lt    = 1'b0;
        rs1_data = 32'b0;
        rs2_data = 32'b0;
        pc       = 32'd100;   // chọn PC mẫu
        mem_data = 32'd123;   // dữ liệu memory mẫu cho lệnh lw

        // ADDI: addi x1, x0, 5
        show_case("ADDI x1, x0, 5");
        instr    = 32'h00500093;
        rs1_data = 32'd0;
        rs2_data = 32'd0;
        br_eq    = 1'b0;
        br_lt    = 1'b0;
        #10;
        show_signals;
        if (imm == 32'd5 && alu_y == 32'd5 && reg_wen == 1'b1 && wb_sel == 2'b01)
            $display("PASS");
        else
            $display("FAIL");

        // ADD: add x3, x1, x2
        show_case("ADD x3, x1, x2");
        instr    = 32'h002081B3;
        rs1_data = 32'd10;
        rs2_data = 32'd7;
        #10;
        show_signals;
        if (alu_y == 32'd17 && reg_wen == 1'b1 && alu_sel == 4'b0000)
            $display("PASS");
        else
            $display("FAIL");

        // SUB: sub x4, x2, x1
        show_case("SUB x4, x2, x1");
        instr    = 32'h40110233;
        rs1_data = 32'd9;
        rs2_data = 32'd4;
        #10;
        show_signals;
        if (alu_y == 32'd5 && reg_wen == 1'b1 && alu_sel == 4'b0001)
            $display("PASS");
        else
            $display("FAIL");

        // AND: and x5, x1, x2
        show_case("AND x5, x1, x2");
        instr    = 32'h0020F2B3;
        rs1_data = 32'h0000000F;
        rs2_data = 32'h0000000A;
        #10;
        show_signals;
        if (alu_y == 32'h0000000A && alu_sel == 4'b0010)
            $display("PASS");
        else
            $display("FAIL");

        // LW: lw x2, 0(x1)
        show_case("LW x2, 0(x1)");
        instr    = 32'h0000A103;
        rs1_data = 32'd20;
        mem_data = 32'd55;
        #10;
        show_signals;
        if (imm == 32'd0 && alu_y == 32'd20 && reg_wen == 1'b1 && wb_sel == 2'b00 && mem_rw == 1'b0)
            $display("PASS");
        else
            $display("FAIL");

        // SW: sw x2, 4(x1)
        show_case("SW x2, 4(x1)");
        instr    = 32'h0020A223;
        rs1_data = 32'd20;
        rs2_data = 32'd99;
        #10;
        show_signals;
        if (imm == 32'd4 && alu_y == 32'd24 && reg_wen == 1'b0 && mem_rw == 1'b1)
            $display("PASS");
        else
            $display("FAIL");


        // BEQ false: beq x1, x2, 8
        show_case("BEQ false");
        instr    = 32'h00208463;
        rs1_data = 32'd5;
        rs2_data = 32'd7;
        br_eq    = 1'b0;
        br_lt    = 1'b1;
        #10;
        show_signals;
        if (pc_sel == 1'b0 && imm == 32'd8)
            $display("PASS");
        else
            $display("FAIL");

        // 8) BEQ true
        show_case("BEQ true");
        instr    = 32'h00208463;
        br_eq    = 1'b1;
        br_lt    = 1'b0;
        #10;
        show_signals;
        if (pc_sel == 1'b1 && alu_y == pc + 32'd8)
            $display("PASS");
        else
            $display("FAIL");

        // JAL: jal x0, 16
        show_case("JAL x0, 16");
        instr    = 32'h0100006F;
        br_eq    = 1'b0;
        br_lt    = 1'b0;
        pc       = 32'd100;
        #10;
        show_signals;
        if (pc_sel == 1'b1 && imm == 32'd16 && wb_sel == 2'b10 && wb_data == 32'd104)
            $display("PASS");
        else
            $display("FAIL");

        // JALR: jalr x0, 0(x1)
        show_case("JALR x0, 0(x1)");
        instr    = 32'h00008067;
        rs1_data = 32'd200;
        pc       = 32'd100;
        #10;
        show_signals;
        if (pc_sel == 1'b1 && imm == 32'd0 && alu_y == 32'd200 && wb_sel == 2'b10 && wb_data == 32'd104)
            $display("PASS");
        else
            $display("FAIL");

        // LUI: lui x5, 0x12345
        show_case("LUI x5, 0x12345");
        instr    = 32'h123452B7;
        rs1_data = 32'd0;
        #10;
        show_signals;
        if (imm == 32'h12345000 && reg_wen == 1'b1)
            $display("PASS");
        else
            $display("FAIL");

        // AUIPC: auipc x5, 0x12345
        show_case("AUIPC x5, 0x12345");
        instr    = 32'h12345297;
        pc       = 32'd100;
        #10;
        show_signals;
        if (imm == 32'h12345000 && alu_y == (32'h12345000 + 32'd100))
            $display("PASS");
        else
            $display("FAIL");

        $display("\n=== KET THUC TEST TONG HOP CAC LOAI LENH ===");
        $finish;
    end

endmodule