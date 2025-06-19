module baudgen #(parameter CLK=50_000_000, BAUDRATE=115200)
(
    input wire clk,
    input wire resetn,
    output wire baudtick
);

    reg [21:0] count_reg;
    wire [21:0] count_next;

    //Counter
    always @ (posedge clk or negedge resetn) begin
        if(!resetn)
            count_reg <= 0;
        else
            count_reg <= count_next;
    end

    //Baudrate = 115200 = 50Mhz/(27*16)
    assign count_next = ((count_reg == CLK/BAUDRATE/16) ? 0 : count_reg + 1'b1);

    assign baudtick = ((count_reg == CLK/BAUDRATE/16) ? 1'b1 : 1'b0);

endmodule
