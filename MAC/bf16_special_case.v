module bf16_special_case (
    input  [15:0] bf16_in,
    output [15:0] bf16_out
);

    wire sign       = bf16_in[15];
    wire [7:0] exp  = bf16_in[14:7];
    wire [6:0] man  = bf16_in[6:0];

    // Special case checks
    wire is_zero      = (exp == 8'b0000_0000) && (man == 7'b0000000);
    wire is_subnormal = (exp == 8'b0000_0000) && (man != 7'b0000000);
    wire is_inf       = (exp == 8'b1111_1111) && (man == 7'b0000000);
    wire is_nan       = (exp == 8'b1111_1111) && (man != 7'b0000000);

    // Corrected values
    wire [15:0] max_normal = {sign, 8'b1111_1110, 7'b111_1111};  // Largest finite value
    wire [15:0] zero_val   = 16'b0000_0000_0000_0000;

    assign bf16_out = is_nan       ? zero_val :
                      is_inf       ? max_normal :
                      is_zero      ? zero_val :
                      is_subnormal ? zero_val :
                      bf16_in;  // Normal number, passthrough

endmodule
