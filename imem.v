module imem (
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:255];

    initial begin
        $readmemh("imem.hex", mem);
    end

    assign instr = mem[addr[31:2]];
endmodule

// Bộ nhớ lệnh là word-addressable theo addr[31:2]
// Vì lệnh RISC-V RV32I dài 4 byte nên bỏ 2 bit thấp
// imem.hex là file chứa mã máy