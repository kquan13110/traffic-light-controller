module auto_mode_ctrl #(
    // --- CẤU HÌNH CAO ĐIỂM SÁNG (RUSH 1: 07:00:00 -> 09:00:00) ---
    parameter [7:0] R1_START_H = 8'h07, 
    parameter [7:0] R1_START_M = 8'h00, 
    parameter [7:0] R1_START_S = 8'h00,
    
    parameter [7:0] R1_END_H   = 8'h09,
    parameter [7:0] R1_END_M   = 8'h00,
    parameter [7:0] R1_END_S   = 8'h00,

    // --- CẤU HÌNH CAO ĐIỂM CHIỀU (RUSH 2: 17:00:00 -> 19:00:00) ---
    parameter [7:0] R2_START_H = 8'h17,
    parameter [7:0] R2_START_M = 8'h00,
    parameter [7:0] R2_START_S = 8'h00,

    parameter [7:0] R2_END_H   = 8'h19,
    parameter [7:0] R2_END_M   = 8'h00,
    parameter [7:0] R2_END_S   = 8'h00
)(
    input [7:0] gio,    
    input [7:0] phut,   
    input [7:0] giay,   
    
    input       sw_blink,  
    input       sw_hold,  
    
    output reg [1:0] mode_sw // 00: Normal, 01: Rush, 10: Blink, 11: Hold
);

    // --- 1. Gom Tín hiệu thời gian thực ---
    wire [23:0] current_time = {gio, phut, giay};

    // --- 2. Tạo các mốc so sánh ---
    // Khung giờ Cao điểm 1 (Sáng)
    wire [23:0] rush1_start = {R1_START_H, R1_START_M, R1_START_S};
    wire [23:0] rush1_end   = {R1_END_H,   R1_END_M,   R1_END_S};
    
    // Khung giờ Cao điểm 2 (Chiều)
    wire [23:0] rush2_start = {R2_START_H, R2_START_M, R2_START_S};
    wire [23:0] rush2_end   = {R2_END_H,   R2_END_M,   R2_END_S};

    // --- 3. Logic So sánh & Quyết định Mode ---
    always @(*) begin
        // --- Ưu tiên 1: Chế độ chỉnh tay (Manual) ---
        if (sw_hold) begin
            mode_sw = 2'b11; // Hold
        end
        else if (sw_blink) begin
            mode_sw = 2'b10; // Blink
        end
        
        // --- Ưu tiên 2: Chế độ tự động (Auto) ---
        else begin
            // Kiểm tra: Nếu nằm trong Cao điểm Sáng HOẶC Cao điểm Chiều
            if ( (current_time >= rush1_start && current_time <= rush1_end) || 
                 (current_time >= rush2_start && current_time <= rush2_end) ) 
            begin
                mode_sw = 2'b01; // RUSH MODE (Thời gian đèn dài hơn)
            end
            else begin
                mode_sw = 2'b00; // NORMAL MODE (Thời gian mặc định)
            end
        end
    end

endmodule