/*
 * Chức năng: Cung cấp các phép tính cộng/trừ 1 cho số BCD 8-bit (00-99).
 */
// --- Module Cộng 1 BCD ---
module bcd_plus1(
    input  [7:0] BCD_in,
    output reg [7:0] BCD_out
);
    always @(*) begin
        if (BCD_in == 8'h99) // Nếu là 99, quay vòng về 00
            BCD_out = 8'h00;
        else if (BCD_in[3:0] == 4'h9) begin // Nếu hàng đơn vị là 9
            BCD_out[7:4] = BCD_in[7:4] + 1'b1; // Tăng hàng chục
            BCD_out[3:0] = 4'h0;               // Hàng đơn vị về 0
        end
        else
            BCD_out = BCD_in + 8'h01; // Cộng thông thường
    end
endmodule

// --- Module Trừ 1 BCD ---
module bcd_minus1(
    input  [7:0] BCD_in,
    output reg [7:0] BCD_out
);
    always @(*) begin
        if (BCD_in == 8'h00) // Nếu là 00, quay vòng về 99
            BCD_out = 8'h99;
        else if (BCD_in[3:0] == 4'h0) begin // Nếu hàng đơn vị là 0
            BCD_out[7:4] = BCD_in[7:4] - 1'b1; // Giảm hàng chục
            BCD_out[3:0] = 4'h9;               // Hàng đơn vị thành 9
        end
        else
            BCD_out = BCD_in - 8'h01; // Trừ thông thường
    end
endmodule