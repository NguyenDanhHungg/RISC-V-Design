module alu (
    input  wire [31:0] a,        // toán hạng A
    input  wire [31:0] b,        // toán hạng B
    input  wire [3:0]  alu_sel,  // tín hiệu chọn phép toán
    output reg  [31:0] y         // kết quả ALU
);

    always @(*) begin
        case (alu_sel)
            4'b0000: y = a + b;                              // ADD
            4'b0001: y = a - b;                              // SUB
            4'b0010: y = a & b;                              // AND
            4'b0011: y = a | b;                              // OR
            4'b0100: y = a ^ b;                              // XOR
            4'b0101: y = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT
            4'b0110: y = (a < b) ? 32'd1 : 32'd0;            // SLTU
            4'b0111: y = a << b[4:0];                        // SLL
            4'b1000: y = a >> b[4:0];                        // SRL
            4'b1001: y = $signed(a) >>> b[4:0];              // SRA
            default: y = 32'b0;
        endcase
    end

endmodule

// b[4:0] vì shift amount chỉ cần 5 bit trong RV32
// >>> là arithmetic shift right