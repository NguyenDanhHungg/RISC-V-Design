module tb_top;
    reg clk;
    reg rst;

    top dut (
        .clk(clk),
        .rst(rst)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        #20;
        rst = 0;

        #300;
        $finish;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top);
    end
endmodule

//testbench cho top-level module, tạo clock và reset, chạy mô phỏng trong 300 time unit, và ghi lại sóng vào file wave.vcd để xem sau
//clock chu kỳ 10 đơn vị thời gian
//reset 20 đơn vị đầu
//xuất waveform để xem bằng GTKWave hoặc simulator khác