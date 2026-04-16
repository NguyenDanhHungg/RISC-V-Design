`timescale 1ns/1ps

module imem_tb;
    reg  [31:0] addr;   // địa chỉ đọc lệnh
    wire [31:0] instr;  // lệnh đọc ra từ instruction memory

    // Gọi module instruction memory cần test
    imem dut (
        .addr(addr),
        .instr(instr)
    );

    initial begin
        $dumpfile("imem_tb.vcd");
        $dumpvars(0, imem_tb);

        // Đọc các lệnh đầu tiên trong imem.hex
        addr = 32'h00000000; #10;
        $display("addr=%h -> instr=%h", addr, instr);

        addr = 32'h00000004; #10;
        $display("addr=%h -> instr=%h", addr, instr);

        addr = 32'h00000008; #10;
        $display("addr=%h -> instr=%h", addr, instr);

        addr = 32'h0000000C; #10;
        $display("addr=%h -> instr=%h", addr, instr);

        addr = 32'h00000010; #10;
        $display("addr=%h -> instr=%h", addr, instr);

        $finish;
    end

endmodule