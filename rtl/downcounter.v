module Downcounter #(
    parameter [7:0] TIME_NORM = 8'h30,     // Thời gian chế độ Normal
    parameter [7:0] TIME_RUSH = 8'h60,     // Thời gian chế độ Rush
    parameter [7:0] TIME_YEL  = 8'h05      // Thời gian đèn Vàng
)(
    input        clk1, rst,
    input [1:0]  mode,
    input        pause_cnt,
    output       timeout_total,       // Tín hiệu báo hết thời gian tổng 
    output       timeout_yellow,      // Tín hiệu báo hết thời gian đèn Vàng
    output [7:0] Count 
);
    reg [7:0] count_reg;
    wire [7:0] next_count;

    // Chọn thời gian tổng dựa trên mode
    wire [7:0] current_total = (mode == 2'b01) ? TIME_RUSH : TIME_NORM; 

    bcd_minus1 sub_inst (.BCD_in(count_reg), .BCD_out(next_count));  // Sử dụng module trừ 1 BCD

    always @(posedge clk1 or posedge rst) begin
        if (rst) 
            count_reg <= current_total;
        else if (pause_cnt) 
            count_reg <= count_reg; // Giữ nguyên giá trị (Dừng đếm)
        else if (count_reg == 8'h00) 
            count_reg <= current_total; // Nạp lại thời gian tổng khi hết
        else 
            count_reg <= next_count; 
    end

    assign Count = count_reg; 
    assign timeout_total  = (count_reg == 8'h00);
    assign timeout_yellow = (count_reg == TIME_YEL);
endmodule