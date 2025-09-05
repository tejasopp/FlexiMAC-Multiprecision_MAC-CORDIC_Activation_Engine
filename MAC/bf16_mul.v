module bf16_mul (
    input  [15:0] a,
    input  [15:0] b,
    input         clk,
    input         rst,
    output reg [15:0] out
);

    parameter BIAS = 8'd127;

    // Extract fields
    wire sign_a = a[15];
    wire sign_b = b[15];
    wire [7:0] exp_a = a[14:7];
    wire [7:0] exp_b = b[14:7];
    wire [6:0] man_a_raw = a[6:0];
    wire [6:0] man_b_raw = b[6:0];

    wire sign_res = sign_a ^ sign_b;

    // Zero, Inf, NaN checks
    wire a_is_zero = (exp_a == 8'd0) && (man_a_raw == 7'd0);
    wire b_is_zero = (exp_b == 8'd0) && (man_b_raw == 7'd0);
    wire is_zero   = a_is_zero || b_is_zero;

    wire a_is_nan = (exp_a == 8'hFF) && (man_a_raw != 0);
    wire b_is_nan = (exp_b == 8'hFF) && (man_b_raw != 0);
    wire is_nan   = a_is_nan || b_is_nan;

    wire a_is_inf = (exp_a == 8'hFF) && (man_a_raw == 0);
    wire b_is_inf = (exp_b == 8'hFF) && (man_b_raw == 0);
    wire is_inf   = a_is_inf || b_is_inf;

    wire [7:0] man_a = (exp_a == 0) ? 8'd0 : {1'b1, man_a_raw};  // handle denormals
    wire [7:0] man_b = (exp_b == 0) ? 8'd0 : {1'b1, man_b_raw};

    // Multiply mantissas using mul8x8
    wire [15:0] mant_prod;
    mult8x8 u_mul (.a(man_a), .b(man_b), .p(mant_prod));

    // Exponent addition
    wire [8:0] exp_sum = exp_a + exp_b;

    // Normalize result
    reg [6:0] final_mant;
    reg [7:0] final_exp;

    always @(*) begin
        if (mant_prod[15]) begin
            final_mant = mant_prod[14:8];             
            final_exp  = exp_sum - BIAS + 1;
        end else begin
            final_mant = mant_prod[13:7];              
            final_exp  = exp_sum - BIAS;
        end

        // Clamp to max value if overflow
        if (final_exp > 8'hFE)
            final_exp = 8'hFE;
    end

    // Output assignment
    always @(posedge clk or posedge rst) begin
        if (rst)
            out <= 16'd0;
        else if (is_nan)
            out <= 16'b0;  
        else if (is_inf)
            out <= {sign_res, 8'hFE, 7'h7F};  // max finite value instead of Inf
        else if (is_zero)
            out <= 16'd0;
        else
            out <= {sign_res, final_exp, final_mant};
    end

endmodule
