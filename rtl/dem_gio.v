module dem_gio
(
	input wire clk_1Hz,
	input wire rst_n,
	input btn_up,
    input btn_down,
    input [2:0] mode,
	input [7:0] giay,
	input [7:0] phut,
	output reg [7:0] gio
);

wire [7:0] gio_plus1;
bcd_plus1 bcd_inst(
    .BCD_in(gio),
    .BCD_out(gio_plus1)
);
wire [7:0] gio_minus1;
bcd_minus1 bcd_inst_n(
    .BCD_in(gio),
    .BCD_out(gio_minus1)
);

always @(posedge clk_1Hz or negedge rst_n)
begin
	if (~rst_n) gio <= 8'b00000000;
	else
	
		if (mode == 3'b010)
		begin
			if (~btn_up)
				if (gio == 8'b0010_0011) gio <= 8'b0000_0000;
				else gio <= gio_plus1;
			else if (~btn_down)
				if (gio == 8'b0000_0000) gio <= 8'b0010_0011;
				else gio <= gio_minus1;
		end
		
		else
	
		if (giay == 8'b01011001 && phut == 8'b01011001)
			if (gio == 8'b00100011) gio <= 8'b00000000;
			else gio <= gio_plus1;
		else gio <= gio;
end

endmodule

// module dem_gio(
//     input wire clk,
//     input wire rst_n,
//     input wire switch,     // switch = 0: 24h, switch = 1: 12h
//     input [7:0] giay,
//     input [7:0] phut,
//     output reg [7:0] gio
// );

// wire [7:0] gio_plus1;
// bcd_plus1 bcd_inst(
//     .BCD_in(gio),
//     .BCD_out(gio_plus1)
// );

// always @(posedge clk or negedge rst_n)
// begin
//     if (~rst_n) begin 
//         gio <= 8'b0000_0001;  // Giờ ban đầu là 00
//     end
//     else if (giay == 8'b01011001 && phut == 8'b01011001) begin  // 59 giây, 59 phút
//         if (switch == 0) begin // 24h mode
//             if (gio == 8'b00100011) begin  // 23h (23:59:59)
//                 gio <= 8'b00000000;  // Reset về 00h
//             end 
//             else begin
//                 gio <= gio_plus1;  // Tăng giờ bình thường
//             end
//         end
//         else if (switch == 1) begin // 12h mode (AM/PM)
//             // if (gio >= 8'b00010011) begin // Giờ >= 13 (PM)
//             //     gio <= gio - 8'b00001100;  // Trừ đi 12 giờ để chuyển sang chế độ 12h (AM/PM)
//             // end
//             // else if (gio == 8'b00000000) begin // Giờ = 00 AM
//             //     gio <= 8'b00010010;  // Đặt giờ là 12 AM
//             // end
//             if (gio == 8'b00010010) begin  // 23h (23:59:59)
//                 gio <= 8'b0000_0001;  // Reset về 00h
//             end
//             else if (gio == 8'b0000_0000) begin
//                 gio <= 8'b0001_0010;
//             end
//             else begin
//                 gio <= gio_plus1;  // Tăng giờ bình thường
//             end
//         end
//     end
//     else begin
//         gio <= gio;  // Giữ nguyên giá trị giờ nếu không có điều kiện thay đổi
//     end
// end

// endmodule
