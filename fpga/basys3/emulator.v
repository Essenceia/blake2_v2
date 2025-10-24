`default_nettype none
module emulator #(
	parameter SWITCH_W = 2,
	parameter PMOD_W = 8,
	parameter LED_W = 16
)
(
	input wire clk_bus_i, /* 40 MHz for now */

	input wire [SWITCH_W-1:0] switch_i,

	// PmodA	
	input  wire [PMOD_W-1:0]  data_i,  
	// Pmod B
	input  wire [2:0]         data_ctrl_i,
	input  wire [1:0]         loopback_ctrl_i,
	output wire [1:0]         hash_ctrl_o,
	// Pmod D
	output wire [PMOD_W-1:0]  hash_o,  
 
	output wire [LED_W-1:0] led_o,

	output wire [11:0] unused_o
);
wire clk_ibuf, clk_pll, clk_pll_feedback, clk;
wire pll_lock;
reg  pll_lock_q;
wire ena;
wire rst_async, ena_async;
reg rst_n_q, rst_n_d1_q;
wire error;
 
wire [7:0] ui_in;
wire [7:0] uo_out; 
wire [7:0] uio_in; 
wire [7:0] uio_out;
wire [7:0] uio_oe;
wire [SWITCH_W-1:0] switch;
wire [LED_W-1:0] led;

reg [PMOD_W-1:0] data_bus_q, data_q;
reg [PMOD_W-1:0] hash_bus_q, hash_q;
reg [2:0] data_ctrl_bus_q, data_ctrl_q;
reg [1:0] hash_ctrl_bus_q, hash_ctrl_q;
reg [1:0] loopback_ctrl_bus_q, loopback_ctrl_q;
wire [PMOD_W-1:0] hash;
wire [1:0] hash_ctrl;


IBUF m_ibuf_clk(
	.I(clk_bus_i),
	.O(clk_ibuf)
);

BUFG m_bufg_clk(
	.I(clk_pll),
	.O(clk)
);
always @(posedge clk) begin
	data_bus_q      <= data_i;
	data_q          <= data_bus_q;
	data_ctrl_bus_q <= data_ctrl_i;
	data_ctrl_q     <= data_ctrl_bus_q;
	loopback_ctrl_bus_q <= loopback_ctrl_i;
	loopback_ctrl_q     <= loopback_ctrl_bus_q;
end

always @(posedge clk) begin
	hash_ctrl_q     <= hash_ctrl;
	hash_ctrl_bus_q <= hash_ctrl_q;
	hash_q          <= hash;
	hash_bus_q      <= hash_q;
end
assign hash_ctrl_o = hash_ctrl_bus_q;
assign hash_o      = hash_bus_q;


// Global clock based on bus clock, using the same frequency
// using the inherent jitter filtering capability of the PLL
// and phase locked on bus clokc
PLLE2_BASE #(
   .CLKFBOUT_MULT(25),        
   .CLKIN1_PERIOD(25.0),      
   .CLKOUT0_DIVIDE(25),
   .DIVCLK_DIVIDE(1)
) m_global_clk_pll (
   .CLKFBIN(clk_pll_feedback),
   .CLKFBOUT(clk_pll_feedback),
   .CLKIN1(clk_ibuf),    
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
	for (i=0; i < SWITCH_W; i=i+1) begin: g_switch_ibuf
		IBUF m_switch_ibuf(
			.I(switch_i[i]),
			.O(switch[i])
		);
	end
	for (i=0; i < LED_W; i=i+1) begin: g_led_obuf
		OBUF m_led_obuf(
			.I(led[i]),
			.O(led_o[i])
		);
	end
endgenerate
assign rst_async = switch[0];

assign led[0] = rst_async;
assign led[1] = rst_n_d1_q;
assign led[2] = pll_lock_q;
assign led[3] = clk_ibuf; /* raw clk, help confirm wiring */
assign led[4] = error;
assign led[5] = ena;

assign led[13:6] = data_q; /* help debug RPI PIO code */

assign led[15:14] =  loopback_ctrl_q; 

assign unused_o = {4'h0, 1'b1, {7{1'b1}}}; // an, dp, seg

/* rst */
always @(posedge clk or posedge rst_async) begin
	if (rst_async) begin
		pll_lock_q <= 1'b0;
		rst_n_q    <= 1'b0;
		rst_n_d1_q <= 1'b0;
	end else begin
		pll_lock_q <= pll_lock;
		rst_n_q    <= pll_lock_q; 
		rst_n_d1_q <= rst_n_q; 
	end
end

debounce m_switch_debounce(
	.clk(clk),
	.rst_async(rst_async),
	.switch_i(switch[1]),
	.switch_o(ena)
);

assign ui_in = data_q;
assign uio_in = {2'b0, loopback_ctrl_q, 1'b0, data_ctrl_q};
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
