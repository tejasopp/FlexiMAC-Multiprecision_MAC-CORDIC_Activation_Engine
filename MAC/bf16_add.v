module bf16_add (
    input         clk,
    input         rst,
    input  [15:0] a,
    input  [15:0] b,
    output reg [15:0] result
);

    wire sign_a = a[15];
    wire sign_b = b[15];
    wire [7:0] exp_a = a[14:7];
    wire [7:0] exp_b = b[14:7];
    wire [6:0] man_a = a[6:0];
    wire [6:0] man_b = b[6:0];

    // Normalize mantissas (implicit leading 1 for non-zero exponent)
    wire [7:0] norm_man_a = (exp_a == 8'd0) ? 8'd0 : {1'b1, man_a};
    wire [7:0] norm_man_b = (exp_b == 8'd0) ? 8'd0 : {1'b1, man_b};

    wire [7:0] exp_diff = (exp_a > exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);
    wire [7:0] aligned_man_a = (exp_a >= exp_b) ? norm_man_a : (norm_man_a >> exp_diff);
    wire [7:0] aligned_man_b = (exp_b >= exp_a) ? norm_man_b : (norm_man_b >> exp_diff);
    wire [7:0] exp_common     = (exp_a >= exp_b) ? exp_a : exp_b;

    reg [8:0] mant_sum;
    reg [6:0] final_man;
    reg [7:0] final_exp;
    reg       result_sign;

    always @(*) begin
      
        mant_sum = 9'd0;
        final_man = 7'd0;
        final_exp = 8'd0;
        result_sign = 1'b0;

        // Add/Subtract mantissas
        if (sign_a == sign_b) begin
            mant_sum = aligned_man_a + aligned_man_b;
            result_sign = sign_a;
        end else if (aligned_man_a >= aligned_man_b) begin
            mant_sum = aligned_man_a - aligned_man_b;
            result_sign = sign_a;
        end else begin
            mant_sum = aligned_man_b - aligned_man_a;
            result_sign = sign_b;
        end

        // Normalization
        if (mant_sum == 0) begin
            final_man = 7'd0;
            final_exp = 8'd0;
            result_sign = 1'b0;
        end else if (mant_sum[8]) begin
            final_man = mant_sum[7:1];
            final_exp = exp_common + 1;
        end else if (mant_sum[7]) begin
            final_man = mant_sum[6:0];
            final_exp = exp_common;
        end else begin
            final_man = mant_sum[6:0] << 1;
            final_exp = exp_common - 1;
        end

        // Clamp exponent
        if (final_exp > 8'hFE) begin
            final_exp = 8'hFF;
            final_man = 7'd0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            result <= 16'd0;
        else
            result <= {result_sign, final_exp, final_man};
    end

endmodule
