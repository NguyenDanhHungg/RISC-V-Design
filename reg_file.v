module reg_file (
    input  wire        clk,
    input  wire        we,
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  rd,
    input  wire [31:0] wd,
    output wire [31:0] rd1,
    output wire [31:0] rd2
);
    reg [31:0] regs [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end

    assign rd1 = (rs1 == 5'd0) ? 32'b0 : regs[rs1];
    assign rd2 = (rs2 == 5'd0) ? 32'b0 : regs[rs2];

    always @(posedge clk) begin
        if (we && rd != 5'd0)
            regs[rd] <= wd;
    end
endmodule

// Có 32 thanh ghi
// x0 luôn bằng 0 nên:
// đọc x0 trả về 0
// không cho ghi vào rd = 0