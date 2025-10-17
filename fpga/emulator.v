`default_nettype none
module emulator(
	input wire clk,

	input wire switch0_i, // rst
	input wire switch1_i, // dissable design


	input   wire [7:0]  pmod_i,  
	input   wire [2:0]  vga_i, 
	output  wire [10:3] vga_o, 
	
	output wire       led0_o, // error led
	output wire [6:0] segA_o,
	output wire [6:0] segB_o
);
wire rst_n, ena;
wire error; 
wire [7:0] ui_in;
wire [7:0] hash; 
wire [7:0] uio_in; 
wire [7:0] uio_out;
wire [7:0]  uio_oe;

assign rst_n = ~switch0_i;
assign ena = ~switch1_i;
assign ui_in = pmod_i;
assign segB_o =  hash[6:0];
assign segA_o = { 6'b0 , hash[7]};

assign vga_o = { 3'd0,  // 10:8
				uio_out[7] & uio_oe[7], // 7
				3'd0, // 6:4
				uio_out[3] & uio_oe[3]}; // 3
assign uio_in[7:3] = 5'd0;
assign uio_in[2:0] = vga_i[2:0] & ~uio_oe[2:0];

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
assign led0_o = error;
endmodule
