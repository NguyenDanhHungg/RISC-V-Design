module tb_top;
    reg clk;   // clock mô phỏng
    reg rst;   // reset mô phỏng

    // Gọi module top-level cần test
    top dut (
        .clk(clk),
        .rst(rst)
    );

    // Tạo clock chu kỳ 10 time unit
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset trong 20 time unit đầu
    initial begin
        rst = 1;
        #20;
        rst = 0;

        // Cho mô phỏng chạy thêm 300 time unit rồi dừng
        #300;
        $finish;
    end

    // Ghi sóng ra file wave.vcd để mở bằng GTKWave
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top);
    end

endmodule

//testbench cho top-level module, tạo clock và reset, chạy mô phỏng trong 300 time unit, và ghi lại sóng vào file wave.vcd để xem sau
//clock chu kỳ 10 đơn vị thời gian
//reset 20 đơn vị đầu
//xuất waveform để xem bằng GTKWave 