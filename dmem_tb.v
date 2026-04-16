`timescale 1ns/1ps

module dmem_tb;
    reg         clk;    // clock mô phỏng
    reg         we;     // write enable
    reg  [31:0] addr;   // địa chỉ truy cập data memory
    reg  [31:0] wdata;  // dữ liệu ghi vào memory
    wire [31:0] rdata;  // dữ liệu đọc ra từ memory

    // Gọi module data memory cần test
    dmem dut (
        .clk(clk),
        .we(we),
        .addr(addr),
        .wdata(wdata),
        .rdata(rdata)
    );

    // Tạo clock chu kỳ 10 time unit
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("dmem_tb.vcd");
        $dumpvars(0, dmem_tb);

        // Khởi tạo ban đầu
        we    = 0;
        addr  = 32'h00000000;
        wdata = 32'd0;

        // Ghi 25 vào địa chỉ 0
        #10;
        we    = 1;
        addr  = 32'h00000000;
        wdata = 32'd25;

        // Đọc lại địa chỉ 0
        #10;
        we   = 0;
        addr = 32'h00000000;
        #10;
        $display("addr=%h -> rdata=%d", addr, rdata);

        // Ghi 99 vào địa chỉ 4
        we    = 1;
        addr  = 32'h00000004;
        wdata = 32'd99;

        // Đọc lại địa chỉ 4
        #10;
        we   = 0;
        addr = 32'h00000004;
        #10;
        $display("addr=%h -> rdata=%d", addr, rdata);

        $finish;
    end

endmodule