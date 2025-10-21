`default_nettype none
module emulator #(
	parameter SWITCH_W = 2,
	parameter PMOD_W = 8,
	parameter LED_W = 1
)
(
	input wire clk_bus_i, /* 100 MHz */

	input wire [SWITCH_W:0] switch_i,

	// PmodA	
	input  wire [PMOD_W-1:0]  data_i,  
	// Pmod B
	input  wire [2:0]         data_ctrl_i,
	output wire [1:0]         hash_ctrl_o,
	// Pmod D
	output wire [PMOD_W-1:0]  hash_o,  
 
	output wire [LED_W-1:0] led_o
);
localparam [7:0] DISSABLE_IO_PIN = 8'b0111000;

wire clk_ibuf, clk_io_bus, clk_pll, clk_pll_feedback, clk;
wire pll_lock;
wire rst_async, rst_n_q;
wire ena_async, ena_q;
wire error;
 
wire [7:0] ui_in;
wire [7:0] uo_out; 
wire [7:0] uio_in; 
wire [7:0] uio_out;
wire [7:0] uio_oe;
wire [SWITCH_W-1:0] switch;
wire [LED_W-1:0] led;/* clk */

(* IOB = TRUE *) reg [PMOD_W-1:0] data_bus_q, hash_bus_q;
(* IOB = TRUE *) reg [2:0] data_ctrl_bus;
(* IOB = TRUE *) reg [1:0] hash_ctrl_bus;
reg [PMOD_W-1:0] data_q, hash_q;
reg [2:0] data_bus;
reg [1:0] hash_bus;

/* BUS */ 
IBUF m_ibuf_clk(
	.I(clk_src_i),
	.O(clk_ibuf)
);
BUFR m_bufio_clk(
	.I(clk_ibuf),
	.O(clk_io_bus)
);
BUFG m_bufg_clk(
	.I(clk_ibuf),
	.O(clk)
);
// I/O bank buffers, driver by bufr, optimized skew with parallel clk
// infer ILOGIC and OLOGIC blocks
always @(posedge clk_io_bus) begin
	data_bus_q <= data_i;
	data_ctrl_bus_q <= data_ctrl_i;
	hash_bus_q <= hash_q;
	hash_ctrl_bus_q <= hash_ctrl_q;
end
assign hash_o = hash_bus_q;
assign hash_ctr_o = hash_ctrl_bus_q;

// sync to global clock
always @(posedge clk) begin
	data_q <= data_bus_q;
	data_ctrl_q <= data_ctrl_bus_q;
	hash_q <= hash;
	hash_ctrl_q <= hash_ctrl;
end

// Global clock based on bus clock, using the same frequency
// using the inherent jitter filtering capability of the PLL
// and phase locked on bus clokc
PLLE2_BASE #(
   .CLKFBOUT_MULT(2),        
   .CLKIN1_PERIOD(10.0),      
   .CLKOUT0_DIVIDE(2)
) m_global_clk_pll (
   .CLKFBIN(clk_pll_feedback)
   .CLKFBOUT(clk_pll_feedback),
   .CLKIN1(clk_io_bus),    
   .CLKOUT0(clk_pll),
   .CLKOUT1(),
   .CLKOUT2(),
   .CLKOUT3(),
   .CLKOUT4(),
   .CLKOUT5(),
   .LOCKED(pll_lock),
   .PWRDWN(1'b0),
   .RST(rst_async) 
);

genvar i;
generate 
	for (i=0; i < SWITCH_W; i++) begin: g_switch_ibuf
		IBUF m_switch_ibuf(
			.I(switch_i[i]),
			.O(switch[i])
		);
	end
	for (i=0; i < LED_W; i=i+1) begin: g_led_obuf
		OBUF m_led_obuf(
			.I(led),
			.O(led_o)
		);
	end
endgenerate
assign rst_async = switch[0];
assign ena = ~switch[1];

assign led[0] = rst_async;
assign led[1] = pll_lock;
assign led[2] = error_q;

/* rst */
always @(posedge clk or posedge rst_async) 
	if (rst_async)
		rst_n_q <= 1'b1;
	else
		rst_n_q <= ~pll_lock; 
end

debounce m_switch_debounce(
	.clk(clk),
	.rst_async(rst_async),
	.switch_i(switch_i[i]),
	.switch_o(ena)
);

assign ui_in = data_q;
assign uio_in = {5'b0, data_ctrl_q);
assign hash = uo_out;
assign hash_ctrl = {uio_out[7], uio_out[3]};

top m_top(
	.ui_in(ui_in),
	.uo_out(uo_out),
	.uio_in(uio_in),
	.uio_out(uio_out),
	.uio_oe(uio_oe),
	.ena(ena),
	.clk(clk),
	.rst_n(rst_n_q)
);

// error 
error m_err(
	.clk(clk), 
	.nreset(rst_n_q), 
	
	.uio_oe(uio_oe),
	.uio_out(uio_out),

	.error_o(error)
);
endmodule
