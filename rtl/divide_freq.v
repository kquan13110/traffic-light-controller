module Divide_freq #(
    parameter COUNT_VAL = 25000000 // Clock 50MHz
)(
    input clk0,
    input Reset,
    output clk1,
    output rst
);
    reg [24:0] counter_reg;
    reg clk1_reg;

    always @(posedge clk0 or posedge Reset) begin
        if (Reset) begin
            counter_reg <= 0;
            clk1_reg <= 1'b0; 
        end
        else begin
            if (counter_reg == COUNT_VAL - 1) begin //Đếm đến COUNT_VAL-1 thì lật trạng thái clk1
                counter_reg <= 0;
                clk1_reg <= ~clk1_reg;
            end
            else begin
                counter_reg <= counter_reg + 1; 
            end
        end
    end

    assign clk1 = clk1_reg; 

    // Reset_Sync
    reg rst_sync1, rst_sync2;
    always @(posedge clk1 or posedge Reset) begin
        if (Reset) begin
            rst_sync1 <= 1'b1;
            rst_sync2 <= 1'b1; 
        end
        else begin
            rst_sync1 <= 1'b0;
            rst_sync2 <= rst_sync1; 
        end
    end
    assign rst = rst_sync2; 
endmodule