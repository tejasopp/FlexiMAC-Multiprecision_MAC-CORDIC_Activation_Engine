module fp8_special_case (
    input  [11:0] fp12_in,
    output [11:0] fp12_out
);

    wire sign     = fp12_in[11];
    wire [3:0] exp = fp12_in[10:7];
    wire [6:0] man = fp12_in[6:0];

    // Special case checks
    wire is_zero      = (exp == 4'b0000) && (man == 7'b0000000);
    wire is_subnormal = (exp == 4'b0000) && (man != 7'b0000000);
    wire is_inf       = (exp == 4'b1111) && (man == 7'b0000000);
    wire is_nan       = (exp == 4'b1111) && (man != 7'b0000000);

    // Constants
    wire [11:0] max_normal = {sign, 4'b1110, 7'b1111111};  // largest finite number
    wire [11:0] zero_val   = 12'b0000_0000_0000;

    assign fp12_out = is_nan       ? zero_val :
                      is_inf       ? max_normal :
                      is_zero      ? zero_val :
                      is_subnormal ? zero_val :
                      fp12_in;  // valid number, pass through

endmodule


