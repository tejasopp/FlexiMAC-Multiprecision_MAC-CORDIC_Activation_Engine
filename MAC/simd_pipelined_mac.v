module simd_pipelined_mac (
    input  [15:0] a, b, c,
    input  [1:0] sel,
    input        clk,
    output reg [15:0] out
);

    
    wire [15:0] bf16_out;
    wire [7:0]  fp8_out0, fp8_out1;
    wire [3:0]  fp4_out0, fp4_out1, fp4_out2, fp4_out3;

   
    reg rst0, rst1, rst2;

   
    bf16_mac mac0 (
        .a(a), .b(b), .c(c), .clk(clk), .rst(rst0), .acc(bf16_out)
    );

   
    fp8_mac mac1 (
        .a0(a[15:8]), .a1(a[7:0]),
        .b0(b[15:8]), .b1(b[7:0]),
        .c0(c[15:8]), .c1(c[7:0]),
        .clk(clk), .rst(rst1),
        .facc0(fp8_out0), .facc1(fp8_out1)
    );

   
    fp4_mac mac2 (
        .a0(a[15:12]), .a1(a[11:8]), .a2(a[7:4]), .a3(a[3:0]),
        .b0(b[15:12]), .b1(b[11:8]), .b2(b[7:4]), .b3(b[3:0]),
        .c0(c[15:12]), .c1(c[11:8]), .c2(b[7:4]), .c3(c[3:0]),
        .clk(clk), .rst(rst2),
        .facc0(fp4_out0), .facc1(fp4_out1), .facc2(fp4_out2), .facc3(fp4_out3)
    );

    // Control logic
    always @(*) begin
        // Default reset values (inactive)
        rst0 = 1;
        rst1 = 1;
        rst2 = 1;
//        out = 16'd0;

        case (sel)
            2'd0: begin // BF16 mode
                rst0 = 0;
                out  = bf16_out;
            end

            2'd1: begin // FP8 SIMD mode
                rst1 = 0;
                out = {fp8_out0, fp8_out1};
            end

            2'd2: begin // FP4 SIMD mode
                rst2 = 0;
                out = {fp4_out0, fp4_out1, fp4_out2, fp4_out3};
            end

            2'd3: begin
                out = 0;
            end
        endcase
    end

endmodule


