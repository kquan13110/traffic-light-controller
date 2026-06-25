module top #(
    parameter [7:0] P_TIME_NORM = 8'h30, 
    parameter [7:0] P_TIME_RUSH = 8'h60, 
    parameter [7:0] P_TIME_YEL  = 8'h05,
    parameter       P_CLK_DIV   = 25000000
)(
    input clk0, Reset,
    
    input btn_up, btn_down,
    input [2:0] mode_time, // chọn chỉnh giờ / phút / giây (000: Giây, 001: Phút, 010: Giờ)
    
    input sw_blink, sw_hold,   

    output [6:0] HEX0, HEX1, HEX2, HEX3,
    output LR1, LG1, LY1, LR2, LG2, LY2,
    output [7:0] o_gio, o_phut, o_giay
);
    wire clk1, rst, w_timeout_t, w_timeout_y, w_pause_cnt;
    wire [7:0] w_Count;
    wire [1:0] w_mode_sw;
    
    //Đồng hồ số
    dong_ho_so U_CLOCK (
        .clk_1Hz(clk1), .rst_n(~rst),   
        .btn_up(btn_up), .btn_down(btn_down), .mode(mode_time),
        .giay(o_giay), .phut(o_phut), .gio(o_gio)
    );
    
    // Chọn mode 
    auto_mode_ctrl #(
        // Cấu hình Cao điểm Sáng (7h-9h)
        .R1_START_H(8'h07), .R1_START_M(8'h00), .R1_START_S(8'h00),
        .R1_END_H  (8'h09), .R1_END_M  (8'h00), .R1_END_S  (8'h00),
        
        // Cấu hình Cao điểm Chiều (17h-19h)
        .R2_START_H(8'h17), .R2_START_M(8'h00), .R2_START_S(8'h00),
        .R2_END_H  (8'h19), .R2_END_M  (8'h00), .R2_END_S  (8'h00)
    ) U_MODE_CTRL (
        .gio(o_gio),     
        .phut(o_phut),
        .giay(o_giay),
        .sw_blink(sw_blink),
        .sw_hold(sw_hold),
        .mode_sw(w_mode_sw)
    );

    // F1: Bộ chia tần
    Divide_freq #(.COUNT_VAL(P_CLK_DIV)) F1 (
        .clk0(clk0), 
        .Reset(Reset), 
        .clk1(clk1), 
        .rst(rst)
    );

    // F2: Bộ đếm (Logic chọn thời gian nạp chuyển vào đây)
    Downcounter #(
        .TIME_NORM(P_TIME_NORM), 
        .TIME_RUSH(P_TIME_RUSH), 
        .TIME_YEL(P_TIME_YEL)
    ) F2 (
        .clk1(clk1), .rst(rst), 
        .mode(w_mode_sw),  
        .pause_cnt(w_pause_cnt),
        .timeout_total(w_timeout_t), 
        .timeout_yellow(w_timeout_y),
        .Count(w_Count)
    );

    // F3: Máy trạng thái (Xử lý Mode_sw điều khiển đèn và ép nạp 5s)
    State F3 (
        .clk1(clk1), .rst(rst), 
        .mode(w_mode_sw),
        .timeout_total(w_timeout_t), 
        .timeout_yellow(w_timeout_y),
        .LR1(LR1), .LY1(LY1), .LG1(LG1), 
        .LR2(LR2), .LY2(LY2), .LG2(LG2),
        .pause_cnt(w_pause_cnt)
    );

    // F4: Hiển thị (Đã bỏ clk1, rst để hết Warning)
    Led7seg #(.YELLOW_OFFSET(P_TIME_YEL)) F4 (
        .Count(w_Count), 
        .LG1(LG1), .LG2(LG2),
        .hex0(HEX0), .hex1(HEX1), .hex2(HEX2), .hex3(HEX3)
    );

endmodule