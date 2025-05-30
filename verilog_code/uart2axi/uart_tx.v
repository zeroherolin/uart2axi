module uart_tx(
    input wire clk,
    input wire resetn,
    input wire tx_start,        
    input wire b_tick,          //baud rate tick
    input wire [7:0] d_in,      //input data
    output reg tx_done,         //transfer finished
    output wire tx              //output data to RS-232
);

    //STATE DEFINES  
    localparam [1:0] idle_st = 2'b00;
    localparam [1:0] start_st = 2'b01;
    localparam [1:0] data_st = 2'b11;
    localparam [1:0] stop_st = 2'b10;

    //Internal Signals  
    reg [1:0] current_state;
    reg [1:0] next_state;
    reg [3:0] b_reg;          //baud tick counter
    reg [3:0] b_next;
    reg [2:0] count_reg;      //data bit counter
    reg [2:0] count_next;
    reg [7:0] data_reg;       //data register
    reg [7:0] data_next;
    reg tx_reg;               //output data reg
    reg tx_next;

    //State Machine  
    always @(posedge clk or negedge resetn) begin
        if(!resetn) begin
            current_state <= idle_st;
            b_reg <= 0;
            count_reg <= 0;
            data_reg <= 0;
            tx_reg <= 1'b1;
        end else begin
            current_state <= next_state;
            b_reg <= b_next;
            count_reg <= count_next;
            data_reg <= data_next;
            tx_reg <= tx_next;
        end
    end

    //Next State Logic  
    always @* begin
        next_state = current_state;
        tx_done = 1'b0;
        b_next = b_reg;
        count_next = count_reg;
        data_next = data_reg;
        tx_next = tx_reg;
        case(current_state)
        idle_st: begin
            tx_next = 1'b1;
            if(tx_start) begin
                next_state = start_st;
                b_next = 0;
                data_next = d_in;
            end
        end
        start_st: begin
            tx_next = 1'b0;
            if(b_tick)
                if(b_reg==15) begin
                    next_state = data_st;
                    b_next = 0;
                    count_next = 0;
                end
            else
                b_next = b_reg + 1;
        end
        data_st: begin
            tx_next = data_reg[0];
            if(b_tick)
                if(b_reg == 15) begin
                    b_next = 0;
                    data_next = data_reg >> 1;
                    if(count_reg == 7)    //8 data bits
                        next_state = stop_st;
                    else
                        count_next = count_reg + 1;
                end
            else
                b_next = b_reg + 1;
        end
        stop_st: begin
            tx_next = 1'b1;
            if(b_tick)
                if(b_reg == 15) begin
                    next_state = idle_st;
                    tx_done = 1'b1;
                end
            else
                b_next = b_reg + 1;
        end
        endcase
    end

    assign tx = tx_reg;

endmodule
