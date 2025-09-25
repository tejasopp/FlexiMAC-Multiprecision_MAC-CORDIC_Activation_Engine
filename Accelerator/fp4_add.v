module fp4_add (
    input        clk,
    input        rst,
    input  [5:0] a,
    input  [5:0] b,
    output reg [5:0] result
);

   
    wire sign_a = a[5];
    wire sign_b = b[5];
    wire [1:0] exp_a = a[4:3];
    wire [1:0] exp_b = b[4:3];
    wire [2:0] man_a = a[2:0];
    wire [2:0] man_b = b[2:0];

    
    wire [3:0] norm_man_a = (exp_a == 2'b00) ? {1'b0, man_a} : {1'b1, man_a};
    wire [3:0] norm_man_b = (exp_b == 2'b00) ? {1'b0, man_b} : {1'b1, man_b};

    
    wire [1:0] exp_diff = (exp_a > exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);
    wire [4:0] aligned_man_a = (exp_a >= exp_b) ? {1'b0, norm_man_a} : ({1'b0, norm_man_a} >> exp_diff);
    wire [4:0] aligned_man_b = (exp_b >= exp_a) ? {1'b0, norm_man_b} : ({1'b0, norm_man_b} >> exp_diff);
    wire [1:0] exp_common = (exp_a >= exp_b) ? exp_a : exp_b;

    reg [5:0] mant_sum;
    reg [2:0] final_man;
    reg [1:0] final_exp;
    reg       result_sign;

    always @(*) begin
      
        mant_sum = 6'd0;
        final_man = 3'd0;
        final_exp = 2'd0;
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
            final_man = 3'd0;
            final_exp = 2'd0;
            result_sign = 1'b0;
        end else if (mant_sum[5]) begin
            final_man = mant_sum[4:2];
            final_exp = exp_common + 1;
        end else if (mant_sum[4]) begin
            final_man = mant_sum[3:1];
            final_exp = exp_common;
        end else if (mant_sum[3]) begin
            final_man = mant_sum[2:0];
            final_exp = exp_common - 1;
        end else begin
            final_man = mant_sum[1:0] << 1;
            final_exp = exp_common - 2;
        end

        // Clamp for overflow
        if (final_exp > 2'd2) begin
            final_exp = 2'd3;  // set to Inf
            final_man = 3'd0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            result <= 6'd0;
        else
            result <= {result_sign, final_exp, final_man};
    end
endmodule


