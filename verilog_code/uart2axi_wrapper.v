module uart2axi_wrapper #(parameter CLK=50_000_000, BAUDRATE=115200)
(
    input clk,
    input rst_n,

    output        m_axi_gmem_AWVALID,
    input         m_axi_gmem_AWREADY,
    output [63:0] m_axi_gmem_AWADDR,
    output [0:0]  m_axi_gmem_AWID,
    output [7:0]  m_axi_gmem_AWLEN,
    output [2:0]  m_axi_gmem_AWSIZE,
    output [1:0]  m_axi_gmem_AWBURST,
    output [1:0]  m_axi_gmem_AWLOCK,
    output [3:0]  m_axi_gmem_AWCACHE,
    output [2:0]  m_axi_gmem_AWPROT,
    output [3:0]  m_axi_gmem_AWQOS,
    output [3:0]  m_axi_gmem_AWREGION,
    output [0:0]  m_axi_gmem_AWUSER,
    output        m_axi_gmem_WVALID,
    input         m_axi_gmem_WREADY,
    output [31:0] m_axi_gmem_WDATA,
    output [3:0]  m_axi_gmem_WSTRB,
    output        m_axi_gmem_WLAST,
    output [0:0]  m_axi_gmem_WID,
    output [0:0]  m_axi_gmem_WUSER,
    output        m_axi_gmem_ARVALID,
    input         m_axi_gmem_ARREADY,
    output [63:0] m_axi_gmem_ARADDR,
    output [0:0]  m_axi_gmem_ARID,
    output [7:0]  m_axi_gmem_ARLEN,
    output [2:0]  m_axi_gmem_ARSIZE,
    output [1:0]  m_axi_gmem_ARBURST,
    output [1:0]  m_axi_gmem_ARLOCK,
    output [3:0]  m_axi_gmem_ARCACHE,
    output [2:0]  m_axi_gmem_ARPROT,
    output [3:0]  m_axi_gmem_ARQOS,
    output [3:0]  m_axi_gmem_ARREGION,
    output [0:0]  m_axi_gmem_ARUSER,
    input         m_axi_gmem_RVALID,
    output        m_axi_gmem_RREADY,
    input [31:0]  m_axi_gmem_RDATA,
    input         m_axi_gmem_RLAST,
    input [0:0]   m_axi_gmem_RID,
    input [0:0]   m_axi_gmem_RUSER,
    input [1:0]   m_axi_gmem_RRESP,
    input         m_axi_gmem_BVALID,
    output        m_axi_gmem_BREADY,
    input [1:0]   m_axi_gmem_BRESP,
    input [0:0]   m_axi_gmem_BID,
    input [0:0]   m_axi_gmem_BUSER,

    input         uart_rx,
    output        uart_tx
  );

    wire b_tick;

    //---------------------
    wire [7:0] uart_wdata;
    wire [7:0] uart_rdata;

    wire uart_wr;
    wire uart_rd;
    //---------------------

    wire [7:0] tx_data;
    wire [7:0] rx_data;

    wire tx_full;
    wire tx_empty;
    wire rx_full;
    wire rx_empty;

    wire tx_done;
    wire rx_done;

    baudgen #(.CLK(CLK), .BAUDRATE(BAUDRATE)) u_baudgen(
        .clk(clk),
        .resetn(rst_n),
        .baudtick(b_tick)
    );

    sync_fifo #(.DWIDTH(8), .AWIDTH(13)) u_fifo_tx (
        .clk(clk),
        .resetn(rst_n),
        .rd(tx_done),
        .wr(uart_wr),
        .w_data(uart_wdata),
        .empty(tx_empty),
        .full(tx_full),
        .r_data(tx_data)
    );

    sync_fifo #(.DWIDTH(8), .AWIDTH(13)) u_fifo_rx (
        .clk(clk),
        .resetn(rst_n),
        .rd(uart_rd),
        .wr(rx_done),
        .w_data(rx_data),
        .empty(rx_empty),
        .full(rx_full),
        .r_data(uart_rdata)
    );

    uart_tx u_uart_tx (
        .clk(clk),
        .resetn(rst_n),
        .tx_start(~tx_empty),
        .b_tick(b_tick),
        .d_in(tx_data),
        .tx_done(tx_done),
        .tx(uart_tx)
    );

    uart_rx u_uart_rx (
        .clk(clk),
        .resetn(rst_n),
        .b_tick(b_tick),
        .rx(uart_rx),
        .rx_done(rx_done),
        .dout(rx_data)
    );

    uart2axi u_uart2axi (
        .ap_clk(clk),
        .ap_rst_n(rst_n),
        .ap_start(1'b1),
        .ap_done(),
        .ap_idle(),
        .ap_ready(),
        .rx_data_dout(uart_rdata),
        .rx_data_empty_n(~rx_empty),
        .rx_data_read(uart_rd),
        .tx_data_din(uart_wdata),
        .tx_data_full_n(~tx_full),
        .tx_data_write(uart_wr),
        .m_axi_gmem_AWVALID(m_axi_gmem_AWVALID),
        .m_axi_gmem_AWREADY(m_axi_gmem_AWREADY),
        .m_axi_gmem_AWADDR(m_axi_gmem_AWADDR),
        .m_axi_gmem_AWID(m_axi_gmem_AWID),
        .m_axi_gmem_AWLEN(m_axi_gmem_AWLEN),
        .m_axi_gmem_AWSIZE(m_axi_gmem_AWSIZE),
        .m_axi_gmem_AWBURST(m_axi_gmem_AWBURST),
        .m_axi_gmem_AWLOCK(m_axi_gmem_AWLOCK),
        .m_axi_gmem_AWCACHE(m_axi_gmem_AWCACHE),
        .m_axi_gmem_AWPROT(m_axi_gmem_AWPROT),
        .m_axi_gmem_AWQOS(m_axi_gmem_AWQOS),
        .m_axi_gmem_AWREGION(m_axi_gmem_AWREGION),
        .m_axi_gmem_AWUSER(m_axi_gmem_AWUSER),
        .m_axi_gmem_WVALID(m_axi_gmem_WVALID),
        .m_axi_gmem_WREADY(m_axi_gmem_WREADY),
        .m_axi_gmem_WDATA(m_axi_gmem_WDATA),
        .m_axi_gmem_WSTRB(m_axi_gmem_WSTRB),
        .m_axi_gmem_WLAST(m_axi_gmem_WLAST),
        .m_axi_gmem_WID(m_axi_gmem_WID),
        .m_axi_gmem_WUSER(m_axi_gmem_WUSER),
        .m_axi_gmem_ARVALID(m_axi_gmem_ARVALID),
        .m_axi_gmem_ARREADY(m_axi_gmem_ARREADY),
        .m_axi_gmem_ARADDR(m_axi_gmem_ARADDR),
        .m_axi_gmem_ARID(m_axi_gmem_ARID),
        .m_axi_gmem_ARLEN(m_axi_gmem_ARLEN),
        .m_axi_gmem_ARSIZE(m_axi_gmem_ARSIZE),
        .m_axi_gmem_ARBURST(m_axi_gmem_ARBURST),
        .m_axi_gmem_ARLOCK(m_axi_gmem_ARLOCK),
        .m_axi_gmem_ARCACHE(m_axi_gmem_ARCACHE),
        .m_axi_gmem_ARPROT(m_axi_gmem_ARPROT),
        .m_axi_gmem_ARQOS(m_axi_gmem_ARQOS),
        .m_axi_gmem_ARREGION(m_axi_gmem_ARREGION),
        .m_axi_gmem_ARUSER(m_axi_gmem_ARUSER),
        .m_axi_gmem_RVALID(m_axi_gmem_RVALID),
        .m_axi_gmem_RREADY(m_axi_gmem_RREADY),
        .m_axi_gmem_RDATA(m_axi_gmem_RDATA),
        .m_axi_gmem_RLAST(m_axi_gmem_RLAST),
        .m_axi_gmem_RID(m_axi_gmem_RID),
        .m_axi_gmem_RUSER(m_axi_gmem_RUSER),
        .m_axi_gmem_RRESP(m_axi_gmem_RRESP),
        .m_axi_gmem_BVALID(m_axi_gmem_BVALID),
        .m_axi_gmem_BREADY(m_axi_gmem_BREADY),
        .m_axi_gmem_BRESP(m_axi_gmem_BRESP),
        .m_axi_gmem_BID(m_axi_gmem_BID),
        .m_axi_gmem_BUSER(m_axi_gmem_BUSER)
    );

endmodule
