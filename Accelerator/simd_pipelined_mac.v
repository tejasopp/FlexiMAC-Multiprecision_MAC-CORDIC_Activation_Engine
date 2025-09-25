module simd_pipelined_mac (
    input  [7:0] a, b, 
    input   sel, rst,
    input        clk,
    output reg [7:0] out
);

    
//    wire [15:0] bf16_out;
    wire [7:0]  fp8_out0;
    wire [3:0]  fp4_out0, fp4_out1;

   
    reg rst1, rst2;

   
//    bf16_mac mac0 (
//        .a(a), .b(b), .c(c), .clk(clk), .rst(rst0), .acc(bf16_out)
//    );

   
    fp8_mac mac1 (
        .a0(a[7:0]),
        .b0(b[7:0]),
//        .c0(c[15:8]), .c1(c[7:0]),
        .clk(clk), .rst(rst1),
        .facc0(fp8_out0)
    );

   
    fp4_mac mac2 (
        .a0(a[7:4]), .a1(a[3:0]),
        .b0(b[7:4]), .b1(b[3:0]),
//        .c0(c[15:12]), .c1(c[11:8]), .c2(b[7:4]), .c3(c[3:0]),
        .clk(clk), .rst(rst2),
        .facc0(fp4_out0), .facc1(fp4_out1)
    );

    // Control logic
    always @(posedge clk or negedge rst) begin
        // Default reset values (inactive)
//        rst0 = 1;
        if (!rst) begin
        rst1 <= 1;
        rst2 <= 1;
//        out = 16'd0;
        end
        else begin
        case (sel)
//            2'd0: begin // BF16 mode
//                rst0 = 0;
//                out  = bf16_out;
//            end

            1'd0: begin // FP8 SIMD mode
                rst1 <= 0;
                rst2 <= 1;
                out <= fp8_out0;
            end

            1'd1: begin // FP4 SIMD mode
                rst2 <= 0;
                rst1 <= 1;
                out <= {fp4_out0, fp4_out1};
            end

            default : begin
                rst1 <= 0;
                rst2 <= 1;
                out <= fp8_out0;
            end
        endcase
        end
    end

endmodule
