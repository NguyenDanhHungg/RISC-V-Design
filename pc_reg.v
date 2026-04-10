module pc_reg (
    input  wire        clk,      // clock hệ thống
    input  wire        rst,      // reset
    input  wire [31:0] pc_next,  // giá trị PC kế tiếp
    output reg  [31:0] pc        // giá trị PC hiện tại
);

    // PC là một thanh ghi, cập nhật theo cạnh lên của clock
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 32'b0;     // khi reset, PC quay về địa chỉ 0
        else
            pc <= pc_next;   // nếu không reset, nhận giá trị PC mới
    end

endmodule
// pc là thanh ghi Program Counter
// Mỗi cạnh lên clock, PC nhận giá trị mới pc_next
// Khi reset thì PC về 0