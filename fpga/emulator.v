`default_nettype none
module emulator(
	input wire clk,

	input wire [7:0] switch_i,

	input   wire [3:0]  pmodA_i,  
	input   wire [3:0]  pmodB_i,  
	input   wire [3:0]  pmodC_i,  
	output  wire [3:0]  pmodD_o, 
 
	output wire [7:0] led_o
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

assign ui_in = { pmodB_i, pmodA_i};
assign uio_in = {  4'b0, pmodC_i & ~uio_oe[3:0]};

assign led_o =  hash;
assign pmodD_o = { 1'b0,
				error,
				uio_out[3] & uio_oe[3],
				uio_out[7] & uio_oe[7] };

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
