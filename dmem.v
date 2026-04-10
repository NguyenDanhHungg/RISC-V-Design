module dmem (
    input  wire        clk,    // clock
    input  wire        we,     // write enable: cho phép ghi
    input  wire [31:0] addr,   // địa chỉ bộ nhớ dữ liệu
    input  wire [31:0] wdata,  // dữ liệu ghi vào bộ nhớ
    output wire [31:0] rdata   // dữ liệu đọc ra từ bộ nhớ
);

    // Bộ nhớ dữ liệu 256 word
    reg [31:0] mem [0:255];

    // Đọc dữ liệu kiểu combinational
    assign rdata = mem[addr[31:2]];

    // Ghi dữ liệu ở cạnh lên clock khi we = 1
    always @(posedge clk) begin
        if (we)
            mem[addr[31:2]] <= wdata;
    end

endmodule

// Dùng cho lw, sw
// we = 1 thì ghi dữ liệu vào DMEM
// we = 0 thì chỉ đọc
// we là write enable
// đọc dữ liệu kiểu combinational