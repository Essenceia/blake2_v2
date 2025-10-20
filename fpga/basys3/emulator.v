`default_nettype none
module emulator #(
	parameter SWITCH_W = 2,
	parameter PMOD_W = 8,
	parameter LED_W = 1
)
(
	input wire clk_src_i,

	input wire [SWITCH_W:0] switch_i,

	input  wire [PMOD_W-1:0]  pmodA_i,  
	inout  wire [PMOD_W-1:0]  pmodB_io,  
	output wire [PMOD_W-1:0]  pmodD_o,  
 
	output wire [LED_W-1:0] led_o
);
localparam [7:0] DISSABLE_IO_PIN = 8'b0111000;

wire clk_ibufg, clk;
wire rst_n, rst_n_q;
wire ena, ena_q;
wire error; 
wire [7:0] ui_in;
wire [7:0] uo_out; 
wire [7:0] uio_in; 
wire [7:0] uio_out;
wire [7:0] uio_oe;
wire [SWITCH_W-1:0] switch;
wire [LED_W-1:0] led;/* clk */

/* clk */ 
IBUFG m_ibuf_clk(
	.I(clk_src_i),
	.O(clk_ibufg)
);

/* IO buffers */ 
genvar i; 
generate 
	for (i=0; i < PMOD_W; i=i+1) begin : g_pmod_io_buff
		IBUF m_ibuf(
			.I(pmodA_i[i]),
			.O(ui_in[i])
		);
		OBUF m_obuf(
			.I(uo_out[i]),
			.O(pmodC_o[i])
		);
		IOBUF m_iobuf (
			.O(uio_in[i]),
			.IO(pmodB_io[i]),
			.I(uio_out[i]),
			.T(DISSABLE_IO_PIN[i])
		);
	end
	for (i=0; i < SWITCH_W; i=i+1) begin: g_switch_i_buff
		IBUF m_ibuf(
			.I(switch_i[i]),
			.O(switch[i])
		);
	end
	for (i=0; i < LED_W; i=i+1) begin: g_led_o_buff
		OBUF m_obuf(
			.I(led[i]),
			.O(led_o[i])
		);
	end
endgenerate

assign rst_n = ~switch[0];
assign ena = ~switch[1];

assign led[0] = error;

top m_top(
	.ui_in(ui_in),
	.uo_out(uo_out),
	.uio_in(uio_in),
	.uio_out(uio_out),
	.uio_oe(uio_oe),
	.ena(ena),
	.clk(clk),
	.rst_n(rst_n)
);

// error 
error m_err(
	.clk(clk), 
	.nreset(rst_n), 
	
	.uio_oe(uio_oe),
	.uio_out(uio_out),

	.error_o(error)
);
endmodule
