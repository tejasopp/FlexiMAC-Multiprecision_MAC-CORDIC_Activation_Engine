module fp4_mul (
    input  [3:0] a,
    input  [3:0] b,
    input        clk,
    input        rst,
    output reg [5:0] out
);
    parameter bias = 2'd1;

    wire sign_a = a[3];
    wire sign_b = b[3];
    wire [1:0] exp_a = a[2:1];
    wire [1:0] exp_b = b[2:1];
    wire       is_sub_a = (exp_a == 2'b00);
    wire       is_sub_b = (exp_b == 2'b00);

    // Restore implicit 1 for normalized, or 0 for subnormal
    wire [1:0] mant_a = is_sub_a ? 2'b00 : {1'b1, a[0]};
    wire [1:0] mant_b = is_sub_b ? 2'b00 : {1'b1, b[0]};

   
    wire [3:0] prod;
    mult2x2 mul (.a(mant_a), .b(mant_b), .p(prod));

    // Add exponents (treat subnormal exponent as 0)
    wire [2:0] exp_sum = (is_sub_a ? 3'd0 : {1'b0, exp_a}) + 
                         (is_sub_b ? 3'd0 : {1'b0, exp_b});

    // Sign of result
    wire sign_res = sign_a ^ sign_b;

    // Normalization
    reg [1:0] final_exp;
    reg [2:0]      final_mant;

    always @(*) begin
        if (prod[3]) begin
            final_exp  = exp_sum + 1 - bias;  
            final_mant = prod[2:0];
        end else if (prod[2]) begin
            final_exp  = exp_sum - bias;
            final_mant = {prod[1:0],1'b0};
        end else begin
            // result is zero or denormal
            final_exp  = 0;
            final_mant = 0;
        end

        // Handle exponent overflow (max value = 3 for 2 bits)
        if (final_exp > 2'b11)
            final_exp = 2'b11;
    end

    
    always @(posedge clk or posedge rst) begin
        if (rst)
            out <= 6'b000000;
        else
            out <= {sign_res, final_exp, final_mant};
    end

endmodule

