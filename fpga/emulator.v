module emulator(
	input wire clk,
	input switch0_i,

	input  wire [7:0] pmod_i,  
	inout  wire [10:0] vga_io, 
	
	output wire [6:0] segA_o,
	output wire [6:0] segB_o
);

assign segA_o = {6'h0, switch0_i};
assign segB_o = 7'h00;

wire rst_n;
wire [7:0] ui_in, uo_out, uio_in, uio_out, uio_oe;

assign rst_n = ~switch0_i;
assign ui_in = pmod_i;
assign {segA_o, segB_o} = { 4'b0 , uo_out};
assign vga_io[10:8] = 3'd0;
assign vga_io[7] = uio_out[7] & uio_oe[7];
assign vga_io[6:4] = 3'd0;
assign vga_io[3] = uio_out[3] & uio_oe[3];
assign uio_in[7:3] = 5'd0;
assign uio_in[2:0] = vga_io[2:0] & ~uio_oe[2:0];

top m_top(
	.ui_in(ui_in),
	.uo_out(uo_out),
	.uio_in(uio_in),
	.uio_out(uio_out),
	.uio_oe(uio_oe),
	.ena(1'b1),
	.clk(clk),
	.rst_n(rst_n)
);


endmodule
