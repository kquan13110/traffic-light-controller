module Led7seg #(
    parameter [7:0] YELLOW_OFFSET = 8'h05 // Thời gian đèn Vàng 
)(
    // input        clk1,          // Clock hệ thống
    // input        rst,           // Tín hiệu Reset 
    input [7:0]  Count,         // Giá trị đếm gốc dạng BCD 
    
    input        LG1,           // Đèn Xanh Làn 1 
    input        LG2,           // Đèn Xanh Làn 2

    // Output ra các LED 7 đoạn (Anode chung) 
    output [6:0] hex0, // Hàng đơn vị - Làn 1
    output [6:0] hex1, // Hàng chục   - Làn 1
    output [6:0] hex2, // Hàng đơn vị - Làn 2
    output [6:0] hex3  // Hàng chục   - Làn 2
);

    // Biến lưu giá trị BCD hiển thị 
    reg [7:0] val_lane1;
    reg [7:0] val_lane2;

    // --- Logic Tính Toán Giá Trị Hiển Thị BCD ---
    always @(*) begin
        // --- LÀN 1 ---
        if (LG1) begin
            // Nếu đang đèn Xanh: Hiển thị (Count - YELLOW_OFFSET) 
            if (Count > YELLOW_OFFSET) begin
                // Trừ BCD cho h5: Nếu hàng đơn vị < 5 thì mượn 1 từ hàng chục
                if (Count[3:0] >= YELLOW_OFFSET[3:0])
                    val_lane1 = {Count[7:4], Count[3:0] - YELLOW_OFFSET[3:0]};
                else
                    val_lane1 = {Count[7:4] - 4'h1, Count[3:0] + 4'd10 - YELLOW_OFFSET[3:0]}; 
            end
            else
                val_lane1 = 8'h00; // Tránh lỗi số âm 
        end
        else begin
            val_lane1 = Count; // Vàng hoặc Đỏ: Hiển thị đúng Count 
        end

        // --- LÀN 2 ---
        if (LG2) begin
            if (Count > YELLOW_OFFSET) begin
                if (Count[3:0] >= YELLOW_OFFSET[3:0])
                    val_lane2 = {Count[7:4], Count[3:0] - YELLOW_OFFSET[3:0]};
                else
                    val_lane2 = {Count[7:4] - 4'h1, Count[3:0] + 4'd10 - YELLOW_OFFSET[3:0]};
            end
            else
                val_lane2 = 8'h00; 
        end
        else begin
            val_lane2 = Count; 
        end
    end

    // --- Tách số Hàng chục và Hàng đơn vị  ---
    wire [3:0] tens1 = val_lane1[7:4];
    wire [3:0] unit1 = val_lane1[3:0];
    wire [3:0] tens2 = val_lane2[7:4];
    wire [3:0] unit2 = val_lane2[3:0];

    // --- Giải mã LED 7 đoạn (Anode chung: 0:sáng, 1:tắt) ---
    function [6:0] segment_decoder;
        input [3:0] digit; 
        begin
            case (digit)
                //                 gfedcba
                4'h0: segment_decoder = 7'b1000000; //40
                4'h1: segment_decoder = 7'b1111001; //79
                4'h2: segment_decoder = 7'b0100100; //24
                4'h3: segment_decoder = 7'b0110000; //30
                4'h4: segment_decoder = 7'b0011001; //19
                4'h5: segment_decoder = 7'b0010010; //12
                4'h6: segment_decoder = 7'b0000010; //02
                4'h7: segment_decoder = 7'b1111000; //78
                4'h8: segment_decoder = 7'b0000000; //00
                4'h9: segment_decoder = 7'b0010000; //10
                default: segment_decoder = 7'b1111111; 
            endcase
        end
    endfunction

    // --- Gán đầu ra ---
    assign hex0 = segment_decoder(unit1); 
    assign hex1 = segment_decoder(tens1); 
    assign hex2 = segment_decoder(unit2); 
    assign hex3 = segment_decoder(tens2);

endmodule