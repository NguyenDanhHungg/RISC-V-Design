module branch_comp (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire        br_un,
    output wire        br_eq,
    output wire        br_lt
);
    assign br_eq = (a == b);
    assign br_lt = br_un ? (a < b) : ($signed(a) < $signed(b));
endmodule

// br_eq: hai thanh ghi có bằng nhau không
// br_lt: nhỏ hơn
// br_un = 1 thì so sánh unsigned
// br_un = 0 thì so sánh signed