`default_nettype none
module emulator(
	input wire clk,

	input wire [1:0] switch_i,

	input   wire [7:0]  pmodA_i,  
	input   wire [7:0]  pmodB_io,  
	input   wire [7:0]  pmodC_o,  
 
	output wire led_o
);
wire rst_n, ena;
wire error; 
wire [7:0] ui_in;
wire [7:0] hash; 
wire [7:0] uio_in; 
wire [7:0] uio_out;
wire [7:0]  uio_oe;

assign rst_n = ~switch_i[0];
assign ena = ~switch_i[1];

assign ui_in = pmodA_i;
assign uio_in = { 5'b0, pmodB_io[2:0] & ~uio_oe[2:0]};

assign pmodC_o =  hash;
assign pmodB_io[3] = uio_out[3] & uio_oe[3];
assign pmodB_io[7] = uio_out[7] & uio_oe[7];

assign led_o = error;
top m_top(
	.ui_in(ui_in),
	.uo_out(hash),
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
