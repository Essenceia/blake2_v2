module byte_size_config(
	input wire clk, 
	input wire nreset, 
	input wire valid_i,
	input wire config_v_i,
	input wire [7:0] data_i,

	output wire [5:0]  kk_o,
	output wire [5:0]  nn_o,
	output wire [63:0] ll_o
); 
	// configuration
	parameter CFG_CNT_KK      = 4'd0;
	parameter CFG_CNT_NN      = 4'd1;
	parameter CFG_CNT_LL_MIN  = 4'd2;
	parameter CFG_CNT_LL_MAX  = 4'd10;

	reg       unused_cfg_cnt_q;
	reg [3:0]  cfg_cnt_q; 
	reg [5:0]  kk_q, nn_q;
	reg [63:0] ll_q;
	wire       config_v; 

	assign config_v = valid_i & config_v_i;

	always @(posedge clk) begin
		if ((~nreset) | ~valid_i | (valid_i & ~config_v_i)) begin
			cfg_cnt_q <= '0;
		end else begin
			{ unused_cfg_cnt_q, cfg_cnt_q } <= cfg_cnt_q + 'd1;
		end
	end

	always @(posedge clk) begin
		if (config_v) begin
			case(cfg_cnt_q) 
				CFG_CNT_KK: kk_q <= data_i[5:0];
				CFG_CNT_NN: nn_q <= data_i[5:0];
				default: ll_q <= {data_i, ll_q[63:8]}; 
			endcase
		end
	end

	assign kk_o = kk_q;
	assign nn_o = nn_q;
	assign ll_o = ll_q;
endmodule 

module block_data(
	input wire clk, 
	input wire nreset, 
	input wire valid_i,
	input wire [1:0] cmd_i,
	input wire [7:0] data_i,

	output wire         data_v_o,
	output wire [7:0]   data_o,
	output wire [5:0]   data_idx_o,
	output wire         block_first_o,
	output wire         block_last_o
);
	parameter CMD_CONF  = 2'd0;  
	parameter CMD_START = 2'd1;
	parameter CMD_DATA  = 2'd2;
	parameter CMD_LAST  = 2'd3;

	reg       data_v_q;
	reg [7:0] data_q;
	reg [5:0] cnt_q;
	reg       unused_cnt_q;
	wire      conf_v;
	wire      data_v;
	wire      start_v;
	reg       start_q;
	wire      last_v;
	reg       last_q;


	assign start_v = valid_i & (cmd_i == CMD_START);	
	assign last_v = valid_i & (cmd_i == CMD_LAST);	
	assign data_v = valid_i & ~(cmd_i == CMD_CONF); 
	assign conf_v = valid_i & (cmd_i == CMD_CONF);

	always @(posedge clk) begin
		if (~nreset | conf_v) begin
			cnt_q <= '0;
		end else begin
			{unused_cnt_q, cnt_q} <= cnt_q + {5'b0, data_v_q};
		end
	end

	always @(posedge clk)
		data_v_q <= data_v;

	always @(posedge clk) begin
		if (data_v) begin
			data_q <= data_i;
		end
	end

	always @(posedge clk) begin
		if ((~nreset) | (cnt_q == 6'd63))
				start_q <= '0;
		else if (start_v)
			start_q <= start_v;
	end


	always @(posedge clk) begin
		if ((~nreset) | (cnt_q == 6'd63))
				last_q <= '0;
		else if (last_v)
			last_q <= last_v;
	end

	assign data_v_o = data_v_q;
	assign data_o = data_q;
	assign data_idx_o = cnt_q;
	assign block_first_o = start_q;
	assign block_last_o = last_q; 
endmodule

module io_intf(
	// I/O
	input wire clk, 
	input wire nreset,
	input wire en_i, 
	
	input wire       valid_i,
	input wire [1:0] cmd_i,
	input wire [7:0] data_i,

	output wire       ready_v_o,
	output wire       hash_v_o,
	output wire [7:0] hash_o,

	// inner
	input wire       ready_v_i,
	input wire       hash_v_i,
	input wire [7:0] hash_i,

	output wire [5:0]  kk_o,
	output wire [5:0]  nn_o,
	output wire [63:0] ll_o,

	output wire       data_v_o,
	output wire [7:0] data_o,
	output wire [5:0] data_idx_o,
	output wire       block_first_o,
	output wire       block_last_o
);
	parameter CMD_CONF  = 2'd0;  

	// use project slice enable to gate design in order 
	// to help reduce overall tt chip dynamic power 
	// aka: play nice with other projects and be a responsible
	//      project participant
	reg en_q;
	wire valid; 
	always @(posedge clk) 
		en_q <= en_i;
	assign valid = en_q & valid_i;

	byte_size_config m_config(
		.clk(clk),
		.nreset(nreset),
		.valid_i(valid),
		.config_v_i(cmd_i == CMD_CONF),
		.data_i(data_i),

		.kk_o(kk_o),
		.nn_o(nn_o),
		.ll_o(ll_o)
	);

	block_data m_block_data(
		.clk(clk), 
		.nreset(nreset), 
		.valid_i(valid),
		.cmd_i(cmd_i),
		.data_i(data_i),

	 	.data_v_o(data_v_o),
	 	.data_o(data_o),
	 	.data_idx_o(data_idx_o),
	 	.block_first_o(block_first_o),
	 	.block_last_o(block_last_o)
	);

	assign ready_v_o = ready_v_i & ~data_v_o;
	assign hash_v_o = hash_v_i;
	assign hash_o = hash_i;
endmodule
