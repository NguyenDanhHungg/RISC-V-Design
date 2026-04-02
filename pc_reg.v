module pc_reg (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 32'b0;
        else
            pc <= pc_next;
    end
endmodule

// pc là thanh ghi Program Counter
// Mỗi cạnh lên clock, PC nhận giá trị mới pc_next
// Khi reset thì PC về 0