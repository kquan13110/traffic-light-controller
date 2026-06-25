`timescale 1ns / 1ps

module tb_top_full;

    // --- 1. Khai báo tín hiệu ---
    reg clk0;
    reg Reset;
    reg btn_up, btn_down;
    reg [2:0] mode_time;
    reg sw_blink, sw_hold;

    wire [6:0] HEX0, HEX1, HEX2, HEX3;
    wire LR1, LG1, LY1, LR2, LG2, LY2;
    wire [7:0] o_gio, o_phut, o_giay;

    // --- 2. Cấu hình tham số (Giả lập) ---
    // Chỉnh Clock chia tần = 2 để giây chạy nhanh
    localparam TEST_CLK_DIV = 2;
    
    // Khởi tạo Module Top
    top #(
        .P_TIME_NORM(8'h10), // Xanh Normal: 10s
        .P_TIME_RUSH(8'h30), // Xanh Rush: 30s
        .P_TIME_YEL (8'h03), // Vàng: 3s
        .P_CLK_DIV  (TEST_CLK_DIV) 
    ) uut (
        .clk0(clk0), .Reset(Reset), 
        .btn_up(btn_up), .btn_down(btn_down), .mode_time(mode_time), 
        .sw_blink(sw_blink), .sw_hold(sw_hold), 
        .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), 
        .LR1(LR1), .LG1(LG1), .LY1(LY1), .LR2(LR2), .LG2(LG2), .LY2(LY2),
        .o_gio(o_gio), .o_phut(o_phut), .o_giay(o_giay)
    );

    // --- 3. Tạo Clock 50MHz ---
    always #10 clk0 = ~clk0;

    // --- 4. Task "Du hành thời gian" (Force Time) ---
    task jump_time;
        input [7:0] h, m, s;
        begin
            force uut.U_CLOCK.u_dem_gio.gio   = h;
            force uut.U_CLOCK.u_dem_phut.phut = m;
            force uut.U_CLOCK.u_dem_giay.giay = s;
            #20; 
            release uut.U_CLOCK.u_dem_gio.gio;
            release uut.U_CLOCK.u_dem_phut.phut;
            release uut.U_CLOCK.u_dem_giay.giay;
        end
    endtask

    // --- 5. Main Test Process ---
    initial begin
        // Khởi tạo
        clk0 = 0; Reset = 1; 
        btn_up = 1; btn_down = 1; mode_time = 0;
        sw_blink = 0; sw_hold = 0;

        $display("-------------------------------------------------------------");
        $display("   TESTBENCH KIEM TRA TOAN DIEN (AUTO + MANUAL)");
        $display("   Mode Code: 00=Normal, 01=Rush, 10=Blink, 11=Hold");
        $display("-------------------------------------------------------------");

        #100 Reset = 0;

        // ============================================================
        // CASE 1: KIỂM TRA TỰ ĐỘNG VÀO GIỜ BÌNH THƯỜNG (NORMAL)
        // ============================================================
        #100;
        $display("\n--- CASE 1: AUTO NORMAL (07:00:00) ---");
        jump_time(8'h06, 8'h59, 8'h57); // Nhảy đến sát giờ
        repeat(5) @(posedge uut.clk1);  // Chờ qua mốc 7h
        
        $display("Time: %h:%h:%h | Mode: %b (Mong doi: 00)", o_gio, o_phut, o_giay, uut.w_mode_sw);
        #1000;
        // ============================================================
        // CASE 2: KIỂM TRA TỰ ĐỘNG VÀO GIỜ CAO ĐIỂM (RUSH)
        // ============================================================
        #200;
        $display("\n--- CASE 2: AUTO RUSH (17:00:00) ---");
        jump_time(8'h16, 8'h59, 8'h58); 
        repeat(5) @(posedge uut.clk1); // Chờ qua mốc 17h
        
        $display("Time: %h:%h:%h | Mode: %b (Mong doi: 01)", o_gio, o_phut, o_giay, uut.w_mode_sw);

        #1000;
        // ============================================================
        // CASE 3: RA KHỎI KHUNG GIỜ CHIỀU
        // Mốc kết thúc: 19:30:00
        // ============================================================
        #200;
        $display("\n[TIME TRAVEL] Nhay den 18:59:58 (Chuan bi het gio Chieu)");
        jump_time(8'h18, 8'h59, 8'h58); 

        repeat(6) begin
            @(posedge uut.clk1); 
            $display("Time: %h:%h:%h | Mode Hien Tai: %b", o_gio, o_phut, o_giay, uut.w_mode_sw);
        end
        // ============================================================
        // CASE 3: KIỂM TRA CHẾ ĐỘ NHÁY ĐÈN VÀNG (BLINK)
        // Mục tiêu: sw_blink=1 phải ghi đè chế độ Auto Rush hiện tại
        // ============================================================
        #200;
        $display("\n--- CASE 3: MANUAL BLINK (Override Auto) ---");
        $display("[ACTION] Bat sw_blink = 1");
        sw_blink = 1;
        
        #100; // Chờ hệ thống phản hồi
        $display("Time: %h:%h:%h | Mode: %b (Mong doi: 10)", o_gio, o_phut, o_giay, uut.w_mode_sw);
        
        // Quan sát đèn vàng nhấp nháy trong Log
        repeat(4) begin
            @(posedge uut.clk1);
            $display("   > LED Vang L1: %b | LED Vang L2: %b (Dang nhay?)", LY1, LY2);
        end

        $display("[ACTION] Tat sw_blink = 0 -> Ve lai Auto Rush");
        sw_blink = 0;
        #50;
        $display("Time: %h:%h:%h | Mode: %b (Mong doi: 01)", o_gio, o_phut, o_giay, uut.w_mode_sw);

        // ============================================================
        // CASE 4: KIỂM TRA CHẾ ĐỘ CẦM CHỪNG (HOLD)
        // Mục tiêu: sw_hold=1 phải làm hệ thống đứng im
        // ============================================================
        #200;
        $display("\n--- CASE 4: MANUAL HOLD ---");
        $display("[ACTION] Bat sw_hold = 1");
        sw_hold = 1;
        
        #100;
        $display("Time: %h:%h:%h | Mode: %b (Mong doi: 11)", o_gio, o_phut, o_giay, uut.w_mode_sw);
        $display("   > Pause_Cnt Signal: %b (Mong doi: 1 - Dung dem)", uut.w_pause_cnt);
        
        // ============================================================
        // CASE 5: KIỂM TRA ĐỘ ƯU TIÊN (PRIORITY CHECK)
        // Mục tiêu: Nếu bật cả Blink và Hold, Hold phải thắng (Priority 1)
        // ============================================================
        #100;
        $display("\n--- CASE 5: PRIORITY CHECK (Hold vs Blink) ---");
        $display("[ACTION] Bat THEM sw_blink = 1 (Trong khi Hold van bat)");
        sw_blink = 1; 
        // sw_hold vẫn đang = 1
        
        #50;
        if (uut.w_mode_sw == 2'b11) 
            $display("RESULT: PASS! Mode van la 11 (Hold) du Blink dang bat.");
        else
            $display("RESULT: FAIL! Mode bi doi thanh %b", uut.w_mode_sw);

        // Dọn dẹp
        sw_blink = 0;
        sw_hold = 0;
        
        $display("\n-------------------------------------------------------------");
        $display("HOAN THANH MO PHONG");
        $finish;
    end

endmodule
