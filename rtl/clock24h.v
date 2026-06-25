module dong_ho_so
(
    input wire clk_1Hz,    // Xung nhịp 1Hz
    input wire rst_n,      // Reset tích cực mức thấp
    input wire btn_up,     // Nút tăng (Active low dựa trên code con)
    input wire btn_down,   // Nút giảm (Active low dựa trên code con)
    input wire [2:0] mode, // Chế độ chỉnh (000: Giây, 001: Phút, 010: Giờ)
    output wire [7:0] giay, // Xuất ra LED 7 thanh hoặc waveform
    output wire [7:0] phut,
    output wire [7:0] gio
);

    // --- Kết nối Module Đếm Giây ---
    // Module này hoạt động độc lập với phút/giờ, reset khi đến 59
    dem_giay u_dem_giay (
        .clk_1Hz    (clk_1Hz),
        .rst_n      (rst_n),
        .btn_up     (btn_up),
        .btn_down   (btn_down),
        .mode       (mode),
        .giay       (giay)      // Output này sẽ được đưa vào module phút và giờ
    );

    // --- Kết nối Module Đếm Phút ---
    // Module này cần tín hiệu 'giay' để biết khi nào tăng phút (khi giây = 59)
    dem_phut u_dem_phut (
        .clk_1Hz    (clk_1Hz),
        .rst_n      (rst_n),
        .giay       (giay),     // Input từ module dem_giay
        .btn_up     (btn_up),
        .btn_down   (btn_down),
        .mode       (mode),
        .phut       (phut)      // Output
    );

    // --- Kết nối Module Đếm Giờ ---
    // Module này cần cả 'giay' và 'phut' để tăng giờ (khi 59:59)
    dem_gio u_dem_gio (
        .clk_1Hz    (clk_1Hz),
        .rst_n      (rst_n),
        .btn_up     (btn_up),
        .btn_down   (btn_down),
        .mode       (mode),
        .giay       (giay),     // Input từ module dem_giay
        .phut       (phut),     // Input từ module dem_phut
        .gio        (gio)       // Output
    );

endmodule