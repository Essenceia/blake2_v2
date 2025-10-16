module emulator(
	input wire clk,
	input switch0_i,
	input switch1_i,

	input  wire [7:0] pmod_i,  
	inout  wire [2:0] vga_i, 
	inout  wire [10:3] vga_o, 
	
	output wire [6:0] segA_o,
	output wire [6:0] segB_o
);

assign segA_o = {6'h0, switch0_i};
assign segB_o = 7'h00;

wire rst_n, ena;
wire [7:0] ui_in, uo_out, uio_in, uio_out, uio_oe;

assign rst_n = ~switch0_i;
assign ena = switch1_i;
assign ui_in = pmod_i;
assign segB_o =  uo_out[6:0];
assign segA_o = { 4'b0 , uo_out[7]};
//assign vga_o[10:8] = 3'd0;
assign vga_o[7] = uio_out[7] & uio_oe[7];
//assign vga_o[6:4] = 3'd0;
assign vga_o[3] = uio_out[3] & uio_oe[3];
assign uio_in[7:3] = 5'd0;
assign uio_in[2:0] = vga_i[2:0] & ~uio_oe[2:0];

top m_top(
	.ui_in(ui_in),
	.uo_out(),
	.uio_in(uio_in),
	.uio_out(uio_out),
	.uio_oe(uio_oe),
	.ena(ena),
	.clk(clk),
	.rst_n(rst_n)
);


endmodule
