module reg_file (
    input  wire        clk,   // clock
    input  wire        we,    // write enable
    input  wire [4:0]  rs1,   // địa chỉ thanh ghi nguồn 1
    input  wire [4:0]  rs2,   // địa chỉ thanh ghi nguồn 2
    input  wire [4:0]  rd,    // địa chỉ thanh ghi đích
    input  wire [31:0] wd,    // dữ liệu ghi vào rd
    output wire [31:0] rd1,   // dữ liệu đọc từ rs1
    output wire [31:0] rd2    // dữ liệu đọc từ rs2
);

    // 32 thanh ghi, mỗi thanh ghi 32 bit
    reg [31:0] regs [0:31];
    integer i;

    // Khởi tạo tất cả thanh ghi về 0 khi bắt đầu mô phỏng
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end

    // x0 luôn bằng 0 nên nếu đọc rs1/rs2 = 0 thì trả về 0
    assign rd1 = (rs1 == 5'd0) ? 32'b0 : regs[rs1];
    assign rd2 = (rs2 == 5'd0) ? 32'b0 : regs[rs2];

    // Ghi dữ liệu vào rd ở cạnh lên clock nếu we = 1
    // Không cho phép ghi vào x0
    always @(posedge clk) begin
        if (we && rd != 5'd0)
            regs[rd] <= wd;
    end

endmodule

// Có 32 thanh ghi
// x0 luôn bằng 0 nên:
// đọc x0 trả về 0
// không cho ghi vào rd = 0