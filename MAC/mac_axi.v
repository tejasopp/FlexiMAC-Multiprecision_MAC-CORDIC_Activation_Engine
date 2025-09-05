`timescale 1 ns / 1 ps

// ******************************************************
//  AXI-4 FULL wrapper that streams 32 input/weight pairs
//  through **your** 4-stage `simd_pipelined_mac` core and
//  then adds the bias.  Result is 64-bit.
// ******************************************************

module mac_axi #(
    parameter integer C_S_AXI_DATA_WIDTH  = 32,
    parameter integer C_S_AXI_ADDR_WIDTH  = 8  // 256-byte map 0x00-0xFF
)(
    input  wire                              S_AXI_ACLK,
    input  wire                              S_AXI_ARESETN,

    // AXI-4 FULL write-address channel
    input  wire [C_S_AXI_ADDR_WIDTH-1:0]     S_AXI_AWADDR,
    input  wire [7:0]                        S_AXI_AWLEN,   // expect 31
    input  wire [2:0]                        S_AXI_AWSIZE,  // 010 (4-byte)
    input  wire [1:0]                        S_AXI_AWBURST, // 01  (INCR)
    input  wire                              S_AXI_AWVALID,
    output wire                              S_AXI_AWREADY,

    // AXI write-data channel
    input  wire [C_S_AXI_DATA_WIDTH-1:0]     S_AXI_WDATA,
    input  wire [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
    input  wire                              S_AXI_WLAST,
    input  wire                              S_AXI_WVALID,
    output wire                              S_AXI_WREADY,

    // AXI write-response channel
    output wire [1:0]                        S_AXI_BRESP,
    output wire                              S_AXI_BVALID,
    input  wire                              S_AXI_BREADY,

    // AXI read-address channel
    input  wire [C_S_AXI_ADDR_WIDTH-1:0]     S_AXI_ARADDR,
    input  wire [7:0]                        S_AXI_ARLEN,
    input  wire [2:0]                        S_AXI_ARSIZE,
    input  wire [1:0]                        S_AXI_ARBURST,
    input  wire                              S_AXI_ARVALID,
    output wire                              S_AXI_ARREADY,

    // AXI read-data channel
    output wire [C_S_AXI_DATA_WIDTH-1:0]     S_AXI_RDATA,
    output wire [1:0]                        S_AXI_RRESP,
    output wire                              S_AXI_RLAST,
    output wire                              S_AXI_RVALID,
    input  wire                              S_AXI_RREADY
);

// =====================================================
//  LOCAL MEMORY (inputs + weights)
// =====================================================
reg [31:0] mem32 [0:31];             // 32 × 4-byte words (128 B)
reg [15:0] bias_reg;                 // 16-bit bias written at 0x8C

// =====================================================
//  CONTROL & RESULT REGISTERS (control space ≥0x80)
// =====================================================
reg        ctrl_start;               // write 1 → start op (self-clear)
reg        ctrl_done;                // RO  (bit1 of 0x80)
reg [15:0] result_reg;               // dot-product + bias

// =====================================================
//  AXI SIGNAL REGISTERS (handshake only, IDs removed)
// =====================================================
reg awready_r, wready_r, bvalid_r;  reg [1:0] bresp_r;
reg arready_r, rvalid_r, rlast_r;   reg [1:0] rresp_r;
reg [C_S_AXI_ADDR_WIDTH-1:0] awaddr_r, araddr_r;
assign S_AXI_AWREADY = awready_r;
assign S_AXI_WREADY  = wready_r;
assign S_AXI_BVALID  = bvalid_r;
assign S_AXI_BRESP   = bresp_r;
assign S_AXI_ARREADY = arready_r;
assign S_AXI_RVALID  = rvalid_r;
assign S_AXI_RRESP   = rresp_r;
assign S_AXI_RLAST   = rlast_r;

// Read-data mux - now includes bias at 0x8C (addr[1:0]==2'b11)
assign S_AXI_RDATA = (araddr_r[7] ?
                     (araddr_r[0]==1'b0 ? {30'b0,ctrl_done,1'b0} : result_reg[15:0]): mem32[araddr_r[6:2]]);

// =====================================================
//  WRITE-CHANNEL FSM (single 32-beat burst for data)
// =====================================================
localparam WR_IDLE=0, WR_DATA=1, WR_RESP=2; reg [1:0] wr_state;
reg [5:0] wr_word_cnt;
always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        awready_r<=0; wready_r<=0; bvalid_r<=0; bresp_r<=2'b00;
        wr_state<=WR_IDLE; wr_word_cnt<=0;
    end else begin
        case(wr_state)
        WR_IDLE: begin
            if(S_AXI_AWVALID&&S_AXI_WVALID) begin
                awready_r<=1; wready_r<=1; awaddr_r<=S_AXI_AWADDR; wr_word_cnt<=0; wr_state<=WR_DATA;
            end else begin awready_r<=0; wready_r<=0; end
        end
        WR_DATA: if(S_AXI_WVALID&&wready_r) begin
            if(!awaddr_r[7]) begin  // data window 0x00-0x7F
                if(S_AXI_WSTRB==4'hF) mem32[awaddr_r[6:2]]<=S_AXI_WDATA;
            end else begin           // control space ≥0x80
                case(awaddr_r[4:2])
                    3'b000: if(S_AXI_WDATA[0]) ctrl_start<=1'b1;       // 0x80
                    3'b011: bias_reg <= S_AXI_WDATA[15:0];             // 0x8C
                endcase
            end
            awaddr_r[6:2]<=awaddr_r[6:2]+1'b1; wr_word_cnt<=wr_word_cnt+1'b1;
            if(S_AXI_WLAST) begin wready_r<=0; awready_r<=0; bvalid_r<=1; wr_state<=WR_RESP; end
        end
        WR_RESP: if(S_AXI_BREADY&&bvalid_r) begin bvalid_r<=0; wr_state<=WR_IDLE; end
        endcase
    end
end

// =====================================================
//  READ-CHANNEL FSM (supports bursts)
// =====================================================
localparam RD_IDLE=0,RD_DATA=1; reg [1:0] rd_state; reg [7:0] rd_cnt;
always @(posedge S_AXI_ACLK) begin
    if(!S_AXI_ARESETN) begin arready_r<=0; rvalid_r<=0; rresp_r<=0; rlast_r<=0; rd_state<=RD_IDLE; end else begin
        case(rd_state)
        RD_IDLE: if(S_AXI_ARVALID) begin arready_r<=1; araddr_r<=S_AXI_ARADDR; rd_cnt<=0; rd_state<=RD_DATA; end else arready_r<=0;
        RD_DATA: begin
            if(!rvalid_r) begin rvalid_r<=1; rresp_r<=0; rlast_r <= (rd_cnt==S_AXI_ARLEN); end
            else if(rvalid_r && S_AXI_RREADY) begin rvalid_r<=0; araddr_r[6:2]<=araddr_r[6:2]+1'b1; rd_cnt<=rd_cnt+1; if(rd_cnt==S_AXI_ARLEN) rd_state<=RD_IDLE; end
        end endcase end end

// =====================================================
//  SIMD-PIPELINED-MAC INSTANTIATION (your core)
// =====================================================
reg  [15:0] mac_in_a, mac_in_b, mac_in_c;
wire [15:0] mac_out;          // assume 32-bit result from core
simd_pipelined_mac u_mac (
    .a  (mac_in_a),
    .b  (mac_in_b),
    .c  (mac_in_c),
    .sel(2'b00),               // bf16/fp8/fp4 selector fixed to 00 for now
    .clk(S_AXI_ACLK),
    .out(mac_out)
);

// =====================================================
//  MAC CONTROL FSM - streams 32 pairs, 4-cycle latency
// =====================================================
localparam MAC_IDLE=0, MAC_FEED=1, MAC_WAIT=2, MAC_DONE=3; reg [1:0] mac_state;
reg [5:0] feed_cnt, cap_cnt;             // counters 0-31
reg [3:0] valid_shift;                   // 4-deep latency pipe
reg [15:0] acc;

// helpers to fetch 16-bit halves
wire [31:0] word_in  = mem32[feed_cnt[5:1]];
wire [31:0] word_wt  = mem32[16+feed_cnt[5:1]];
wire [15:0] in_half  = feed_cnt[0] ? word_in[31:16]  : word_in[15:0];
wire [15:0] wt_half  = feed_cnt[0] ? word_wt[31:16]  : word_wt[15:0];

always @(posedge S_AXI_ACLK) begin
    if(!S_AXI_ARESETN) begin
        mac_state<=MAC_IDLE; feed_cnt<=0; cap_cnt<=0; valid_shift<=0; acc<=0; ctrl_done<=0; ctrl_start<=0; result_reg<=0; mac_in_c<=0;
    end else begin
        case(mac_state)
        //------------------------------------------------
        MAC_IDLE: begin
            ctrl_done<=0; acc<=0; cap_cnt<=0; valid_shift<=0;
            if(ctrl_start) begin ctrl_start<=0; feed_cnt<=0; mac_state<=MAC_FEED; end
        end
        //------------------------------------------------
        MAC_FEED: begin
            // drive core inputs each clock
            mac_in_a <= in_half;
            mac_in_b <= wt_half;
            mac_in_c <= 16'd0;            // no bias during streaming

            valid_shift <= {valid_shift[2:0],1'b1}; // push valid bit
            if(feed_cnt==6'd31) mac_state<=MAC_WAIT;
            feed_cnt <= feed_cnt + 1'b1;
        end
        //------------------------------------------------
        MAC_WAIT: begin
            // keep pipeline full of zeros until last product exits
            mac_in_a <= 0; mac_in_b<=0; mac_in_c<=0;
            valid_shift <= {valid_shift[2:0],1'b0};
        end
        //------------------------------------------------
        MAC_DONE: ; // placeholder - never actually reached
        endcase

        // Capture core outputs after 4-cycle latency
        if(valid_shift[3]) begin
            acc <= acc + $signed(mac_out);
            cap_cnt <= cap_cnt + 1'b1;
            if(cap_cnt==6'd31) begin
                // all 32 captured - add bias, latch result
                result_reg <= acc + $signed({{48{bias_reg[15]}},bias_reg});
                ctrl_done  <= 1'b1;
                mac_state  <= MAC_IDLE;
            end
        end
    end
end

endmodule

