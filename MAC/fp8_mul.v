module fp8_mul (
    input  [7:0] a, b,
    input        clk, rst,
    output reg [11:0] out
);
    parameter bias_f = 4'd7;

    wire sign_a = a[7];
    wire sign_b = b[7];
    wire [3:0] exp_a = a[6:3];
    wire [3:0] exp_b = b[6:3];
    wire [3:0] mant_a = {1'b1, a[2:0]};  // 1.xxx
    wire [3:0] mant_b = {1'b1, b[2:0]};
    wire sign_res = sign_a ^ sign_b;

    wire [7:0] prod;
    mult4x4 m1 (.a(mant_a), .b(mant_b), .p(prod));

    wire [4:0] exp_sum = exp_a + exp_b;

    reg [3:0] norm_exp;
    reg [6:0] norm_mant;

    always @(*) begin
        if (prod[7]) begin
            // MSB at bit 7 → normalized form is prod[7:4]
            norm_mant = prod[6:0];  
            norm_exp  = exp_sum - bias_f + 1;
        end else if (prod[6]) begin
            norm_mant = {prod[5:0],1'b0} ;  // Shift 0
            norm_exp  = exp_sum - bias_f;
        end else if (prod[5]) begin
            norm_mant = {prod[4:0],2'b00};  // Shift left
            norm_exp  = exp_sum - bias_f - 1;
        end else begin
            // Underflow or very small values
            norm_mant = 7'd0;
            norm_exp  = 4'd0;
        end

        // Clamp exponent if it overflows
        if (norm_exp > 4'd15)
            norm_exp = 4'd15;
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            out <= 12'd0;
        else
            out <= {sign_res, norm_exp, norm_mant};
    end
endmodule

