`timescale 1ns/1ps

module imm_gen_tb;
    reg  [31:0] instr;    // instruction đầu vào
    reg  [2:0]  imm_sel;  // chọn kiểu immediate
    wire [31:0] imm;      // immediate mở rộng ra 32 bit

    // Gọi module immediate generator cần test
    imm_gen dut (
        .instr(instr),
        .imm_sel(imm_sel),
        .imm(imm)
    );

    initial begin
        $dumpfile("imm_gen_tb.vcd");
        $dumpvars(0, imm_gen_tb);

        // I-type: addi x1, x0, 5
        instr   = 32'h00500093;
        imm_sel = 3'b000;
        #10;
        $display("I-type : instr=%h -> imm=%0d", instr, $signed(imm));

        // S-type: sw x2, 4(x1)
        instr   = 32'h0020A223;
        imm_sel = 3'b001;
        #10;
        $display("S-type : instr=%h -> imm=%0d", instr, $signed(imm));

        // B-type: beq x1, x2, 8
        instr   = 32'h00208463;
        imm_sel = 3'b010;
        #10;
        $display("B-type : instr=%h -> imm=%0d", instr, $signed(imm));

        // U-type: lui x5, 0x12345
        instr   = 32'h123452B7;
        imm_sel = 3'b011;
        #10;
        $display("U-type : instr=%h -> imm=%0d (0x%h)", instr, $signed(imm), imm);

        // J-type: jal x0, 16
        instr   = 32'h0100006F;
        imm_sel = 3'b100;
        #10;
        $display("J-type : instr=%h -> imm=%0d", instr, $signed(imm));

        $finish;
    end

endmodule