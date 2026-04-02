module dmem (
    input  wire        clk,
    input  wire        we,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    output wire [31:0] rdata
);
    reg [31:0] mem [0:255];

    assign rdata = mem[addr[31:2]];

    always @(posedge clk) begin
        if (we)
            mem[addr[31:2]] <= wdata;
    end
endmodule

// we là write enable
// nếu we=1 thì ghi dữ liệu vào DMEM
// đọc dữ liệu kiểu combinational