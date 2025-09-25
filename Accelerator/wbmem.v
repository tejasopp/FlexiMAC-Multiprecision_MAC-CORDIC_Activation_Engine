module wbmem (
    input  clk, rst,
    input [1:0] load,
    input [7:0] data_in,
    input [32*32*8-1:0] res,
    input [5:0] cnt_r, cnt_c,    // Acts as address 
    input [4:0] cnt_w,
    output reg [32*32*8-1:0] im_r,   // flattened 32x32 r image = 1024 bytes 
//    output reg [28*28*8-1:0] im_g,   // flattened 28x28 g image = 784 bytes
//    output reg [28*28*8-1:0] im_b,   // flattened 28x28 b image = 784 bytes
    output reg [7:0] w_r
   );

    reg [7:0] mem_r [0:1295];        // r memory array       
//    reg [7:0] mem_g [0:1024];        // g memory array       
//    reg [7:0] mem_b [0:1024];        // b memory array       
    reg [7:0] wr_mem [0:24];
//    reg [7:0] wg_mem [0:24];
//    reg [7:0] wb_mem [0:24];
    reg [7:0] out_mem [0:1023];
    
    reg [10:0] addr_rgb;   // for mem_r, mem_g, mem_b (0..1024)
    reg [4:0]  addr_w;     // for wr_mem, wg_mem, wb_mem (0..24)
    
    integer i, j, k;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        for (i = 0; i <= 1296; i = i + 1)
            mem_r[i] <= 8'b0;

        for (i = 0; i <= 24; i = i + 1)
            wr_mem[i] <= 8'b0;

        addr_rgb <= 0;
        addr_w   <= 0;
    end
    else begin
        case (load)
            2'b10: begin  // load_r
                mem_r[addr_rgb] <= data_in;
                if (addr_rgb < 1296) addr_rgb <= addr_rgb + 1;
                else addr_rgb <= 0;
            end
            2'b01: begin  // load_wr
                wr_mem[addr_w] <= data_in;
                if (addr_w < 24) addr_w <= addr_w + 1;
                else addr_w <= 0;
            end
        endcase
    end
end


always @(*) begin
    for (i = 0; i < 32; i = i + 1) begin
        for (j = 0; j < 32; j = j + 1) begin
            im_r[((i*32+j)*8) +: 8] = mem_r[(cnt_r + i)*64 + (cnt_c + j)];
        end
    end

    w_r = wr_mem[cnt_w];

    for (k = 0; k < 1024; k = k + 1) begin
        out_mem[k] = res[8*k +: 8];
    end
end

endmodule
