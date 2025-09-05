module fp8_add (
    input         clk,
    input         rst,
    input  [11:0] a,
    input  [11:0] b,
    output reg [11:0] result
);

    
    wire sign_a = a[11];
    wire sign_b = b[11];
    wire [3:0] exp_a = a[10:7];
    wire [3:0] exp_b = b[10:7];
    wire [6:0] man_a = a[6:0];
    wire [6:0] man_b = b[6:0];

    // Normalize mantissas (implicit leading 1 for normalized)
    wire [7:0] norm_man_a = (exp_a == 4'd0) ? {1'b0, man_a} : {1'b1, man_a};
    wire [7:0] norm_man_b = (exp_b == 4'd0) ? {1'b0, man_b} : {1'b1, man_b};

    // Align exponents
    wire [3:0] exp_diff = (exp_a > exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);
    wire [8:0] aligned_man_a = (exp_a >= exp_b) ? {1'b0, norm_man_a} : ({1'b0, norm_man_a} >> exp_diff);
    wire [8:0] aligned_man_b = (exp_b >= exp_a) ? {1'b0, norm_man_b} : ({1'b0, norm_man_b} >> exp_diff);
    wire [3:0] exp_common = (exp_a >= exp_b) ? exp_a : exp_b;

    // Internal registers
    reg [9:0] mant_sum;
    reg [6:0] final_man;
    reg [3:0] final_exp;
    reg       result_sign;

    always @(*) begin
        // Default assignments
        mant_sum = 10'd0;
        final_man = 7'd0;
        final_exp = 4'd0;
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
            final_exp = 4'd0;
            result_sign = 1'b0;
        end else if (mant_sum[9]) begin
            final_man = mant_sum[8:2];  
            final_exp = exp_common + 2;
        end else if (mant_sum[8]) begin
            final_man = mant_sum[7:1];
            final_exp = exp_common + 1;
        end else if (mant_sum[7]) begin
            final_man = mant_sum[6:0];
            final_exp = exp_common;
        end else if (mant_sum[6]) begin
            final_man = mant_sum[5:0] << 1;
            final_exp = exp_common - 1;
        end else if (mant_sum[5]) begin
            final_man = mant_sum[4:0] << 2;
            final_exp = exp_common - 2;
        end else begin
            final_man = 7'd0;
            final_exp = 4'd0;
        end

        // Clamp overflow
        if (final_exp > 4'd14) begin
            final_exp = 4'd15;
            final_man = 7'd0;
        end
    end

    // Register result
    always @(posedge clk or posedge rst) begin
        if (rst)
            result <= 12'd0;
        else
            result <= {result_sign, final_exp, final_man};
    end
endmodule

