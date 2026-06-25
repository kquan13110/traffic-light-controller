module State (
    input        clk1,          
    input        rst,           
    input [1:0]  mode,          // 00:Normal, 01:Rush, 10:Blink, 11:Hold
    input        timeout_total, // Hết chu kỳ đèn (Đỏ/Vàng) 
    input        timeout_yellow,// Chuyển mốc đèn Vàng (từ Xanh) 

    output reg   LR1, LY1, LG1, // Đèn Làn 1 
    output reg   LR2, LY2, LG2, // Đèn Làn 2 
    output reg   pause_cnt      // Tín hiệu để dừng bộ đếm
);
    // --- Định nghĩa các trạng thái (Moore FSM) --- 
    localparam S0_G1_R2 = 2'b00; // Làn 1: Xanh, Làn 2: Đỏ
    localparam S1_Y1_R2 = 2'b01; // Làn 1: Vàng, Làn 2: Đỏ
    localparam S2_R1_G2 = 2'b10; // Làn 1: Đỏ,   Làn 2: Xanh
    localparam S3_R1_Y2 = 2'b11; // Làn 1: Đỏ,   Làn 2: Vàng

    reg [1:0] current_state, next_state;

    // --- 1. Sequential Block: Cập nhật trạng thái hiện tại --- 
    always @(posedge clk1 or posedge rst) begin
        if (rst) 
            current_state <= S0_G1_R2;
        else 
            current_state <= next_state;
    end

    // --- 2. Combinational Block: Logic chuyển trạng thái --- 
    always @(*) begin
        next_state = current_state; // Giữ nguyên trạng thái mặc định 
        pause_cnt  = 1'b0;          // Mặc định bộ đếm chạy bình thường

        if (mode == 2'b10) begin
            pause_cnt = 1'b1;       // Dừng đếm khi ở chế độ nháy đèn vàng
        end else begin
        case (current_state)
            S0_G1_R2: begin
                if (mode == 2'b11) begin
                    next_state = S0_G1_R2;  // Giữ nguyên trạng thái Xanh
                    pause_cnt  = 1'b1;      // Dừng bộ đếm thời gian
                end else if (timeout_yellow) begin
                    next_state = S1_Y1_R2;
                end
            end
            S1_Y1_R2: begin
                if (timeout_total) next_state = S2_R1_G2; 
            end
            S2_R1_G2: begin
                if (mode == 2'b11) begin
                    next_state = S2_R1_G2;  // Giữ nguyên trạng thái Xanh
                    pause_cnt  = 1'b1;      // Dừng bộ đếm thời gian
                end else if (timeout_yellow) begin
                    next_state = S3_R1_Y2;
                end
            end
            S3_R1_Y2: begin
                if (timeout_total) next_state = S0_G1_R2; 
            end

            default: next_state = S0_G1_R2;
        endcase
        end
    end

    // --- 3. Combinational Block: Logic điều khiển đèn ngõ ra ---
    always @(*) begin
        // Mặc định tắt tất cả đèn
        {LR1, LY1, LG1, LR2, LY2, LG2} = 6'b000_000; 

        if (mode == 2'b10) begin
            // Mode 2: Hai làn cùng nháy đèn Vàng (Cảnh báo)
            LY1 = clk1; 
            LY2 = clk1;
        end 
        else begin
            // Logic điều khiển đèn theo trạng thái FSM
            case (current_state)
                S0_G1_R2: begin LG1 = 1; LR2 = 1; end 
                S1_Y1_R2: begin LY1 = 1; LR2 = 1; end 
                S2_R1_G2: begin LR1 = 1; LG2 = 1; end 
                S3_R1_Y2: begin LR1 = 1; LY2 = 1; end 
            endcase
        end
    end

endmodule