module byte_size_config(
	input wire clk, 
	input wire nreset,
 
	input wire       valid_i,
	input wire [1:0] cmd_i,
	input wire [7:0] data_i,

	output wire [5:0]  kk_o,
	output wire [5:0]  nn_o,
	output wire [63:0] ll_o
); 
	// configuration
	localparam CMD_CONF        = 2'd0;  
	localparam CFG_CNT_KK      = 4'd0;
	localparam CFG_CNT_NN      = 4'd1;
	/* verilator lint_off UNUSEDPARAM */
	localparam CFG_CNT_LL_MIN  = 4'd2;
	/* verilator lint_on UNUSEDPARAM */
	localparam CFG_CNT_LL_MAX  = 4'd9;

	reg       unused_cfg_cnt_q;
	(* MARK_DEBUG = "true" *) reg [3:0]  cfg_cnt_q; 
	(* MARK_DEBUG = "true" *) reg [5:0]  kk_q, nn_q;
	(* MARK_DEBUG = "true" *) reg [63:0] ll_q;
	wire       config_v; 
	wire       config_n_v; 

	assign config_v   = valid_i & (cmd_i == CMD_CONF);
	assign config_n_v = valid_i & ~(cmd_i == CMD_CONF);

	always @(posedge clk) begin
		if ((~nreset) | config_n_v | (cfg_cnt_q == CFG_CNT_LL_MAX)) begin
			cfg_cnt_q <= 'd0;
		end else begin
			{ unused_cfg_cnt_q, cfg_cnt_q } <= cfg_cnt_q + {3'b0, config_v};
		end
	end

	always @(posedge clk) begin
		if (~nreset) begin
			kk_q <= 6'b0;
			nn_q <= 6'b0;
			ll_q <= 64'b0;
		end else if (config_v) begin
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
	localparam CMD_CONF  = 2'd0;  
	localparam CMD_START = 2'd1;
	localparam CMD_LAST  = 2'd3;
	/* verilator lint_off UNUSEDPARAM */
	localparam CMD_DATA  = 2'd2;
	/* verilator lint_on UNUSEDPARAM */

	reg       data_v_q;
	reg [7:0] data_q;
	(* MARK_DEBUG = "true" *) reg [5:0] data_cnt_q;
	reg [5:0] data_idx_q;
	reg       unused_data_cnt_q;
	wire      conf_v;
	wire      data_v;
	wire      start_v;
	reg       start_q;
	wire      last_v;
	reg       last_q;


	assign start_v = valid_i & (cmd_i == CMD_START);	
	assign last_v  = valid_i & (cmd_i == CMD_LAST);	
	assign data_v  = valid_i & ~(cmd_i == CMD_CONF); 
	assign conf_v  = valid_i & (cmd_i == CMD_CONF);

	always @(posedge clk) begin
		if (~nreset | conf_v) begin
			data_cnt_q <= 'd0;
		end else begin
			{unused_data_cnt_q, data_cnt_q} <= data_cnt_q + {5'b0, data_v};
		end
	end

	always @(posedge clk) begin
		data_v_q   <= data_v;
		data_idx_q <= data_cnt_q; // idx = cnt - 1, saving on added logic by capturing the unincremented version of cnt
	end

	always @(posedge clk) begin
		if (data_v) begin
			data_q <= data_i;
		end
	end

	always @(posedge clk) begin
		if ((~nreset) | ((data_cnt_q == 6'd0) & data_v & ~start_v))
			start_q <= 'd0;
		else if (start_v)
			start_q <= start_v;
	end


	always @(posedge clk) begin
		if ((~nreset) | ((data_cnt_q == 6'd0) & data_v & ~last_v))
			last_q <= 'd0;
		else if (last_v)
			last_q <= last_v;
	end

	assign data_v_o      = data_v_q;
	assign data_o        = data_q;
	assign data_idx_o    = data_idx_q;
	assign block_first_o = start_q;
	assign block_last_o  = last_q; 
endmodule

module io_intf(
	// I/O
	input wire clk, 
	input wire nreset,

	input wire en_i, 
	
	input wire       valid_i,
	input wire [1:0] cmd_i,
	input wire [7:0] data_i,

	input wire [1:0] loopback_mode_i,

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
	localparam [1:0] LOOPBACK_NONE   = 2'b00;
	localparam [1:0] LOOPBACK_DATA   = 2'b01;
/* verilator lint_off UNUSEDPARAM */
	localparam [1:0] LOOPBACK_CTRL   = 2'b10;
	localparam [1:0] LOOPBACK_CTRL_2 = 2'b11;
/* verilator lint_on UNUSEDPARAM */
	reg [1:0] loopback_mode_q;
	wire [7:0] cmd;
 
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
		.cmd_i(cmd_i),
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
	// loopback mode 
	always @(posedge clk) 
		if (~nreset)
			loopback_mode_q <= LOOPBACK_NONE;
		else if(en_q)
			loopback_mode_q <= loopback_mode_i;
	
	assign cmd = {2'b0, loopback_mode_q, 1'b0, cmd_i, valid_i}; // rebuild cmd

	assign ready_v_o = ready_v_i & ~data_v_o;
	assign hash_v_o = hash_v_i;
	assign hash_o = (loopback_mode_q == LOOPBACK_NONE) ? hash_i
				  : (loopback_mode_q == LOOPBACK_DATA) ? data_i : cmd;
endmodule
