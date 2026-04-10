module branch_comp (
    input  wire [31:0] a,      // toán hạng 1
    input  wire [31:0] b,      // toán hạng 2
    input  wire        br_un,  // 1: so sánh unsigned, 0: so sánh signed
    output wire        br_eq,  // bằng nhau hay không
    output wire        br_lt   // a < b hay không
);

    // So sánh bằng nhau
    assign br_eq = (a == b);

    // So sánh nhỏ hơn
    // Nếu br_un = 1 thì so sánh unsigned
    // Nếu br_un = 0 thì so sánh signed
    assign br_lt = br_un ? (a < b) : ($signed(a) < $signed(b));

endmodule

// br_eq: hai thanh ghi có bằng nhau không
// br_lt: nhỏ hơn
// br_un = 1 thì so sánh unsigned
// br_un = 0 thì so sánh signed