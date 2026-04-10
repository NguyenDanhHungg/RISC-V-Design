module imem (
    input  wire [31:0] addr,   // địa chỉ đọc lệnh, thường là PC
    output wire [31:0] instr   // lệnh 32-bit đọc ra
);

    // Bộ nhớ lệnh gồm 256 word, mỗi word 32 bit
    reg [31:0] mem [0:255];

    initial begin
        // Đọc nội dung chương trình từ file imem.hex
        $readmemh("imem.hex", mem);
    end

    // Vì mỗi lệnh dài 4 byte nên dùng addr[31:2]
    assign instr = mem[addr[31:2]];

endmodule

// Bộ nhớ lệnh là word-addressable theo addr[31:2]
// Vì lệnh RISC-V RV32I dài 4 byte nên bỏ 2 bit thấp
// imem.hex là file chứa mã máy
// CPU dùng PC để lấy lệnh